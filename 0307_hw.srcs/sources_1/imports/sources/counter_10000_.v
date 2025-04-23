`timescale 1ns / 1ps

module Top_Upcounter(
    input clk,
    input reset,
    input [2:0] sw,
    output[3:0] seg_comm,
    output[7:0] seg
);

    wire [13:0] w_count; // 10000을 $clog2로 필요한 비트 수 계산한 결과 값
    wire w_clk_10hz, w_run_stop, w_clear;

    //assign w_run_stop = clk & sw[0];
    //assign w_clear = reset | sw[1]; 

    clk_div_10hz U_Clk_div_10hz (
        .clk(clk),
        .reset(reset),
        .run_stop(w_run_stop),
        .o_clk_10hz(w_clk_10hz)
    );




    counter_10000 U_Counter_10000 (
        .clk(w_clk_10hz),
        .clear(w_clear), //clear
        .reset(reset),
        .count(w_count) // 14bit
    );


    fnd_controller U_fnd_ctrl(
        .clk(clk),
        .reset(reset),
        .bcd(w_count), // 14bit
        .seg(seg),
        .seg_comm(seg_comm)
    );

    control_unit U_Control_unit (
    .clk(clk),
    .reset(reset),
    .i_run_stop(sw[0]),
    .i_clear(sw[1]),
    .o_run_stop(w_run_stop),
    .o_clear(w_clear)
);


endmodule

module clk_div_10hz (
    input clk,
    input reset,
    input run_stop,
    output o_clk_10hz
);
    reg [$clog2(10_000_000)-1:0] r_counter;
    reg r_clk_10hz;

    assign o_clk_10hz = r_clk_10hz;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else begin
            if (run_stop == 1'b1) begin
                if (r_counter == (10_000_000-1)) begin
                    r_counter <= 0;
                    r_clk_10hz <= 1'b1;
                end else if (r_counter==(10_000_000 / 2) -1) begin
                    // duty radio 50%
                    r_clk_10hz <= 1'b0;
                    r_counter <= r_counter + 1;
                end else begin
                    r_counter <= r_counter + 1;
                end
            end else r_counter <= r_counter;
        end
    end



endmodule


module counter_10000(
    input clk,
    input reset,
    input clear,
    output [13:0] count // 14bit
);
    reg [$clog2(10000)-1:0] r_counter;

    
    assign count = r_counter;


    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else if (clear) begin
            r_counter <= 0;  // 🔹 clear 신호가 1일 때 즉시 초기화
        end else if (r_counter == 10000-1) begin
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1;
        end
    end
endmodule


/*module digit_splitter(
    input [13:0] bcd,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
    
);
    assign digit_1 = bcd % 10;
    assign digit_10 = (bcd / 10) % 10;
    assign digit_100 = (bcd / 100) % 10;
    assign digit_1000 = (bcd / 1000) % 10;
endmodule */

module control_unit (
    input clk,
    input reset,
    input i_run_stop,
    input i_clear,
    output reg o_run_stop,
    output reg o_clear
);
    parameter STOP = 3'b000, RUN = 3'b001, CLEAR = 3'b010;

    // state 관리
    reg [2:0] state, next;

    // state sequencial logic
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= STOP; // 대부분 초기값 넣음 0(STOP도 0임)
        end else begin
            state <= next;
        end
    end

    // next combinational logic
    always @(*) begin
        case (state)
            STOP : begin
                if (i_clear == 1'b1) begin
                    next = CLEAR;  // 🔹 clear 우선 처리
                end else if (i_run_stop == 1'b1) begin
                    next = RUN;
                end else begin
                    next = STOP;
                end
            end
            RUN : begin
                if (i_clear == 1'b1) begin
                    next = CLEAR;  // 🔹 clear 중에 run 중단
                end else if (i_run_stop == 1'b0) begin
                    next = STOP;
                end else begin
                    next = RUN;
                end
            end
            CLEAR : begin
                if (i_clear == 1'b0) begin
                    next = STOP;  // 🔹 clear 신호 해제 후 STOP으로 복귀
                end else begin
                    next = CLEAR;
                end
            end
            default: next = STOP;
        endcase
    end



    // combinational logic
    always @(*) begin
        case (state)
            STOP: begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
            end  
            RUN: begin
                o_run_stop = 1'b1;
                o_clear = 1'b0;
            end  
            CLEAR: begin
                o_clear = 1'b1; // 🔹 clear 신호 즉시 반영
                o_run_stop = 1'b0;
            end 
            default: begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
            end
        endcase
    end





endmodule
