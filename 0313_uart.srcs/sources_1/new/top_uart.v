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
        parameter IDLE = 4'h0, START = 4'h1, 
                  D0 = 4'h2,
                  D1 = 4'h3,
                  D2 = 4'h4,
                  D3 = 4'h5,
                  D4 = 4'h6,
                  D5 = 4'h7,
                  D6 = 4'h8,
                  D7 = 4'h9,
                  STOP = 4'ha;
        reg [3:0] state, next;
        reg tx_reg, tx_next;
        reg tx_done_reg, tx_done_next;

        assign o_tx_done = tx_done_reg;
        assign o_tx = tx_reg;

        always @(posedge clk, posedge rst) begin
            if (rst) begin
                state <= 0;
                tx_reg <= 1; //Uart tx line을 초기에 항상 1로 만들기 위함함
                tx_done_reg <= 0;
            end else begin
                state <= next;
                tx_reg <= tx_next;
                tx_done_reg <= tx_done_next;
            end
        end

        //next
        always @(*) begin
            next = state;
            tx_next = tx_reg;
            tx_done_next = tx_done_reg;
            case (state)
                IDLE: begin
                    //tx_done_next = 1'b1; // high, 1번자리리
                    tx_next = 1'b1;
                    if (start_trigger) begin
                        // 1번 자리
                        next = START;
                    end
                end        
                START: begin
                    if (tick == 1'b1) begin
                        tx_done_next = 1'b1; // 2번 자리
                        tx_next = 1'b0; // 출력 //tick이 와야 0으로 떨궈야 함
                        next = D0;    
                    end
                end        
                D0: begin
                    if (tick == 1'b1) begin
                        tx_next = data_in[0];
                        next = D1;
                    end
                end
                D1: begin
                    if (tick == 1'b1) begin
                        tx_next = data_in[1];
                        next = D2;
                    end
                end
                D2: begin
                    if (tick == 1'b1) begin
                        tx_next = data_in[2];
                        next = D3;
                    end
                end
                D3: begin
                    if (tick == 1'b1) begin
                        tx_next = data_in[3];
                        next = D4;
                    end
                end
                D4: begin
                    if (tick == 1'b1) begin
                        tx_next = data_in[4];
                        next = D5;
                    end
                end
                D5: begin
                    if (tick == 1'b1) begin
                        tx_next = data_in[5];
                        next = D6;
                    end
                end
                D6: begin
                    if (tick == 1'b1) begin
                        tx_next = data_in[6];
                        next = D7;
                    end
                end
                D7: begin
                    if (tick == 1'b1) begin
                        tx_next = data_in[7];
                        next = STOP;
                    end
                end
                STOP: begin
                    if (tick == 1'b1) begin
                        tx_done_next = 1'b0;
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
    localparam BAUD_COUNT = 100_000_000 / BAUD_RATE ;
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