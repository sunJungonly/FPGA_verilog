`timescale 1ns / 1ps

module top_uart(
    input clk,
    input rst,
    input btn_start,
    input [7:0] tx_data_in,
    output tx_done,
    output tx
);

    wire w_tick;
    
    uart_tx U_UART_TX (
        .clk(clk),
        .rst(rst),
        .tick(w_tick),
        .start_trigger(btn_start),
        .data_in(tx_data_in),
        .o_tx_done(tx_done),
        .o_tx(tx)
    );

    baud_tick_gen U_BAUD_Tick_Gen (
        .clk(clk),
        .rst(rst),
        .baud_tick(w_tick) 
    );

    
endmodule

    module uart_tx (
    input clk,
    input rst,
    input tick,
    input start_trigger,
    input [7:0] data_in,
    output o_tx_done,
    output o_tx
);
    // FSM 상태 정의
    parameter IDLE = 'b00, START = 2'b01, 
              DATA = 2'b10, STOP = 2'b11;

    reg [1:0] state, next;
    reg tx_reg, tx_next;
    reg tx_done_reg, tx_done_next;
    reg [2:0] data_count, data_count_next; // 3비트 카운터 (0~7)
    reg [3:0] tick_count_reg, tick_count_next;
    assign o_tx = tx_reg;
    assign o_tx_done = tx_done_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            tx_reg      <= 1'b1; // UART TX 초기 상태 HIGH
            tx_done_reg <= 0;
            data_count   <= 0;
            tick_count_reg <= 0;
        end else begin
            state       <= next;
            tx_reg      <= tx_next;
            tx_done_reg <= tx_done_next;
            data_count   <= data_count_next;
            tick_count_reg <= tick_count_next;
        end
    end

    // 상태 전이 로직
    always @(*) begin
        next = state;
        tx_next = tx_reg;
        tx_done_next = tx_done_reg;
        data_count_next = data_count;
        tick_count_next = tick_count_reg;

        case (state)
            IDLE: begin
                tx_done_next = 1'b0; 
                tx_next = 1'b1;
                tick_count_next = 4'h0;
                if (start_trigger) begin
                    next = START;
                end
            end      

            START: begin
                tx_done_next = 1'b1;
                tx_next = 1'b0; //출력을 0으로 유지지
                if (tick) begin
                    if (tick_count_reg == 15) begin
                        next = DATA;
                    data_count_next = 0; // 중요 첫 번 째 rst 이후 rst에서도 0되어야 함함
                    tick_count_next = 0;
                    end else begin
                    tick_count_next =tick_count_reg + 1;
                    end
                end
            end        
            DATA: begin
                tx_next = data_in[data_count]; // 일단 출력

                if (tick) begin
                    if (tick_count_reg == 15) begin
                        tick_count_next = 0; //다음 상태로 가기 전에 초기화화
                        if (data_count == 3'd7) begin 
                            next = STOP;
                        end else begin
                            next = DATA;
                            data_count_next = data_count + 1; 
                        end
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end

            STOP: begin
                tx_next = 1'b1; 
                data_count_next = 0;
                if (tick) begin
                    if (tick_count_reg == 15) begin
                        next = IDLE;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule


module baud_tick_gen (
    input clk,
    input rst,
    output baud_tick 
);
    
    parameter BAUD_RATE = 9600; // BAUD_RATE_19200 = 19200, ;
    localparam BAUD_COUNT = (100_000_000 / BAUD_RATE) / 16 ;
    reg [$clog2(BAUD_COUNT)-1:0] count_reg, count_next;
    reg tick_reg, tick_next;
    // output
    assign baud_tick = tick_reg;

    always @(posedge clk, posedge rst) begin
        if (rst == 1) begin
            count_reg <= 0;
            tick_reg <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg <= tick_next;
        end
    end

    //next 
    always @(*) begin
        count_next = count_reg;
        tick_next = tick_reg;
        if (count_reg == BAUD_COUNT - 1) begin
            count_next = 0;
            tick_next = 1'b1;
        end else begin
            count_next = count_reg + 1;
            tick_next = 1'b0;
        end
    end

endmodule

