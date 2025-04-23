`timescale 1ns / 1ps

module top_dht11(
    input clk,
    input rst,
    input btn_start,
    input [1:0] sw_mode,
    output [3:0] led,
    inout dht_io,
    output [15:0] o_bcd
    );

    wire tick_1usec;
    wire [15:0] humidity;
    wire [15:0] temperature;

    tick_gen_1usec U_Tick_1usec(
    .clk(clk),
    .rst(rst),
    .tick_1usec(tick_1usec)
    );

    dht11_ctrl U_Controller (
    .clk(clk),
    .rst(rst),
    .start(btn_start),
    .tick(tick_1usec),
    .led_m(led),
    .humidity(humidity),
    .temperature(temperature),
    .dht_io(dht_io)
    );

    mux_2X1 U_MUX_2x1(
    .sel(sw_mode),
    .digit_1(humidity),
    .digit_100(temperature),
    .o_bcd(o_bcd)
    );

endmodule
