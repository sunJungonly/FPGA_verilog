`timescale 1ns / 1ps

module adder_8bit(

    input [7:0] a,
    input [7:0] b,
    output[7:0] s,
    output cout
); 

    wire w_c;    

    fa_4 U_fa_4 (
    .a(a[3:0]), 
    .b(b[3:0]), 
    .s(s[3:0]),
    .c(w_c)  
);

    fa_4 U_fa_5 (
    .a(a[7:4]), 
    .b(b[7:4]), 
    .s(s[7:4]),
    .c(cout)  

    );
endmodule


module bcdtoseg (
    input [7:0] bcd,  //[3:0] sum 값
    output reg [7:0] seg
);
    // always 구문 출력으로 reg type을 가져야 한다.
    always @(bcd) begin

        case (bcd)
            8'h0: seg = 8'hc0;
            8'h1: seg = 8'hF9;
            8'h2: seg = 8'hA4;
            8'h3: seg = 8'hB0;
            8'h4: seg = 8'h99;
            8'h5: seg = 8'h92;
            8'h6: seg = 8'h82;
            8'h7: seg = 8'hf8;
            8'h8: seg = 8'h80;
            8'h9: seg = 8'h90;
            8'ha: seg = 8'h88;
            8'hb: seg = 8'h83;
            8'hc: seg = 8'hc6;
            8'hd: seg = 8'ha1;
            8'he: seg = 8'h86;
            8'hf: seg = 8'h8E;
            default: seg = 8'hff;
        endcase
    end

endmodule