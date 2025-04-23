`timescale 1ns / 1ps

module Ascii_to_SegDecoder(
    input clk,
    input rst,
    input rx,
    output tx,
    output [7:0] seg,
    output [3:0] seg_comm
);

    wire w_rx_done;
    wire [7:0] w_rx_data;

    fnd_controller U_fnd(
        .clk(clk),
        .reset(rst),
        .rx_data(w_rx_data),
        .seg(seg),
        .seg_comm(seg_comm)
    );


    top_uart U_UART (
        .clk(clk),
        .rst(rst),
        .btn_start(w_rx_done),
        .tx_data_in(),
        .tx_done(),
        .tx(tx),
        .rx(rx),
        .rx_done(w_rx_done),
        .rx_data(w_rx_data)
    );
 
endmodule

