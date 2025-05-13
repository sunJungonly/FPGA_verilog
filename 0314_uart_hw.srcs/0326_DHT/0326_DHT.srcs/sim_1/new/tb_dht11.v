`timescale 1ns / 1ps

module tb_dht11( );

    reg clk;
    reg rst;
    reg btn_start;
    reg tick;

    reg dht_sensor_data;
    reg io_oe;

    wire [3:0]led;
    wire dht_io;

    // tb io mode 변환
    assign dht_io = (io_oe) ? dht_sensor_data : 1'bz;

    top_dht11 dut (
    .clk(clk),
    .rst(rst),
    .btn_start(btn_start),
    .led(led),
    .dht_io(dht_io)
    );

always #5 clk = ~clk;

integer i;
initial begin
    clk = 0;
    rst = 1;
    io_oe = 0;
    btn_start = 0;

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
    // io_oe = 1;
    // #50000;
    // io_oe = 0;
    // #40000;
    end
    io_oe = 0;
    #50000;

    $stop;
end

endmodule
