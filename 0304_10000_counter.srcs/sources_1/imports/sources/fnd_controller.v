`timescale 1ns / 1ps

module calculator(
    input clk,
    input reset,
    // adder_8
    input [7:0] a,
    input [7:0] b,

    // 7-seg 출력
    output [7:0] seg,
    output [3:0] seg_comm
);

wire w_carry;
wire [7:0] w_s;


fa_8bit U_fa8(
    .a(a),
    .b(b),
    .sum(w_s),
    .cout(w_carry)
);

fnd_controller U_fndC(
        .clk(clk),
        .reset(reset),
        .bcd({w_carry, w_s}),
        .seg(seg),
        .seg_comm(seg_comm)
    );


endmodule



module fnd_controller(
        input clk,
        input reset,
        input [13:0] bcd,
        output [7:0] seg,
        output [3:0] seg_comm
    
    );

    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire [3:0] w_bcd;
    wire [1:0] o_sel;
    wire w_clk_100hz;

    clk_divider U_Clk_Divider(
        .clk(clk),
        .reset(reset),
        .o_clk(w_clk_100hz)
    );

    counter_4 U_counter4 (
        .clk(w_clk_100hz),
        .reset(reset),
        .o_sel(o_sel)

    );

    bcdtoseg U_bcdtoseg( 
        .bcd(w_bcd),
        .seg(seg)
    );

    digit_splitter U_dig_splt(
        .bcd(bcd),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000)
    );  


    mux_4X1 U_mux41(
        .sel(o_sel),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000),
        .bcd(w_bcd)
    );

    decoder_2to4 U_decoder(
        .btn(o_sel),
        .seg_comm(seg_comm)

    );



endmodule




module bcdtoseg( // 4bit(0~15까지)입력으로 해서 출력을 (0~9) 디스플레이로 출력(이때는 8bit가 쓰임) 
    input [3:0] bcd,
    output reg [7:0] seg
);


    always@(bcd) begin // 대상(bcd)의 값의 변화를 추적
            case(bcd) 
                4'h0: seg=8'hc0;
                4'h1: seg=8'hf9;
                4'h2: seg=8'ha4;
                4'h3: seg=8'hb0; 
                4'h4: seg=8'h99;
                4'h5: seg=8'h92;
                4'h6: seg=8'h82;
                4'h7: seg=8'hf8;
                4'h8: seg=8'h80;
                4'h9: seg=8'h90;
                4'ha: seg=8'h88;
                4'hb: seg=8'h83;
                4'hc: seg=8'hc6;
                4'hd: seg=8'ha1; 
                4'he: seg=8'h86;
                4'hf: seg=8'h8e;
                default: seg = 8'hff;
            endcase

        end

endmodule


module decoder_2to4(
    input [1:0] btn,
    output reg [3:0] seg_comm
);


    always@(btn) begin
        case(btn)
            2'b00: seg_comm=4'b1110;
            2'b01: seg_comm=4'b1101;
            2'b10: seg_comm=4'b1011;
            2'b11: seg_comm=4'b0111;
            default: seg_comm=4'b1110;
        endcase
    end


endmodule


module digit_splitter(
    input [13:0] bcd,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);
// 1의자리 ~ 1000의 자리
    assign digit_1 = bcd % 10;
    assign digit_10 = bcd / 10 % 10;
    assign digit_100 = bcd / 100 % 10;
    assign digit_1000 = bcd / 1000 % 10;

endmodule


module mux_4X1(
    input [1:0] sel,
    input [3:0] digit_1,
    input [3:0] digit_10,
    input [3:0] digit_100,
    input [3:0] digit_1000,
    output reg [3:0] bcd
);

// always 안에서는 assign x
// always 안에서 출력은 reg type
    always @(*) begin
        case(sel)
            2'b00: bcd = digit_1;
            2'b01: bcd = digit_10;
            2'b10: bcd = digit_100;
            2'b11: bcd = digit_1000;
            default: bcd = 4'bx;
        endcase

    end

endmodule

module clk_divider (
    input clk,
    input reset,
    output o_clk
);
    parameter FCOUNT = 500_000 ;
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


module counter_4(

    input clk, 
    input reset,
    output [1:0] o_sel
);

    reg [1:0] r_counter;
    assign o_sel = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1;
            end

    end


endmodule