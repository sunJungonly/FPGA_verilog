`timescale 1ns / 1ps

module mux_2x1(
    input [1:0] sel,
    input [15:0] digit_1,
    input [15:0] digit_100,
    output [7:0] o_bcd
);
    reg [7:0] r_bcd;
    assign o_bcd = r_bcd;

    always @(sel, digit_1, digit_100) begin
        case(sel)
            2'b0: r_bcd = digit_1;
            2'b1: r_bcd = digit_100;
            default: r_bcd = 4'bx; // 상관없음
        endcase
    end

endmodule

