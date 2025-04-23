`timescale 1ns / 1ps

module tb_uart_sw_cl();


    reg clk;
    reg reset;
    reg btn_run;
    reg btn_clear;
    reg btn_sec;
    reg btn_min;
    reg rx;
    reg [1:0] sw_mode;
    wire tx;
    wire [3:0] fnd_comm;
    wire [7:0] fnd_font;
    wire [3:0] led;

    wire w_rx_done;
    wire [7:0] w_rx_data;
    wire [7:0] fifo_rx_rdata;
    wire [7:0] fifo_tx_rdata;
    wire fifo_tx_empty, fifo_tx_full, fifo_rx_empty;
    wire tx_done;


    top_uart U_UART (
    .clk(clk),
    .rst(reset),
    .btn_start(~fifo_tx_empty),
    .tx_data_in(fifo_tx_rdata),
    .tx_done(tx_done),
    .tx(tx),
    .rx(rx),
    .rx_done(w_rx_done),
    .rx_data(w_rx_data)
    );

    fifo U_Fifo_RX(
    .clk(clk),
    .reset(reset),
    // write
    .wdata(w_rx_data),
    .wr(w_rx_done),
    .full(),
    // read
    .rd(~fifo_tx_full),
    .rdata(fifo_rx_rdata),
    .empty(fifo_rx_empty)
    );

    fifo U_Fifo_TX(
    .clk(clk),
    .reset(reset),
    // write
    .wdata(fifo_rx_rdata),
    .wr(~fifo_rx_empty),
    .full(fifo_tx_full),
    // read
    .rd(~tx_done), //.rd(~tx_done & ~fifo_tx_empty),
    .rdata(fifo_tx_rdata),
    .empty(fifo_tx_empty)
    );

    top_stopwatch U_SW_CL (
    .clk(clk),
    .reset(reset),
    .btn_run(btn_run),
    .btn_clear(btn_clear),
    .btn_sec(btn_sec),
    .btn_min(btn_min),
    .fifo_rx_rdata(fifo_rx_rdata),
    .fifo_rx_empty(fifo_rx_empty),
    .fifo_rd_en(~fifo_tx_full),
    .sw_mode(sw_mode),
    .fnd_comm(fnd_comm),
    .fnd_font(fnd_font),
    .led(led)
    );

    always #5 clk = ~clk;

    integer j = 0 ;
    //Test sequence using tasks
    initial begin
        clk = 0;
        reset = 1;   // Reset 활성화
        rx = 1;    //RX 라인을 기본값으로 설정

        #50 
        reset = 0;  //Reset 비활성화 후 테스트 시작
        #10000;

        //수신
        // send_data(8'h68); // 데이터 'r' 0x72송신
        // //wait_for_rx();    //수신 완료 대기 및 데이터 확인
        // #10; //#10000;

        repeat (15) begin
            send_data(8'h68);
            #10; // 각 비트 전송 시간 지연
        end
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

// FIFO 상태 모니터링
always @(posedge clk) begin
    // FIFO가 가득 찼을 때 (full 상태)
    if (fifo_tx_full) begin
        $display("FIFO is full at time %t", $time);
    end
    // FIFO가 비어있을 때 (empty 상태)
    if (fifo_tx_empty) begin
        $display("FIFO is empty at time %t", $time);
    end
end

endmodule
