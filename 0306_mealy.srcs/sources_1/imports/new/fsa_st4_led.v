`timescale 1ns / 1ps
module fsm_exam_mealy(
    input clk,
    input reset,
    input [2:0] sw,
    output [2:0] led
);
    parameter [2:0] IDLE = 3'b000, ST1 = 3'b001, ST2 = 3'b010, ST3 = 3'b100, ST4 = 3'b111;
    
    reg [2:0] r_led;
    assign led = r_led;
    
    reg [2:0] state, next; // 3bits for 5 states
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= 0;
            
        end else begin
            // 상태관리, next를 현재상태로 바꿔라
            state <= next;
        end
    end

    // 2. 다음 상태로 가기위한 로직
    // next combinational logic
    always @(*) begin
        next = state;
        case (state)
            IDLE: begin 
                if (sw == 3'b001) begin
                    next = ST1;
                end else if (sw == 3'b010) begin
                    next = ST2;
                end else begin
                    next = state;
                end
            end
            ST1: begin
                if (sw == 3'b010) begin
                    next = ST2;
                end else begin
                    next = state;
                end
            end
            ST2: begin
                if (sw == 3'b100) begin
                    next = ST3;
                end else begin
                    next = state;
                end
            end
            ST3: begin
                if (sw == 3'b001) begin
                    next = ST1;
                end else if (sw == 3'b000) begin
                    next = IDLE;
                end else if (sw == 3'b111) begin
                    next = ST4;
                end else begin
                    next = state;
                end
            end
            ST4: begin
                if (sw == 3'b100) begin
                    next = ST3;
                end else begin
                    next = state;
                end
            end
            default: next = state;
        endcase
    end

    // 3. 출력로직
    // output combination logic
    always @(*) begin
        case (state) // next vs state?
            IDLE: begin
                if (sw == 3'b001) begin // meally
                    r_led = 3'b001;
                end else if (sw == 3'b010) begin
                    r_led = 3'b010;
                end else begin
                    r_led = 3'b000;
                end
            end
            ST1 : begin
                if (sw == 3'b010) begin
                    r_led = 3'b010;
                end else begin
                    r_led = 3'b001;
                end
            end
            ST2 : begin
                if (sw == 3'b100) begin
                    r_led = 3'b100;
                end else begin
                    r_led = 3'b010;
                end
            end
            ST3 : begin
                if (sw == 3'b001) begin
                    r_led = 3'b001;
                end else if (sw == 3'b000) begin
                    r_led = 3'b000;
                end else if (sw == 3'b111) begin
                    r_led = 3'b111;
                end else begin
                    r_led = 3'b100; // 뭐지 여기기
                end
            end
            ST4 : begin
                if (sw == 3'b100) begin
                    r_led = 3'b100;
                end else begin
                    r_led = 3'b111;
                end
            end
            default: begin
                r_led = 3'b000; // 뭐 넣지.. 유지 or 알람기능능
            end
        endcase
    end
endmodule
