`timescale 1ns / 1ps
/*
module adder(


    );
endmodule

*/


module fa_8bit(
    input [7:0] a,
    input [7:0] b,
    output [7:0] sum,
    output cout
);

    wire cout1;

    fa_4bit U_fa4_1(
        .a(a[3:0]),
        .b(b[3:0]),
        .cin(1'b0),
        .sum(sum[3:0]),
        .cout(cout1)
    );

    fa_4bit U_fa4_2(
        .a(a[7:4]),
        .b(b[7:4]),
        .cin(cout1),
        .sum(sum[7:4]),
        .cout(cout)
    );



endmodule





module fa_4bit(
    input [3:0] a,
    input [3:0] b,
    input cin,
    output [3:0] sum,
    output cout
);

    wire [3:1] carry;
    
    
    full_adder FA0 (a[0], b[0], cin, sum[0], carry[1]);
    full_adder FA1 (a[1], b[1], carry[1], sum[1], carry[2]);
    full_adder FA2 (a[2], b[2], carry[2], sum[2], carry[3]);
    full_adder FA3 (a[3], b[3], carry[3], sum[3], cout);


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
    input a,
    input b,
    output sum,
    output c
);

    xor (sum, a, b); // (출력, 입력0, 입력1)
    and (c, a, b);
endmodule