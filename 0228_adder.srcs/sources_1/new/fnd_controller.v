`timescale 1ns / 1ps

module calcultor(
    input [3:0] a,
    input [3:0] b,
    input [1:0] btn,
    output [7:0] seg,
    output [3:0] seg_comm,
    output c_led
); 

    wire [3:0] w_sum;    
    fnd_controller U_fnd_controller (
        .bcd(w_sum), 
        .btn(btn), 
        .seg(seg),
        .seg_comm(seg_comm)
    );

    fa_4 U_fa_4 (
    .a(a), 
    .b(b), 
    .s(w_sum),
    .c(c_led)  
);

endmodule

module fnd_controller (
    input [8:0] bcd,
    input [1:0] btn,
    output [7:0] seg,
    output [3:0] seg_comm
);

    decoder_2X4 U_decoder_2X4 (
        .seg_sel(seg_sel),
        .seg_comm(seg_comm)
    );
    bcdtoseg U_bcdtoseg (
            .bcd(bcd),  //[3:0] sum 값
            .seg(seg)
    );
endmodule

module decoder_2X4 (
    input [1:0] seg_sel,
    output reg [3:0] seg_comm
);

    // 2X4 decoder
    always @(seg_sel) begin
        case (seg_sel)
            2'b00: seg_comm = 4'b1110;  
            2'b01: seg_comm = 4'b1101; 
            2'b10: seg_comm = 4'b1011;  
            2'b11: seg_comm = 4'b0111;  
                default: seg_comm = 4'b1110;
        endcase
    end

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
