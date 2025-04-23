`timescale 1ns / 1ps

module Uart_fifo_SW_CL(
    input clk,
    input reset,
    input btn_run,
    input btn_clear,
    input btn_sec,
    input btn_min,
    input rx,
    output tx,
    input [1:0] sw_mode,
    output [3:0] fnd_comm,
    output [7:0] fnd_font,
    output [3:0] led
    );

    wire w_rx_done;
    wire [7:0] w_rx_data;
    wire [7:0] fifo_rx_rdata;
    wire [7:0] fifo_tx_rdata;
    wire fifo_tx_empty, fifo_tx_full, fifo_rx_empty;
    wire tx_done;


    top_uart U_UART (
    .clk(clk),
    .rst(reset),
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
    .reset(reset),
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
    .reset(reset),
    // write
    .wdata(fifo_rx_rdata),
    .wr(~fifo_rx_empty),
    .full(fifo_tx_full),
    // read
    .rd(~tx_done), //.rd(~tx_done & ~fifo_tx_empty),
    .rdata(fifo_tx_rdata),
    .empty(fifo_tx_empty)
    );

    top_stopwatch U_SW_CL (
    .clk(clk),
    .reset(reset),
    .btn_run(btn_run),
    .btn_clear(btn_clear),
    .btn_sec(btn_sec),
    .btn_min(btn_min),
    .fifo_rx_rdata(fifo_rx_rdata),
    .sw_mode(sw_mode),
    .fnd_comm(fnd_comm),
    .fnd_font(fnd_font),
    .led(led)
    );



//  ila_0 U_ILA (
// clk,
// probe0,
// probe1
// );

endmodule
