`timescale 1ns / 1ps

module rx_done_data(
    input clk,
    input rst,
    input rx_done,
    input [7:0] fifo_rx_rdata,
    output [7:0] rx_done_data  // rx_done_data를 reg로 선언
);

    reg rx_tick_data;

    always @(posedge clk) begin
        if (rst) begin
            rx_tick_data <= 0;
        end
        else begin
            rx_tick_data <= rx_done;
        end
    end

    assign rx_done_data = (rx_tick_data) ? fifo_rx_rdata : 8'h0 ;

endmodule
