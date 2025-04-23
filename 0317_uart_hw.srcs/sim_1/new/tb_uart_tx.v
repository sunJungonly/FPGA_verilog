`timescale 1ns / 1ps

module tb_uart_tx();
    reg clk;
    reg rst;
    reg rx;
    wire w_tick, w_rx_done;
    wire [7:0] rx_data;

    //reg btn_start;
    //reg tx_start_trig;
    //wire tx;
    // reg [7:0] tx_din;
    //wire tx_dout;
    
    // send_tx_btn dut(
    //     .clk(clk),
    //     .rst(rst),
    //     .btn_start(tx_start_trig),
    //     .tx(tx_dout)
    // );

    baud_tick_gen U_BAUD_Tick (
        .clk(clk),
        .rst(rst),
        .baud_tick(w_tick) 
    );

    uart_rx DUT_rx (
        .clk(clk),
        .rst(rst),
        .tick(w_tick),
        .rx(rx),
        .rx_done(w_rx_done),
        .rx_data(rx_data)
    );


    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        rx = 1;
        #10;
        rst = 0;
        #100;
        rx = 0;    // start
        #104160; // 9600 1bit
        
        rx = 1;    // data 0
        #104160; // 9600 1bit
        
        rx = 0;    // data 1
        #104160; // 9600 1bit
        
        rx = 0;    // data 2
        #104160; // 9600 1bit
        
        rx = 0;    // data 3
        #104160; // 9600 1bit
        
        rx = 0;    // data 4
        #104160; // 9600 1bit
        
        rx = 1;    // data 5
        #104160; // 9600 1bit
        
        rx = 0;    // data 6
        #104160; // 9600 1bit
        
        rx = 0;    // data 7
        #104160; // 9600 1bit
        rx = 1;    // stop

        #10000;
        $stop;

        // tx_start_trig = 1'b0;

        // #20 rst = 1'b0;
        // #200 tx_start_trig = 1'b1;
        // #50000 tx_start_trig = 1'b0;
        // #17000000 tx_start_trig = 1'b1;
        // #50000 tx_start_trig = 1'b0;
        // #1100000 $stop;

    end
    
endmodule
