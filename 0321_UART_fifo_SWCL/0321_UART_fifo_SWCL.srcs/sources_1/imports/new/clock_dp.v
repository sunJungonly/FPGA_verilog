`timescale 1ns / 1ps

module clk_dp(
    input clk,
    input reset,
    input in_hour,
    input in_min,
    input in_sec,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
    );

    wire btn;
    wire w_clk_100hz;
    wire w_msec_tick, w_sec_tick, w_min_tick;

    clk_div_100_cl U_CLK_Div(
        .clk(clk),
        .reset(reset),
        .o_clk(w_clk_100hz)
    );

    time_counter_cl #(.TICK_COUNT(100), .BIT_WIDTH(7)) U_Time_Msec(
        .clk(clk),
        .reset(reset),
        .tick(w_clk_100hz),
        .btn(),
        .o_time(msec),
        .o_tick(w_msec_tick)
    );

    time_counter_cl #(.TICK_COUNT(60), .BIT_WIDTH(6)) U_Time_sec(
        .clk(clk),
        .reset(reset),
        .tick(w_msec_tick),
        .btn(in_sec),
        .o_time(sec),
        .o_tick(w_sec_tick)
    );

    time_counter_cl #(.TICK_COUNT(60), .BIT_WIDTH(6)) U_Time_Min(
        .clk(clk),
        .reset(reset),
        .tick(w_sec_tick),
        .btn(in_min),
        .o_time(min),
        .o_tick(w_min_tick)
    );

    time_counter_cl #(.TICK_COUNT(24), .BIT_WIDTH(5)) U_Time_Hour(
        .clk(clk),
        .reset(reset),
        .tick(w_min_tick),
        .btn(in_hour),
        .o_time(hour),
        .o_tick()
    );

    

endmodule


    module time_counter_cl #(parameter TICK_COUNT = 100, BIT_WIDTH = 7) ( 
        input clk,
        input reset,
        input tick,
        input btn,
        output [BIT_WIDTH - 1 : 0]o_time, // 놓침
        output o_tick
    );
        
        reg [$clog2(TICK_COUNT)-1 : 0] count_reg, count_next; // for state
        reg tick_reg, tick_next;                              // for output
        
        assign o_time = count_reg;
        assign o_tick = tick_reg;

        always @(posedge clk, posedge reset) begin
            if (reset) begin
                count_reg <= 0;
                tick_reg <= 0;
            end else begin
                count_reg <= count_next;
                tick_reg <= tick_next;
            end
        end

        

        always @(*) begin
            count_next = count_reg; // 고민뚠뚠
            tick_next = 1'b0; // 0 -> 1 -> 0 2clk 걸림//output

            // if (btn == 1'b1) begin
            //     if (count_reg == TICK_COUNT - 1) begin
            //         count_next = 0;
            //     end else begin
            //         count_next = count_reg + 1;
            //     end 
            // end 


            if (tick == 1'b1 || btn == 1'b1 ) begin               
                if (count_reg == TICK_COUNT - 1) begin
                    count_next = 0;
                    tick_next = 1'b1;
                end else begin
                    count_next = count_reg + 1;
                    tick_next = 1'b0;
                end
            end
        end

    endmodule

    module clk_div_100_cl (
        input clk,
        input reset,
        output o_clk
        
    );
        parameter FCOUNT = 1_000_000; //100; for test 2 //10; for test
        reg [$clog2(FCOUNT) - 1 : 0] count_reg, count_next;
        reg clk_reg, clk_next; // ** 출력을 f/f으로 내보내기 위해서
        
        assign o_clk = clk_reg; // 최종 출력

        always @(posedge clk, posedge reset) begin
            if (reset) begin
                count_reg   <= 0;
                clk_reg     <= 0;
            end else begin
                count_reg <= count_next;
                clk_reg   <= clk_next;
            end           
        end
        
        always @(*) begin
            count_next  = count_reg;
            clk_next    = 1'b0;
            
                if (count_reg == (FCOUNT-1)) begin
                    count_next = 0;
                    clk_next   = 1'b1; // high 출력
                end else begin
                    count_next = count_reg + 1;
                    clk_next = 1'b0;
                end
             
        end

    endmodule


    