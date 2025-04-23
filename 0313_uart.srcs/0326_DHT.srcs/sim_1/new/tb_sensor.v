`timescale 1ns / 1ps

module tb_sensor();

    reg clk;
    reg rst;
    reg btn_start;
    reg [1:0] sw_mode;

    wire [3:0] led;
    wire dht_io;
    wire [7:0] seg;
    wire [3:0] seg_com;

    reg dht_sensor_data;
    reg io_oe;

    assign dht_io = (io_oe) ? dht_sensor_data : 1'bz;

    TOP_sensor dut(
    .clk(clk),
    .rst(rst),
    .btn_start(btn_start),
    .sw_mode(sw_mode),
    .led(led),
    .dht_io(dht_io),
    .seg(seg),
    .seg_comm(seg_comm)
    );

    always #5 clk = ~clk;

    integer i;
    initial begin
    clk = 0;
    rst = 1;
    btn_start = 0;
    sw_mode = 0;

    #100;
    rst = 0;
    #100;
    btn_start = 1;
    #100
    btn_start = 0;
    #1000;
    // 18msec 대기
    wait(dht_io);
    #30000;
    
    //입력 모드로 변환
    io_oe = 1;
    dht_sensor_data= 1'b0;
    #80000;
    dht_sensor_data= 1'b1;
    #80000;
    dht_sensor_data= 1'b0;
    #50000;
    
    for (i = 0; i < 41; i = i + 1) begin
    dht_sensor_data= 1'b0;
    #50000;
    dht_sensor_data= 1'b1;
    #40000;
    end
    io_oe = 0;
    #50000;

    $stop;
    end

endmodule
