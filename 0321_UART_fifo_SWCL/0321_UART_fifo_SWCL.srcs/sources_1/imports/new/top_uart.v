`timescale 1ns / 1ps

module TOP_uart_fifo (
    input clk,
    input rst,
    input rx,
    output tx,
    output [7:0] o_rdata,
    //output rx_done,
    output fifo_empty,
    output rx_rd
);

    wire w_rx_done;
    wire [7:0] w_rx_data;
    wire [7:0] fifo_rx_rdata;
    wire [7:0] fifo_tx_rdata;
    wire fifo_tx_empty, fifo_tx_full, fifo_rx_empty;
    wire tx_done;

    assign o_rdata = fifo_rx_rdata;
    //assign rx_done = w_rx_done;

    assign fifo_empty = fifo_rx_empty;

    // rx_rd는 fifo_tx_full이 비어있을 때만 읽을 수 있도록 설정
    assign rx_rd = (~fifo_rx_empty && ~fifo_tx_full);  // 조건에 맞는 값 할당
  
    top_uart U_UART (
    .clk(clk),
    .rst(rst),
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
    .reset(rst),
    // write
    .wdata(w_rx_data),
    .wr(w_rx_done),
    .full(),
    // read
    .rd(rx_rd),
    .rdata(fifo_rx_rdata),
    .empty(fifo_rx_empty)
    );

    fifo U_Fifo_TX(
    .clk(clk),
    .reset(rst),
    // write
    .wdata(fifo_rx_rdata),
    .wr(~fifo_rx_empty),
    .full(fifo_tx_full),
    // read
    .rd(~tx_done), //.rd(~tx_done & ~fifo_tx_empty),
    .rdata(fifo_tx_rdata),
    .empty(fifo_tx_empty)
    );



endmodule

module top_uart(
    input clk,
    input rst,
    //tx
    input btn_start,
    input [7:0] tx_data_in,
    output tx_done,
    output tx,
    //rx
    input rx,
    output rx_done,
    output [7:0] rx_data
);

    wire w_tick;

    
    uart_tx U_UART_TX (
        .clk(clk),
        .rst(rst),
        .tick(w_tick),
        .start_trigger(btn_start),
        .data_in(tx_data_in),
        .o_tx_done(tx_done),
        .o_tx(tx)
    );

    uart_rx U_UART_RX (
        .clk(clk),
        .rst(rst),
        .tick(w_tick),
        .rx(rx),
        .rx_done(rx_done),
        .rx_data(rx_data)    
    );

    baud_tick_gen U_BAUD_Tick_Gen (
        .clk(clk),
        .rst(rst),
        .baud_tick(w_tick) 
    );

    
endmodule

    module uart_tx (
    input clk,
    input rst,
    input tick,
    input start_trigger,
    input [7:0] data_in,
    output o_tx_done,
    output o_tx
);
    // FSM 상태 정의
    parameter IDLE = 2'b00, START = 2'b01, 
              DATA = 2'b10, STOP = 2'b11;

    reg [1:0] state, next;
    reg tx_reg, tx_next;
    reg tx_done_reg, tx_done_next;
    reg [2:0] data_count, data_count_next; // 3비트 카운터 (0~7)
    reg [3:0] tick_count_reg, tick_count_next; 

    assign o_tx = tx_reg;
    assign o_tx_done = tx_done_reg;
    // tx data in buffer
    reg [7:0] temp_data_reg, temp_data_next;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            tx_reg      <= 1'b1; // UART TX 초기 상태 HIGH
            tx_done_reg <= 0;
            data_count   <= 0;
            tick_count_reg <= 0;
            temp_data_reg <= 0;
        end else begin
            state       <= next;
            tx_reg      <= tx_next;
            tx_done_reg <= tx_done_next;
            data_count   <= data_count_next;
            tick_count_reg <= tick_count_next;
            temp_data_reg <= temp_data_next;
        end
    end

    // 상태 전이 로직
    always @(*) begin
        next = state;
        tx_next = tx_reg;
        tx_done_next = tx_done_reg;
        data_count_next = data_count;
        tick_count_next = tick_count_reg;
        temp_data_next = temp_data_reg;
        case (state)
            IDLE: begin
                tick_count_next = 4'b0;
                tx_done_next = 1'b0; 
                tx_next = 1'b1;
                if (start_trigger) begin
                    next = START;
                    //start trigger 순간 data를 buffring 하기 위해해
                    temp_data_next = data_in;
                end
            end        
            START: begin
                tx_done_next = 1'b1;
                tx_next      = 1'b0;         // 출력을 0으로 유지
                if (tick) begin
                    if (tick_count_reg == 15) begin
                    next            = DATA;
                    data_count_next = 0; // 중요 첫 번 째 rst 이후 rst에서도 0되어야 함
                    tick_count_next = 1'b0; // next state로 갈 때 tick_count 초기화
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end        
            DATA: begin
                tx_next = temp_data_reg[data_count];
                //tx_next = data_in[data_count]; // 일단 출력
                if (tick) begin
                    if (tick_count_reg == 15) begin
                        tick_count_next = 0;     // 다음 상태로 가기전에 초기화
                        if (data_count == 3'd7) begin 
                            next = STOP;
                        end else begin
                                next = DATA;
                                data_count_next = data_count + 1;
                            end                        
                    end else begin
                            tick_count_next = tick_count_reg + 1; 
                    end
                end
            end

            STOP: begin
                data_count_next = 0;
                tx_next = 1'b1;
                if (tick) begin
                    if (tick_count_reg == 15) begin
                    tx_next = 1'b1; 
                    next = IDLE;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule

// UART_RX
module uart_rx (
    input clk,
    input rst,
    input tick,
    input rx,
    output rx_done,
    output [7:0] rx_data
);

    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;
    reg [1:0] state, next;
    reg rx_done_reg, rx_done_next;
    reg [7:0] rx_data_reg, rx_data_next;
    reg [2:0] bit_count_reg, bit_count_next;
    reg [4:0] tick_count_reg, tick_count_next; //tick count 5bit, 24tick

    //output
    assign rx_done = rx_done_reg;
    assign rx_data = rx_data_reg;

    //state
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= 0;
            rx_done_reg <= 0;
            rx_data_reg <= 0;
            bit_count_reg <= 0;
            tick_count_reg <= 0;
        end else begin
            state <= next;
            rx_done_reg <= rx_done_next;
            rx_data_reg <= rx_data_next;
            bit_count_reg <= bit_count_next;
            tick_count_reg <= tick_count_next;
        end
    end

    //next
    always @(*) begin
        next = state;
        tick_count_next = tick_count_reg;
        bit_count_next = bit_count_reg;
        rx_done_next = rx_done_reg;
        rx_data_next = rx_data_reg;
        case (state)
            IDLE: begin
                tick_count_next = 0;
                bit_count_next = 0;
                rx_done_next = 0;
                if (rx == 1'b0) begin
                    next = START;
                end
            end
            START: begin
                if (tick == 1'b1) begin
                    if (tick_count_reg == 7) begin
                        next = DATA;
                        tick_count_next = 0; //init tick count
                    end else begin
                        tick_count_next = tick_count_reg + 1; //8번 반복
                    end
                end 
            end
            DATA: begin
                if (tick == 1'b1) begin
                    if (tick_count_reg == 15) begin
                        // read data 
                        rx_data_next [bit_count_reg] = rx;
                        if (bit_count_reg == 7) begin
                            next = STOP;  
                            tick_count_next = 0; //tick count 초기화  
                        end else begin
                            next = DATA;
                            bit_count_next = bit_count_reg + 1;
                            tick_count_next = 0;
                        end
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
            STOP: begin
                if (tick == 1'b1) begin
                    if (tick_count_reg == 23) begin
                        rx_done_next = 1'b1;
                        next = IDLE;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
        endcase
    end
endmodule

module baud_tick_gen (
    input clk,
    input rst,
    output baud_tick 
);
    
    parameter BAUD_RATE = 9600; 
    localparam BAUD_COUNT = (100_000_000 / BAUD_RATE) / 16; //오차 줄이기 위함함
    reg [$clog2(BAUD_COUNT)-1:0] count_reg, count_next;
    reg tick_reg, tick_next;
    // output
    assign baud_tick = tick_reg;

    always @(posedge clk, posedge rst) begin
        if (rst == 1) begin
            count_reg <= 0;
            tick_reg <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg <= tick_next;
        end
    end

    //next 
    always @(*) begin
        count_next = count_reg;
        tick_next = tick_reg;
        if (count_reg == BAUD_COUNT - 1) begin
            count_next = 0;
            tick_next = 1'b1;
        end else begin
            count_next = count_reg + 1;
            tick_next = 1'b0;
        end
    end

endmodule

