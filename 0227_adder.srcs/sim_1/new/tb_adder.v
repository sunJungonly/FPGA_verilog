`timescale 1ns / 1ps

module tb_adder();

    reg a_0, b_0, a_1, b_1, a_2, b_2, a_3, b_3, cin; // reg,
    wire s_0, s_1, s_2, s_3, c;
     //  wire, 
    full_adder_4bit u_full_adder(   // module instance 
        .a_0(a_0),
        .a_1(a_1),
        .a_2(a_2),
        .a_3(a_3),
        .b_0(b_0),
        .b_1(b_1),
        .b_2(b_2),
        .b_3(b_3),
        .cin(cin),         //input carry.
        .s_0(s_0),
        .s_1(s_1),
        .s_2(s_2),
        .s_3(s_3),
        .c(c)
    );
    initial 
    begin 
        #10;    a_0 = 0; b_0 = 0; a_1 = 0; b_1 = 0; a_2 = 0; b_2 = 0; a_3 = 0; b_3 = 0;  cin = 0;
        #10;    a_0 = 0; b_0 = 1; a_1 = 0; b_1 = 0; a_2 = 0; b_2 = 0; a_3 = 0; b_3 = 0;  cin = 0;
        #10;    a_0 = 0; b_0 = 0; a_1 = 0; b_1 = 1; a_2 = 0; b_2 = 0; a_3 = 0; b_3 = 0;  cin = 1;
        #10;    a_0 = 0; b_0 = 0; a_1 = 0; b_1 = 0; a_2 = 1; b_2 = 0; a_3 = 0; b_3 = 0;  cin = 1;

    end

endmodule
