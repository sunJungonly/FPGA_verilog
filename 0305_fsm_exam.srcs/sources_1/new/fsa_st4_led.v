`timescale 1ns / 1ps

module fsa_st4_led(
    input clk,
    input reset,
    input [2:0] sw,
    output reg [2:0] led
    );


    parameter [2:0] IDLE =  3'b000, ST01 = 3'b001, ST02 = 3'b010, ST03 = 3'b011, ST04 = 3'b100;

    reg [2:0] state, next;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= 0;
        end
        else begin
            state <= next;  
        end      
    end

    always @(*) begin
        case (state)
            IDLE : begin
                led = 3'b000;
            end
            ST01 : begin
                led = 3'b001;
            end
            ST02 : begin
                led = 3'b010;
            end
            ST03 :begin
                led = 3'b100;
            end
            ST04 : begin
                led = 3'b111;
            end
             
            default: begin
                led = 3'b000;
            end 
         endcase
    end

        // next combinational logic
        always @(*) begin
            next = state ;
            case (next)
                IDLE : begin
                    if (sw == 3'b001) begin
                        next = ST01;
                    end
                    else if (sw == 3'b010) begin
                        next = ST02;
                    end
                end 
                ST01 : begin
                    if (sw == 3'b010) begin
                        next = ST02;
                    end
                end
                ST02 : begin
                    if (sw == 3'b100) begin
                        next = ST03;
                    end
                end
                ST03 : begin
                    if (sw == 3'b000) begin
                        next = IDLE;
                    end
                    else if (sw == 3'b111) begin
                        next = ST04;
                    end
                    else if (sw == 3'b001) begin
                        next = ST01;
                    end
                    else begin
                        next = state;
                    end
                end
                ST04 : begin
                    if (sw == 3'b100) begin
                        next = ST03;
                    end
                end
                default: next = state; 
            endcase
        end      
endmodule