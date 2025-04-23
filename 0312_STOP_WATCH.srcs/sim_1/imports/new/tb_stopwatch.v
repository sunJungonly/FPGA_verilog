`timescale 1ns / 1ps

module tb_stopwatch( );
    
    reg clk, reset, run, clear, sw_mode;
    wire [6:0] msec;
    wire [5:0] sec, min;
    wire [4:0] hour;
    wire [7:0] fnd_font;
    wire [3:0] fnd_comm;
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

    fnd_controller DUT0 (
    .clk(clk),
    .reset(reset),
    .sw_mode(sw_mode),
    .msec(msec),
    .sec(sec),
    .min(min),
    .hour(hour),
    .fnd_font(fnd_font),
    .fnd_comm(fnd_comm)
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
        sw_mode = 0;
        
        //10나노 뒤에 run = 1 활성화
        #10;
        reset = 0;
        run = 1;
        wait ( sec == 2 ); //2시간 대기
        
        
        // wait ( hour == 1 ); //2시간 대기
        #10; 
        run = 0; // stop
        repeat(4) @(posedge clk);  // 4번 반복, posedge clk 을 4번 반복
        clear = 1;
        // #100;
    // $stop;
    end

endmodule
