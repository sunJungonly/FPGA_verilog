`timescale 1ns / 1ps

module dht11_ctrl(
    input clk,
    input rst,
    input start,
    input tick,
    output [3:0] led_m,
    output [15:0] humidity,
    output [15:0] temperature,
    inout dht_io
    );

parameter START_CNT = 1800, WAIT_CNT = 3, DATA_SYNC_CNT = 5, DATA_01 = 4, STOP_CNT = 5,
TIME_OUT = 2000;

localparam IDLE = 0, START = 1, WAIT = 2, SYNC_LOW = 3, SYNC_HIGH = 4,
             DATA_SYNC = 5, DATA_DC= 6, STOP = 7;
reg [2:0] c_state, n_state;

reg [$clog2(START_CNT) - 1: 0] count_reg, count_next;
reg io_oe_reg, io_oe_next; //dht_io 출력 활성화 여부
reg io_out_reg, io_out_next; //dht_io 출력 값
reg led_ind_reg, led_ind_next; //indicator
reg [39:0] data_reg, data_next;
reg [$clog2(40) - 1:0] data_count_reg, data_count_next;
reg [$clog2(40) - 1:0] bit_count_reg, bit_count_next;

// out 3state on/off
assign dht_io = (io_oe_reg) ? io_out_reg : 1'bz; 
// io_oe_reg이 1일 때는 출력 모드로 동작하고, 
// 0일 때는 dht_io 핀이 하이 임피던스 상태가 되어 입력 모드로 전환

assign led_m = {led_ind_reg, c_state};

assign humidity = {data_reg[39:32], data_reg[31:24]};
assign temperature = {data_reg[23:16], data_reg[15:8]};

always @(posedge clk, posedge rst) begin
    if (rst) begin
        c_state <= IDLE;
        count_reg <= 0;
        led_ind_reg <= 0;
        io_out_reg <= 1'b1;
        io_oe_reg <= 0;
        bit_count_reg <= 0;
        data_count_reg <= 0; 
    end else begin
        c_state <= n_state;
        count_reg <= count_next;
        led_ind_reg <= led_ind_next;
        io_out_reg <= io_out_next;
        io_oe_reg <= io_oe_next;
        bit_count_reg <= bit_count_next;
        data_count_reg <= data_count_next;
    end
end

always @(*) begin
    n_state = c_state;
    count_next = count_reg;
    led_ind_next = led_ind_reg;
    io_out_next = io_out_reg;
    io_oe_next = io_oe_reg;
    bit_count_next = bit_count_reg;
    data_count_next = data_count_reg;


    case (c_state)
        IDLE:begin
            io_out_next = 1'b1;
            io_oe_next = 1'b1;
                if (start) begin
                    n_state = START;
                    count_next = 0;
                end 
        end    
        START: begin
            io_out_next = 1'b0;
            //tick 1때만 count
            if (tick) begin
                if (count_reg == START_CNT - 1) begin
                    n_state = WAIT;
                    count_next = 0;
                end else begin
                    count_next = count_reg + 1;
                end
            end
        end
        WAIT: begin
            io_out_next = 1'b1;
            if (tick) begin
                if (count_reg == WAIT_CNT - 1) begin
                    n_state = SYNC_LOW;
                    count_next = 0;
                end else begin
                    count_next = count_reg + 1;
                    
                end
            end
        end
        SYNC_LOW: begin
            io_oe_next = 1'b0;
            if (tick) begin
                if (dht_io == 1) begin
                    n_state = SYNC_HIGH;
                end
            end
        end

        SYNC_HIGH: begin
            if (dht_io == 0) begin
                n_state = DATA_SYNC;
                bit_count_next = 0;
            end
        end

        DATA_SYNC: begin
            if (dht_io == 1) begin
                n_state = DATA_DC;
            end 
        end
        
        DATA_DC: //데이터 0, 1 판별 
        begin 
            if (bit_count_reg < 40) begin
                bit_count_next = bit_count_reg + 1;
                if (tick == 1) begin
                    if (count_reg < 40) begin  
                        data_next = {data_reg[38:0], 1'b0};
                        n_state = DATA_SYNC;
                    end else begin
                        data_next = {data_reg[38:0], 1'b1};
                        n_state = DATA_SYNC;
                    end 
                end
            end else begin
                n_state = STOP;
                bit_count_next = 0;
            end
        end
        STOP:
        begin 
            io_out_next = 1'b1;  
            if (count_reg == STOP_CNT -1) begin
                n_state = IDLE;
            end
        end
        
    endcase
end

endmodule