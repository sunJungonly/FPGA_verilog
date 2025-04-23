`timescale 1ns / 1ps

module tb_uart_fifo();

    reg clk;
    reg rst;
    reg rx;
    wire tx;

    wire w_rx_done;
    wire [7:0] w_rx_data;
    wire [7:0] fifo_rx_rdata;
    wire [7:0] fifo_tx_rdata;
    wire fifo_tx_empty, fifo_tx_full, fifo_rx_empty;
    wire tx_done;
    //wire w_rd;


    top_uart U_UART (
    .clk(clk),
    .rst(rst),
    .btn_start(~fifo_tx_empty),
    .tx_data_in(fifo_tx_rdata),
    .tx_done(tx_done),
    .tx(tx),
    .rx(rx),
    .rx_done(w_rx_done),
    .rx_data(w_rx_data)
    );

    fifo U_Fifo_RX(
    .clk(clk),
    .reset(rst),
    // write
    .wdata(w_rx_data),
    .wr(w_rx_done),
    .full(),
    // read
    .rd(~fifo_tx_full),
    .rdata(fifo_rx_rdata),
    .empty(fifo_rx_empty)
    );

    fifo U_Fifo_TX(
    .clk(clk),
    .reset(rst),
    // write
    .wdata(fifo_rx_rdata),
    .wr(~fifo_rx_empty),
    .full(fifo_tx_full),
    // read
    .rd(~tx_done),
    .rdata(fifo_tx_rdata),
    .empty(fifo_tx_empty)
    );
    always #5 clk = ~clk;


    initial begin
        clk = 0;
        rst = 1;
        rx = 1; 

        #50;
        rst = 0;
        #50;

        #104170;
        rx = 0; //start
        
        #104170;
        rx = 1; // DATA 0100 1111 = 79

        #104170;
        rx = 1;
        
        #104170;
        rx = 1; 
        
        #104170;
        rx = 1;
        
        #104170;
        rx = 0; 
        
        #104170;
        rx = 0;
        
        #104170;
        rx = 1; 
        
        #104170;
        rx = 0;

        #104170;
        rx = 1; //stop
    end
endmodule