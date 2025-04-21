`timescale 1ns / 1ps

    module Top_Upcounter (
        input clk,
        input reset,
        output [3:0] seg_comm,
        output [7:0] seg_data
    );
        

    fnd_controller U_fnd_cntl(
            .clk(clk),
            .reset(reset),
            .bcd(),
            .seg(seg),
            .seg_comm(seg_comm)
        
        );
    endmodule

module counter_10000 (
    input clk,
    input reset,
    output [$clog2(10000)-1:0] count 
);

    reg [$clog2(10000)-1:0] r_counter;

    assign count = r_counter;


    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;

        end
    end

endmodule
