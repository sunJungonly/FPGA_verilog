`timescale 1ns / 1ps

module tb_dht_io_input();
    reg clk;
    reg rst;
    reg btn_start;
    reg tick;

    reg dht_sensor_data;  // dht_sensor_data는 실제 입력값을 설정할 변수
    reg io_oe;            // io_oe는 출력/입력 모드를 제어하는 변수
    wire dht_io;          // dht_io는 inout 신호

    wire [3:0] led;

    // dht_io를 io_oe에 따라 출력 또는 입력으로 설정
    assign dht_io = (io_oe) ? dht_sensor_data : 1'bz;  // io_oe가 1이면 dht_sensor_data를 출력, 0이면 high-impedance (입력)

    top_dht11 dut (
        .clk(clk),
        .rst(rst),
        .btn_start(btn_start),
        .led(led),
        .dht_io(dht_io)  // dht_io는 inout으로 연결됨
    );

    always #5 clk = ~clk;

    integer i;
    initial begin
        // 초기화
        clk = 0;
        rst = 1;
        io_oe = 0;  // 처음에는 입력 모드로 설정
        btn_start = 0;

        #100;
        rst = 0;
        #100;
        btn_start = 1;
        #100;
        btn_start = 0;
        #1000;

        #180000;

        // **입력 모드일 때 임의 값 넣기**
        // #30000;
        io_oe = 1; 
        // DUT가 dht_io 값을 읽을 수 있도록, dht_sensor_data 값을 변경하여 전달
        dht_sensor_data = 1'b0;  // dht_io에 0 값을 입력 //state3
        #80000;  // DUT가 이 값을 읽을 수 있도록 대기

        dht_sensor_data = 1'b1;  // dht_io에 1 값을 입력 //state 4
        #80000;  // DUT가 이 값을 읽을 수 있도록 대기

        dht_sensor_data = 1'b0;  // dht_io에 0 값을 입력 //state5
        #50000;  // DUT가 이 값을 읽을 수 있도록 대기

        // 반복적으로 값을 넣어서 DUT가 이를 읽게 합니다
        for (i = 0; i < 5; i = i + 1) begin
            dht_sensor_data = (i % 2) ? 1'b0 : 1'b1;  // 0과 1을 반복하여 입력
            #50000;  // DUT가 이 값을 읽을 수 있도록 대기
        end

        $stop;
    end
endmodule
