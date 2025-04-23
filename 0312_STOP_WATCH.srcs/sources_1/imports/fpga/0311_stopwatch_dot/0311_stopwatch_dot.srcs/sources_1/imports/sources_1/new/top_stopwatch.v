`timescale 1ns / 1ps
module top_stopwatch(
    input clk,
    input reset,
    input btn_run,
    input btn_clear,
    input btn_sec,
    input btn_min,
    input [1:0] sw_mode,
    output [3:0]fnd_comm,
    output [7:0] fnd_font,
    output [3:0] led

);

    wire w_run, w_clear, run, clear, w_sec, w_min; //반드시 선언 해주자
    wire o_hour, o_min, o_sec;
    wire [6:0] msec, msec0, msec1 ; //msec0: SW, msec1: W 
    wire [5:0] sec, sec0, sec1;
    wire [5:0] min, min0, min1;
    wire [4:0] hour, hour0, hour1;

    wire [23:0] w_comb;
    wire [23:0] y;
    wire [23:0] x_st;
    wire [23:0] x_cl;
    wire [23:0] w_split;

    led U_Led_sw(
    .sw_mode(sw_mode), 
    .led(led) 
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

    btn_debounce U_Btn_DB_sec(
    .clk(clk),
    .reset(reset),
    .i_btn(btn_sec),
    .o_btn(w_sec)
    );

    btn_debounce U_Btn_DB_min(
    .clk(clk),
    .reset(reset),
    .i_btn(btn_min),
    .o_btn(w_min)
    );

    stopwatch_cu U_stopwatch_cu(
    .clk(clk),
    .reset(reset),
    .i_btn_run(w_run),
    .i_btn_clear(w_clear),
    .o_run(run),
    .o_clear(clear)
    );

    stopwatch_dp U_stopwatch_DP(
    .clk(clk),
    .reset(reset),
    .run(run),
    .clear(clear),
    .msec(msec0),
    .sec(sec0),
    .min(min0),
    .hour(hour0)
    );

    clock_cu U_CLK_cu(
    .clk(clk),
    .reset(reset),
    .i_hour(w_run),
    .i_min(w_min),
    .i_sec(w_sec),
    .o_hour(o_hour),
    .o_min(o_min),
    .o_sec(o_sec)
    );
    
    clk_dp U_CLk_dp(
    .clk(clk),
    .reset(reset),
    .in_hour(o_hour),
    .in_min(o_min),
    .in_sec(o_sec),
    .msec(msec1),
    .sec(sec1),
    .min(min1),
    .hour(hour1)
    );


    wwire_combiner U_Wire_Combiner_ST (
    .msec(msec0),
    .sec(sec0),
    .min(min0),
    .hour(hour0),
    .w_comb(x_st)
    );

    wwire_combiner U_Wire_Combiner_CL(
    .msec(msec1),
    .sec(sec1),
    .min(min1),
    .hour(hour1),
    .w_comb(x_cl)
    );

    mux_2x1_sw1 U_Mux_2x1_sw1(
    .sw_mode(sw_mode[1]),
    .x_st(x_st),
    .x_cl(x_cl),
    .y(y)
    );

    wwire_splitter U_Wire_Split (
    .w_split(y),
    .msec(msec),
    .sec(sec),
    .min(min),
    .hour(hour)    
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


module clock_cu (
    input clk,
    input reset,
    input i_hour,
    input i_min,
    input i_sec,
    output reg o_hour,
    output reg o_min,
    output reg o_sec
);
    // fsm 구조  CU 설계
    parameter IDLE = 2'b00, HOUR = 2'b01, MIN = 2'b10, SEC = 2'b11;
    reg [1:0] state, next;
    // state register
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next;
        end
    end
    // next
    always @(*) begin
        next = state;
        case (state)
            IDLE: begin
                if (i_hour == 1) begin
                    next = HOUR;
                end 
                else if (i_min == 1) begin
                    next = MIN;
                end
                else if (i_sec == 1) begin
                    next = SEC;
                end
                // else next = state;
            end
            HOUR: begin
                if (i_hour == 0) begin
                    next = IDLE;
                end
                else if (i_min == 1) begin
                    next = MIN;
                end
                else if (i_sec == 1) begin
                    next = SEC;
                end
            end
            MIN: begin
                if (i_hour == 1) begin
                    next = HOUR;
                end
                else if (i_min == 0) begin
                    next = IDLE;
                end
                else if (i_sec == 1) begin
                    next = SEC;
                end
            end
            SEC: begin
                if (i_hour == 1) begin
                    next = HOUR;
                end
                else if (i_min == 1) begin
                    next = MIN;
                end
                else if (i_sec == 0) begin
                    next = IDLE;
                end
            end

        endcase
    end
    //output
    always @(*) begin
        o_hour = 1'b0;
        o_min = 1'b0;
        o_sec = 1'b0;
        case (state)
            IDLE: begin
                o_hour = 1'b0;
                o_min = 1'b0;
                o_sec = 1'b0;
            end 

            HOUR: begin
                o_hour = 1'b1;
                o_min = 1'b0;
                o_sec = 1'b0;
            end

            MIN: begin
                o_hour = 1'b0;
                o_min = 1'b1;
                o_sec = 1'b0;
            end

            SEC: begin
                o_hour = 1'b0;
                o_min = 1'b0;
                o_sec = 1'b1;
            end
        endcase
    end
endmodule

module wwire_combiner (
    input [6:0] msec,
    input [5:0] sec,
    input [5:0] min,
    input [4:0] hour,
    output [23:0] w_comb
);
    assign w_comb = {hour, min, sec, msec};

endmodule

// module wire_combiner_cl (
//     input [6:0] msec,
//     input [5:0] sec,
//     input [5:0] min,
//     input [4:0] hour,
//     output [23:0] w_comb
// );
//     assign w_comb = {hour, min, sec, msec};

// endmodule

//MUX 2x1
module mux_2x1_sw1 (
    input sw_mode,
    input [23:0] x_st,
    input [23:0] x_cl,
    output reg [23:0] y
);
    always @(*) begin
        case (sw_mode)
            1'b0: y = x_st; 
            1'b1: y = x_cl; 

            default: y = x_st;
        endcase
    end
    
endmodule

module wwire_splitter (
    input [23:0] w_split,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour    
);
    assign hour = w_split [23:19];
    assign min = w_split[18:13];
    assign sec = w_split[12:7];
    assign msec = w_split [6:0];

endmodule

module led (
    input [1:0] sw_mode, // 스위치 2개 쓰니까 2비트트
    output reg [3:0] led //led가 4개 켜지니까 4비트
);
    always @(*) begin
        case (sw_mode)
            2'b00 : led = 4'b0001;
            2'b01 : led = 4'b0010;

            2'b10 : led = 4'b0100;
            2'b11 : led = 4'b1000;
                default: led = 4'b0001;
        endcase
    end

endmodule