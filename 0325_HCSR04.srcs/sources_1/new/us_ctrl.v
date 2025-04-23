`timescale 1ns / 1ps

module us_ctrl(

    input clk,
    input rst,
    input btn_start,
    input echo,
    output trigger,
    output [7:0] seg,
    output [3:0] seg_comm
);

    wire w_tick_1usec;
    wire [$clog2(400) - 1:0]w_dist;

    baud_tick_1usec U_Tick_1usec(
    .clk(clk),
    .rst(rst),
    .tick_1usec(w_tick_1usec)
    );

    tick_10usec U_US_Ctrl(
    .clk(clk),
    .rst(rst),
    .btn_start(btn_start),
    .i_tick_1usec(w_tick_1usec),
    .trigger(trigger)
    );

    dist_cal U_Dist_Cal(
    .clk(clk),
    .rst(rst),
    .tick_1usec(w_tick_1usec),
    .echo(echo),
    .dist(w_dist)
    );

    fnd U_FND (
    .clk(clk),
    .reset(rst),
    .bcd(w_dist),
    .seg(seg),
    .seg_comm(seg_comm)
    );

endmodule

module baud_tick_1usec (
    input clk,
    input rst,
    output tick_1usec
);
    parameter FCOUNT = 100;
    reg [$clog2(FCOUNT)-1:0]count_reg, count_next;
    reg clk_reg, clk_next;

    assign tick_1usec = clk_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
        count_reg <= 0;
        clk_reg <= 0;
        end else begin
            count_reg <= count_next;
            clk_reg <= clk_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        clk_next = 0;
        if (count_reg == (FCOUNT -1)) begin
            count_next = 0;
            clk_next = 1; 
        end else begin
            count_next = count_reg + 1;
            clk_next = 0;
        end
    end
    
endmodule

module tick_10usec (
    input clk,
    input rst,
    input btn_start,
    input i_tick_1usec,
    output trigger
);

    parameter TICK_COUNT = 10;

    reg [$clog2(TICK_COUNT)-1:0]counter_reg, counter_next;

    reg o_trigger_reg, o_trigger_next;
    assign trigger = o_trigger_reg;

    parameter IDLE = 1'b0, HIGH = 1'b1;
    reg state, next;
    
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= IDLE;
            counter_reg <= 0;
            o_trigger_reg <= 0;
        end else begin
            state <= next;
            counter_reg <= counter_next;
            o_trigger_reg <= o_trigger_next;
        end
    end

    //next
    always @(*) begin
        next = state;
        counter_next = counter_reg;
            case (state)
                IDLE: 
                if (btn_start == 1'b1) begin
                        next = HIGH;    
                        counter_next = 0;
                        end 
                HIGH: 
                if(i_tick_1usec == 1) begin 
                    if (counter_reg == (TICK_COUNT-1)) begin 
                        next = IDLE;
                        counter_next = 0;
                        end else begin
                            counter_next = counter_reg + 1;
                        end
                    end        
            endcase
    end

    always @(*) begin
        o_trigger_next = o_trigger_reg;
        case (state)
            IDLE: begin
                o_trigger_next = 0;
            end

            HIGH: 
                if (counter_reg == (TICK_COUNT)) begin
                    o_trigger_next = 0;   
                end else begin
                    o_trigger_next = 1;  
                end
        endcase
    end

endmodule

module dist_cal (
    input clk,
    input rst,
    input tick_1usec,
    input echo,
    output [$clog2(400) - 1: 0] dist //최대 4m
);

    reg[$clog2(23200) - 1:0]count_reg, count_next; // 58*400 = 23200

    reg[$clog2(400) - 1:0] dist_reg, dist_next;
    assign dist = dist_reg;

    parameter IDLE = 2'b00, HIGH_CNT = 2'b01, DIST_CAL = 2'b10 ;
    reg [1:0] state, next;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= IDLE;
            dist_reg <= 0;
            count_reg <= 0;
        end else begin
            state <= next;
            dist_reg <= dist_next;
            count_reg <= count_next; 
        end
    end

    always @(*) begin
        next = state;
        case (state)
            IDLE: 
            if (tick_1usec == 1 && echo == 1) begin
                next = HIGH_CNT;
            end
            HIGH_CNT: 
            if (echo == 0) begin
                next = DIST_CAL;
            end 
            DIST_CAL: 
            begin
                next = IDLE;
            end
        endcase
    end

    always @(*) begin
        dist_next = dist_reg;
        count_next = count_reg;
        case (state)
            IDLE: 
            begin
                dist_next = 0;
            end
            HIGH_CNT:
            if (tick_1usec == 1 && echo == 1) begin
                count_next = count_reg + 1;
            end
            DIST_CAL:
            begin
                dist_next = (count_reg)/58;
            end
        endcase
        
    end
        
    
endmodule

