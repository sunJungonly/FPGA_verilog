`timescale 1ns / 1ps

module mealy_fsm (
    input clk, 
    input reset, 
    input din_bit, 
    output reg dout_bit
);

    reg [2:0] state, next;
// 상태 선언
    parameter start = 3'b000;
    parameter rd0_once = 3'b001;
    parameter rd1_once = 3'b010;
    parameter rd0_twice = 3'b011;
    parameter rd1_twice = 3'b100;

// 출력값 결정
// assign dout_bit =(((state == rd0_twice) && (din_bit == 0) ||
//                     (state_reg == rd1_twice) && (din bit == 1))) ? 1 : 0;


// 다음 상태 결정을 위한 always 조합회로 블록
always @(posedge clk, posedge reset) begin
    if (reset) begin
        state <= start;
    end
    else begin
        state <= next;
    end
end

always @(*) begin
    if(reset) begin
        next = start;
        dout_bit = 0;
    end
    else begin
        case (state)
            start : if (din_bit == 0) begin
                next = rd0_once;
                dout_bit = 0;
            end
            else begin
                next = rd1_once;
                dout_bit = 0;
            end
        
            rd0_once : if (din_bit == 0) begin
                next = rd0_twice;
                dout_bit = 1;
            end
            else begin
                next = rd1_once;
                dout_bit = 0;
            end 

            rd1_once : if (din_bit == 0) begin
                next = rd0_once;
                dout_bit = 0;
            end
            else begin
                next = rd1_twice;
                dout_bit = 1;
            end 

            rd0_twice : if (din_bit == 0) begin
                next = rd0_twice;
                dout_bit = 1;
            end
            else begin
                next = rd1_once;
                dout_bit = 0;
            end 

            rd1_twice : if (din_bit == 0) begin
                next = rd0_once;
                dout_bit = 0;
            end
            else begin
                next = rd1_twice;
                dout_bit = 1;
            end 
            default : begin
                next = start;
                dout_bit = 0;
            end

        endcase
    end
end

endmodule