`timescale 1ns / 1ps

module tb_uart_sw_cl();

    reg clk;
    reg reset;
    reg rx;
    reg [1:0] sw_mode;
    wire tx;

    wire w_rx_done;
    wire [7:0] fifo_rx_rdata;
    wire [7:0] rx_done_data;

    TOP_uart_fifo U_Uart_Fifo(
    .clk(clk),
    .rst(reset),
    .rx(rx),
    .tx(tx),
    .o_rdata(fifo_rx_rdata),
    .rx_done(w_rx_done)
    );

    rx_done_data U_rx_done_data(
    .clk(clk),
    .rst(reset),
    .rx_done(w_rx_done),
    .fifo_rx_rdata(fifo_rx_rdata),
    .rx_done_data(rx_done_data)
    );

    uart_CU U_Uart_cu(
    .clk(clk),
    .rst(rst),
    .rdata(rx_done_data),
    .u_run(u_run),
    .u_clear(u_clear),
    .u_hour(u_hour),
    .u_min(u_min),
    .u_sec(u_sec)
    );


    always #5 clk = ~clk;

    //Test sequence using tasks
    initial begin
        clk = 0;
        reset = 1;   // Reset 활성화
        rx = 1;    //RX 라인을 기본값으로 설정

        #50 
        reset = 0;  //Reset 비활성화 후 테스트 시작
        #10000;

        send_data("r");
        send_data("c");
        send_data("h");
        send_data("m");
        send_data("s");
        send_data("r");
        send_data("c");
        send_data("h");
        send_data("m");
        send_data("s");
        send_data("r");
        send_data("c");
        send_data("h");
        send_data("m");
        send_data("s");
        send_data("r");
        send_data("c");
        send_data("h");
        send_data("m");
        send_data("s");

        $stop;
    end

    // Task: 데이터 송신 시뮬레이션 (TX -> RX Loopback)
    task send_data(input [7:0] data);
        integer i;
        begin
            $display("Sending data: %h", data);

            // Start bit (Low)
            rx = 0;
            #(10 * 10417);  // Baud rate에 따른 시간 지연 (9600bps 기준)

            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #(10 * 10417); // 각 비트 전송 시간 지연
            end

            // Stop bit (High)
            rx = 1;
            #(10 * 10417);  // 정지 비트 시간 지연

            $display("Data sent: %h", data);
        end
    endtask


endmodule
