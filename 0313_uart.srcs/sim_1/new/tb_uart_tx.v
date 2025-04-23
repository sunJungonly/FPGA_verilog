`timescale 1ns / 1ps

module tb_uart_tx();
    reg clk;
    reg rst;
    reg tx_start_trig;
    reg [7:0] tx_din;
    wire tx_dout;
    wire tx_done;
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

    top_uart dut(
        .clk(clk),
        .rst(rst),
        .btn_start(tx_start_trig),
        .tx_done(tx_done),
        .tx(tx_dout)

    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        // tx_din = 8'b01010101;
        tx_start_trig = 1'b0;

        #20 rst = 1'b0;
        #20 tx_start_trig = 1'b1;
        #20 tx_start_trig = 1'b0;
        
        
        #20 tx_start_trig = 1'b1;
        #20 tx_start_trig = 1'b0;
    end
    
endmodule
