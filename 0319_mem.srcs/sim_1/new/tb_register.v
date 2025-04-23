`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 10:39:54
// Design Name: 
// Module Name: tb_register
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


module tb_register();

    reg clk;
    reg [31:0] d;
    // reg [3:0] addr,
    wire [31:0] q;

    register dut(
        .clk(clk),
        .d(d),
        // .addr(addr),
        .q(q)
    );

    //Clock gen
    always #5 clk =~clk;


    initial begin
        
        clk = 0;
        d = 32'h0000_0000;

        #10;
        d = 32'h0123_abcd;
        #10;
        
        @(posedge clk);
        if (d == q) begin
            $display("pass");
        end else begin
            $display("fail");
        end

        @(posedge clk);
        $stop;
        
        end

endmodule
