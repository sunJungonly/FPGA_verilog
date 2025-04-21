`timescale 1ns / 1ps
// 1bit FA
module full_adder(
    input a,
    input b,
    input cin,
    output s,
    output c
);
    
    wire w_s;           // wiring U_HA1 out s to U_HA2 in a
    wire w_c1, w_c2;
    
    assign c = w_c1 | w_c2;
    
    half_Adder U_HA1(
        .a(a),
        .b(b),
        .s(w_s),
        .c(w_c1)
    );
    
    half_Adder U_HA2(
        .a(w_s),            //from U_HA1 of s
        .b(cin),
        .s(s),
        .c(w_c2)
    );
    
endmodule

module half_Adder(
    input a,
    input b,
    output s, 
    output c
    );
    // half adder 1bit
    assign s = a ^ b;
    assign c = a & b;
    
endmodule
