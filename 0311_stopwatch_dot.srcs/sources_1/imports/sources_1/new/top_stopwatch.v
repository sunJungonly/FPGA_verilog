`timescale 1ns / 1ps
module top_stopwatch(
    input clk,
    input reset,
    input btn_run,
    input btn_clear,
    input sw_mode,
    output [3:0]fnd_comm,
    output [7:0] fnd_font
);

    wire w_run, w_clear, run, clear; //반드시 선언 해주자
    wire [6:0] msec; 
    wire [5:0] sec, min;
    wire [4:0] hour;

    stopwatch_dp U_stopwatch_DP(
    .clk(clk),
    .reset(reset),
    .run(run),
    .clear(clear),
    .msec(msec),
    .sec(sec),
    .min(min),
    .hour(hour)
    );
    
    btn_debounce U_Btn_DB_RUN(
    .clk(clk),
    .reset(reset),
    .i_btn(btn_run),
    .o_btn(w_run)
    );

    btn_debounce U_Btn_DB_CLEAR(
    .clk(clk),
    .reset(reset),
    .i_btn(btn_clear),
    .o_btn(w_clear)
    );

    stopwatch_cu U_stopwatch_cu(
    .clk(clk),
    .reset(reset),
    .i_btn_run(w_run),
    .i_btn_clear(w_clear),
    .o_run(run),
    .o_clear(clear)
    );

    fnd_controller U_fnd_controller(
    .clk(clk),
    .reset(reset),
    .sw_mode(sw_mode),
    .msec(msec), // wire가 아니라 msec?
    .sec(sec),
    .min(min),
    .hour(hour),
    .fnd_font(fnd_font),
    .fnd_comm(fnd_comm)
);

endmodule
