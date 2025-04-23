`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/20 12:41:49
// Design Name: 
// Module Name: tb_uart_loopback
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_uart_loopback();

    reg clk;
    reg rst;
    reg rx;
    wire tx;
    
TOP_uart_fifo DUT (
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .tx(tx)
);

//  clock 생성성
always #5 clk=~clk;
integer i = 0 ;
//Test sequence using tasks
initial begin
    clk = 0;
    rst = 1;   // Reset 활성화
    rx = 1;    //RX 라인을 기본값으로 설정

    #50 rst = 0;  //Reset 비활성화 후 테스트 시작
    #10000;

    //수신
    send_data(8'h72); // 데이터 'r' 0x72송신
    //wait_for_rx();    //수신 완료 대기 및 데이터 확인
    #10; //#10000;

    // wait_for_rx();
    // for (i = 0; i < 20; i = i + 1) begin
        
    // // wait(tx_done);   
    // // wait(!tx_done);  
    // send_data(8'h30 + i); //데이터 'r' 0x72송신신
   
    // end
    // wait(tx);   
    // wait(!tx);

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

