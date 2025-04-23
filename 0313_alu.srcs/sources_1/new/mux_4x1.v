`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/13 10:26:26
// Design Name: 
// Module Name: mux_4x1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux_4x1(
    input [1:0] sel,
    input [3:0] a,
    input [3:0] b,
    input [3:0] c,
    input [3:0] d,
    output reg [3:0] mux_out
    );

//3항
    // assign mux_out = (sel == 0) ? a:
    //                  (sel == 1) ? b:
    //                  (sel == 2) ? c:
    //                  (sel == 3) ? d: 4'bx;

//always if else
    // always @(*) begin
    //     if (sel == 2'b00) mux_out = a;
    //     else if (sel == 2'b01) mux_out = b;
    //     else if (sel == 2'b10) mux_out = c;
    //     else if (sel == 2'b11) mux_out = d;
    //     else mux_out = 4'bx;       
    // end
 
 //case
    always @(*) begin
        case (sel)
            2'b00: mux_out = a; 
            2'b01: mux_out = b; 
            2'b10: mux_out = c; 
            2'b11: mux_out = d; 
            default: mux_out = 4'bx;
        endcase     
    end


endmodule
