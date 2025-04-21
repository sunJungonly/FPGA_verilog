`timescale 1ns / 1ps

module bit8_adder(

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
    input [3:0] bcd,  //[3:0] sum 값
    output reg [7:0] seg
);
    // always 구문 출력으로 reg type을 가져야 한다.
    always @(bcd) begin

        case (bcd)
            4'h0: seg = 8'hc0;
            4'h1: seg = 8'hF9;
            4'h2: seg = 8'hA4;
            4'h3: seg = 8'hB0;
            4'h4: seg = 8'h99;
            4'h5: seg = 8'h92;
            4'h6: seg = 8'h82;
            4'h7: seg = 8'hf8;
            4'h8: seg = 8'h80;
            4'h9: seg = 8'h90;
            4'ha: seg = 8'h88;
            4'hb: seg = 8'h83;
            4'hc: seg = 8'hc6;
            4'hd: seg = 8'ha1;
            4'he: seg = 8'h86;
            4'hf: seg = 8'h8E;
            default: seg = 8'hff;
        endcase
    end

endmodule