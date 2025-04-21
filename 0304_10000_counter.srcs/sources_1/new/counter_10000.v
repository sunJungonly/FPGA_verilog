`timescale 1ns / 1ps

    module Top_Upcounter (
        input clk,
        input reset,
        input clear,
        input run_stop,
        output [3:0] seg_comm,
        output [7:0] seg
    );
        
    wire [13:0]w_count;
    wire w_clk_10hz;

    clk_divider_2 U_Clk_Divider(
        .clk(clk),
        .reset(reset),
        .o_clk(w_clk_10hz)
    );

    counter_10000 U_Counter_10000(
        .clk(w_clk_10hz),
        .reset(reset),
        .run_stop(run_stop),
        .clear(clear),
        .count (w_count)
    );

    fnd_controller U_fnd_cntl(
        .clk(clk),
        .reset(reset),
        .bcd(w_count),
        .seg(seg),
        .seg_comm(seg_comm)
        
        );
    endmodule

    module clk_divider_2 (
        input clk, //100Mhz = 100_000_000 hz
        input reset,
        output o_clk
    );
        parameter FCOUNT = 10_000_000 ;
        reg[$clog2(FCOUNT)-1:0] r_counter; //$clog2 숫자를 나타내는데 필요한 비트수 계산
        reg r_clk;
        assign o_clk = r_clk;

        always @(posedge clk, posedge reset) begin
            if(reset) begin
                r_counter <= 0; //리셋 상태
                r_clk <= 1'b0;
            end else begin
                if (r_counter == FCOUNT - 1) begin //clock divide 계산 
                    r_counter <= 0;
                    r_clk <= 1'b1;  //r_clk : 0->1
                end else begin
                    r_counter <= r_counter + 1;
                    r_clk <= 1'b0; //r_clk: 0으로 유지
                end

            end
        end

    endmodule



module counter_10000 (
    input clk,
    input reset,
    input run_stop,
    input clear,
    output [$clog2(10000)-1:0] count 
);

    reg [$clog2(10000)-1:0] r_counter;

    assign count = r_counter;


    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end 
        else begin
            if (clear == 1) begin
                r_counter <= 0;
            end else begin
                if (run_stop == 1) begin        
                r_counter <= r_counter +1;
                    if (r_counter == 10000 - 1) begin
                        r_counter <= 0;
                    end
                end
            end
        end
    end

endmodule