`timescale 1ns / 1ps

module full_adder(
    input a_0,
    input b_0,
    input a_1,
    input b_1,
    input a_2,
    input b_2,
    input a_3,
    input b_3, 
    input cin,
    output s_0,
    output s_1,
    output s_2,
    output s_3,
    output c
);

    wire w_c1, w_c2, w_c3, w_c4;
    

    
    full_adder U_HA0(
        .a(a_0),
        .b(b_0),
        .s(s_0),
        .cin(cin),
        .c(w_c1)
    );
    
    full_adder U_HA1(
        .a(a_1),   // from U_HA1 of s
        .b(b_1),
        .s(s_1),
        .cin(w_c1),  
        .c(w_c2) 
    );
    full_adder U_HA2(
        .a(a_2),
        .b(b_2),
        .s(s_2),
        .cin(w_c2),
        .c(w_c3)
    );
    
    ful_adder U_HA3(
        .a(a_3),   // from U_HA1 of s
        .b(b_3),
        .s(s_3),
        .cin(w_c3),  
        .c(w_c4) 
    );
    
    
endmodule
