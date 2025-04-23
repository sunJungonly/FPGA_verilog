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

    wire [7:0] o_rdata;
    wire w_rx_done;
    wire [7:0] w_rx_data;
    wire [7:0] rx_done_data;
    wire [7:0] fifo_rx_rdata;
    wire [7:0] fifo_tx_rdata;
    wire u_run, u_clear, u_hour, u_min, u_sec;
    //wire fifo_tx_empty, fifo_tx_full, fifo_rx_empty;
    //wire tx_done;
    wire fifo_empty, fifo_full, rx_rd;

    TOP_uart_fifo U_Uart_Fifo(
        .clk(clk),
        .rst(reset),
        .rx(rx),
        .tx(tx),
        .o_rdata(o_rdata),
        //.rx_done(w_rx_done)
        .fifo_empty(fifo_empty),
        .rx_rd(rx_rd)
    );

    // rx_done_data U_rx_done_data(
    // .clk(clk),
    // .rst(reset),
    // .rx_done(w_rx_done),
    // .fifo_rx_rdata(o_rdata),
    // .rx_done_data(rx_done_data)
    // );

    uart_CU U_Uart_cu(
    .clk(clk),
    .rst(reset),
    .rdata(o_rdata),//.rdata(rx_done_data),
    .fifo_empty(fifo_empty),
    .rd(rx_rd),
    .u_run(u_run),
    .u_clear(u_clear),
    .u_hour(u_hour),
    .u_min(u_min),
    .u_sec(u_sec)
    );

    top_stopwatch U_SW_CL (
        .clk(clk),
        .reset(reset),
        .btn_run(btn_run),
        .btn_clear(btn_clear),
        .btn_sec(btn_sec),
        .btn_min(btn_min),
        .o_rdata(),
        .u_run(u_run),
        .u_clear(u_clear),
        .u_hour(u_hour),
        .u_min(u_min),
        .u_sec(u_sec),

        .sw_mode(sw_mode),
        .fnd_comm(fnd_comm),
        .fnd_font(fnd_font),
        .led(led)
    );

endmodule

module uart_CU (
  input clk,
  input rst,
  input [7:0] rdata,
  input fifo_empty,
  output reg rd,
  output reg u_run,
  output reg u_clear,
  output reg u_hour,
  output reg u_min,
  output reg u_sec
);



    // fsm 구조  CU 설계
    parameter IDLE = 3'b000, RUN = 3'b100, CLEAR = 3'b101,
              HOUR = 3'b001, MIN = 3'b010, SEC = 3'b011;
              
    reg [2:0] state, next;

    // state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= IDLE;
            rd <= 0;
        end else begin
            state <= next;

        // rd 신호 유지: 데이터 읽기 동안 1을 유지
        if (!fifo_empty && state == IDLE) begin
            rd <= 1; // FIFO에 데이터가 있으면 읽기 요청
        end else begin
            rd <= 0; // 데이터 읽기 후 rd를 0으로 리셋
        end
        end
    end

    // next 상태 결정정
   always @(*) begin
        next = state;  // 기본적으로 현재 상태 유지
        
        case (state)
            IDLE: begin
                if (!fifo_empty) begin
                    case (rdata)
                        "r": next = RUN;
                        "c": next = CLEAR;
                        "h": next = HOUR;
                        "m": next = MIN;
                        "s": next = SEC;
                        default: next = IDLE;
                    endcase
                end
            end
        RUN: begin
            case (rdata)
                "r": next = RUN;
                default: next = IDLE;
            endcase
        end

        CLEAR: begin
            case (rdata)
                "c": next = CLEAR;
                default: next = IDLE;
            endcase
        end

        HOUR: begin
            case (rdata)
                "h": next = HOUR;
                default: next = IDLE;
            endcase
        end

        MIN: begin
            case (rdata)
                "m": next = MIN;
                default: next = IDLE;
            endcase
        end

        SEC: begin
            case (rdata)
                "s": next = SEC;
                default: next = IDLE;
            endcase
        end
    endcase
end
    //         RUN:   if (rdata != "r") next = IDLE;
    //         CLEAR: if (rdata != "c") next = IDLE;
    //         HOUR:  if (rdata != "h") next = IDLE;
    //         MIN:   if (rdata != "m") next = IDLE;
    //         SEC:   if (rdata != "s") next = IDLE;
    //     endcase
    // end

    // 출력 신호 설정
    always @(*) begin
        u_run   = (state == RUN);
        u_clear = (state == CLEAR);
        u_hour  = (state == HOUR);
        u_min   = (state == MIN);
        u_sec   = (state == SEC);
    end

endmodule


