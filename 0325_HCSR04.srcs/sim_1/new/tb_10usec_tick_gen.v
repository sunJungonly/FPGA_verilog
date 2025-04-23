`timescale 1ns / 1ps

module tb_10usec_tick_gen();

    reg clk;
    reg rst;
    reg btn_start;
    reg echo;

    wire trigger;
    wire [7:0] seg;
    wire [3:0] seg_comm;

    us_ctrl DUT(
        .clk(clk),
        .rst(rst),
        .btn_start(btn_start),
        .echo(echo),
        .trigger(trigger),
        .seg(seg),
        .seg_comm(seg_comm)
    );

    always #5 clk = ~clk;


    initial begin
        clk = 0;
        rst = 1;
        btn_start = 0;
        echo = 0;

        #50;
        rst = 0;
        #50;

        btn_start = 1;
        #10;
        btn_start = 0;
        #10;

        #150000;
        echo = 1;
    #1_000_000;
        echo = 0;
        #10;
        // btn_start = 0;
        // #50
        // btn_start = 1;
        // #50
        // btn_start = 1;
        // #50
        // btn_start = 1;
        // #50
        // btn_start = 0;
        // #50
        // btn_start = 1;
        // #50
        // btn_start = 1;
        // #50
        $stop;
    end
endmodule

