`timescale 1ns / 1ps

module TOP_sensor(
    input clk,
    input rst,
    input btn_start,
    input [1:0] sw_mode,
    output [3:0] led,
    inout dht_io,
    output [7:0] seg,
    output [3:0] seg_comm
    );

    wire [15:0] o_bcd;

    top_dht11 U_DHT11 (
    .clk(clk),
    .rst(rst),
    .btn_start(btn_start),
    .sw_mode(sw_mode),
    .led(led),
    .dht_io(dht_io),
    .o_bcd(o_bcd)
    );

    fnd U_FND (
        .clk(clk),
        .reset(rst),
        .bcd(o_bcd),
        //.sw_mode(sw_mode),
        .seg(seg),
        .seg_comm(seg_comm)
    );
endmodule
