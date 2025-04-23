`timescale 1ns / 1ps

module tb_stopwatch( );
    
    reg clk, reset, run, clear;
    wire [6:0] msec, sec, min;
    wire [4:0] hour;
    // wire o_clk;
   
    stopwatch_dp DUT(
    .clk(clk),
    .reset(reset),
    .run(run),
    .clear(clear),
    .msec(msec),
    .sec(sec),
    .min(min),
    .hour(hour)
    );

    // clk_div_100 DUT (
    //     .clk(clk),
    //     .reset(reset),
    //     .run(run),
    //     .clear(clear),
    //     .o_clk(o_clk)
    // );

    always #5 clk = ~clk; // clk 생성

    initial begin
        //초기화
        clk = 0; 
        reset = 1; 
        run = 0; 
        clear = 0;
        
        //10나노 뒤에 run = 1 활성화
        #10;
        reset = 0;
        run = 1;
        wait ( sec == 2 ); //2초 대기

        // #2000000;
        // #10; 
        // run = 0; 
    end

endmodule
