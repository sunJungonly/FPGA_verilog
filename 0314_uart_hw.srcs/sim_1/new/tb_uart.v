`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/14 12:31:18
// Design Name: 
// Module Name: tb_uart
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


module tb_uart( );
    reg clk;
    reg rst;
    reg tx_start_trig;
    reg [7:0] tx_din;
    wire tx_dout;
    // wire tx_done;

/*/

    UART_controller UART_Dut (
        .clk(clk),
        .rst(rst),
        .tx_start_trigger(tx_start_trig),
        .tx_data(tx_din),
        .tx_o(tx_dout),
        .tx_done(tx_done)

*/

uart dut(
    .clk(clk),
    .rst(rst),
    .btn_start(tx_start_trig),
    .tx(tx_out)

);

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        tx_din = 8'b01010101;
        tx_start_trig = 1'b0;

        #20 rst = 1'b0;
        #20 tx_start_trig = 1'b1;
        #20 tx_start_trig = 1'b0;
    end
endmodule
