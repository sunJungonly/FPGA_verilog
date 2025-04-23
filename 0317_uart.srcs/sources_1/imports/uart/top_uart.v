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
        // fsm 
        parameter IDLE = 4'h0, SEND = 4'h1, START = 4'h2, 
                  DATA = 4'h3, STOP = 4'h4;
        reg [3:0] state, next;
        reg tx_reg, tx_next;
        reg tx_done_reg, tx_done_next;
        reg [2:0]bit_count_reg, bit_count_next;
        assign o_tx_done = tx_done_reg;
        assign o_tx = tx_reg;

        always @(posedge clk, posedge rst) begin
            if (rst) begin
                state <= 0;
                tx_reg <= 1; //Uart tx line을 초기에 항상 1로 만들기 위함함
                tx_done_reg <= 0;
                bit_count_reg <= 0;
            end else begin
                state <= next;
                tx_reg <= tx_next;
                tx_done_reg <= tx_done_next;
                bit_count_reg <= bit_count_next;
            end
        end

        //next
        always @(*) begin
            next = state;
            tx_next = tx_reg;
            tx_done_next = tx_done_reg;
            bit_count_next = bit_count_reg;
            case (state)
                IDLE: begin
                    //tx_done_next = 1'b1; // high, 1번자리리
                    tx_next = 1'b1;
                    tx_done_next = 1'b0;
                    if (start_trigger) begin
                        // 1번 자리
                        next = SEND;
                    end
                end

                SEND: begin
                    if (tick == 1'b1) begin
                        next = START;
                    end
                end   

                START: begin
                        // if문 안에 있으면 시간상 안맞기 때문// send에서 start 오자마자 done을 1로 만듦
                        tx_done_next = 1'b1; 
                    if (tick == 1'b1) begin
                        tx_next = 1'b0; // 출력 //tick이 와야 0으로 떨궈야 함
                        next = DATA;   
                        bit_count_next = 1'b0; 
                    end
                end   

                DATA: begin
                    tx_next = data_in[bit_count_reg]; //UART LSB first//조합논리에서 shift register 래치 생길수도 있음
                    if (tick) begin
                        bit_count_next = bit_count_reg + 1; // bit count 증가
                        if (bit_count_reg == 7) begin
                            next = STOP;
                        end else begin
                            next = DATA;
                        end
                    end
                end

                STOP: begin
                    if (tick == 1'b1) begin
                        tx_next = 1'b1;
                        next = IDLE;
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
    localparam BAUD_COUNT = 100_000_000 / BAUD_RATE / 16 ;
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