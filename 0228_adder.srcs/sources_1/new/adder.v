`timescale 1ns / 1ps

module fa_4 (
    input [3:0] a, //4bit vertor형
    input [3:0] b, 
//    input cin, 
    output [3:0] s,
    output c  
);
    wire [3:0] w_c;

    full_adder U_fa0 (
        .a(a[0]),
        .b(b[0]),
        .cin(1'b0),
        .sum(s[0]),
        .c(w_c[0])
    );

    full_adder U_fa1(
        .a(a[1]),
        .b(b[1]),
        .cin(w_c[0]),
        .sum(s[1]),
        .c(w_c[1])
    );

    full_adder U_fa2(
        .a(a[2]),
        .b(b[2]),
        .cin(w_c[1]),
        .sum(s[2]),
        .c(w_c[2])
    );

    full_adder U_fa3(
        .a(a[3]),
        .b(b[3]),
        .cin(w_c[2]),
        .sum(s[3]),
        .c(c)
    );

endmodule
module full_adder (
    input a, 
    input b,
    input cin,
    output sum,
    output c
);


    wire w_s, w_c1, w_c2;
    
    assign c = w_c1 | w_c2;
    
    half_adder U_ha1(
        .a(a),
        .b(b),
        .sum(w_s),
        .c(w_c1)
    );
    half_adder U_ha2(
        .a(w_s),
        .b(cin),
        .sum(sum),
        .c(w_c2) 
    );
endmodule

module half_adder (
    input a, //1bit wire
    input b,
    output sum,
    output c
);

    // assign sum = a ^ b;
    // assign c = a & b;

    // 게이트 프리미티브 방식 :  verilog lib에서 제공
    xor (sum, a, b); // (출력, 입력 0, 입력 1, ...)
    and (c, a, b); 

endmodule 
