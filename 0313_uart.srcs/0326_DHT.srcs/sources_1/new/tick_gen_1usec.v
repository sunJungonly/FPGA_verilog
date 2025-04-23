`timescale 1ns / 1ps
//1usec 에서 가독성을 위해 10usec으로 변경함함
module tick_gen_1usec(
    input clk,
    input rst,
    output tick_1usec
    );

    parameter FCOUNT = 10;
    reg [$clog2(FCOUNT) - 1:0] count_reg, count_next;

    reg tick_1usec_reg, tick_1usec_next;
    assign tick_1usec = tick_1usec_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            tick_1usec_reg <= 0;
            count_reg <= 0;
        end else begin
            tick_1usec_reg <= tick_1usec_next;
            count_reg <= count_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        tick_1usec_next = tick_1usec_reg;
        if (count_reg == (FCOUNT -1)) begin
            count_next = 0;
            tick_1usec_next = 1;
        end else begin
            count_next = count_reg + 1;
            tick_1usec_next = 0;
        end
        
    end

endmodule
