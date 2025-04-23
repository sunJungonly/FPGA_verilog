`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 16:34:32
// Design Name: 
// Module Name: tb_fifo
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


module tb_fifo();

    reg clk;
    reg reset;
    reg [7:0] wdata;
    reg wr;
    reg rd;
    wire [7:0] rdata;
    wire empty;
    wire full;

fifo dut(
    .clk(clk),
    .reset(reset),
    .wdata(wdata),
    .wr(wr),
    .full(full),
    .rd(rd),
    .rdata(rdata),
    .empty(empty)
    );

    always #5 clk = ~clk;
    integer i;
    initial begin
        clk = 0 ;
        reset = 1;
        wdata = 0;
        wr = 0;
        rd = 0;
        #10;
        reset = 0;
        #10;
        wr = 1;
        for (i = 0; i < 33; i = i +1) begin
            #10;
            wdata = 8'haa + i;  
        end
        // #10;
        // wdata = 8'haa;
        // #10;
        // wdata = 8'h55;
        #10;
        wr = 0;
        rd = 1;
        #20;
        $stop;


    end

endmodule
