`timescale 1ns / 1ps

module fnd(
        input clk,
        input reset,
        //input [1:0] sw_mode,
        input [15:0] bcd,
        output [7:0] seg,
        output [3:0] seg_comm
    );

    wire [3:0] w_bcd, w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire [1:0] w_seg_sel;

    wire w_clk_100hz;

    clk_divider U_clk_divider (
        .clk(clk),
        .reset(reset),
        .o_clk(w_clk_100hz)
    );

    counter_4 U_Counter_4 (
        .clk(w_clk_100hz),
        .reset(reset),
        .o_sel(w_seg_sel)
    );
    
    
    decoder_2x4 U_decoder_2x4(
        .seg_sel(w_seg_sel),
        .seg_comm(seg_comm)
    );
    
    digit_splitter U_Digit_Splitter(
        .bcd(bcd),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000)
    );

    mux_4x1 U_Mux_4x1 (
        .sel(w_seg_sel),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000),
        .bcd(w_bcd)
    );

    //assign seg_comm = 4'b1110; // segment 0의자리 on (segment가 anode type)
    bcdtoseg U_bcdtoseg(
        .bcd(w_bcd), 
        .seg(seg)
    );
endmodule

module clk_divider (
    input clk,
    input reset,
    output o_clk
);
    parameter FCOUNT = 500_000 ;
    reg [19:0] r_counter;       // [$clog(1_000_000):0]로 적어줘도 된다 ( $ 필수!!! )
    reg r_clk;

    assign o_clk = r_clk;
    
    always @(posedge clk, posedge reset) begin      
        if(reset) begin
            r_counter <= 0;     // 리셋 상태
            r_clk <= 1'b0;
        end else begin
            //clock divide 계산, 100Mhz -> 100hz
            if (r_counter == FCOUNT) begin     
                r_counter <= 0;
                r_clk <= 1'b1;      // r_clk : 0 -> 1
                // clk이 쭉 오다가 999,999,999 상승엣지일때 r_clk(o_clk)=1로 바꾸겠다
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0;       // r_clk : 0으로 유지
            end
        end
        
    end
    
endmodule

module counter_4 (
    input clk,
    input reset,
    output [1:0] o_sel
);

    reg [1:0] r_counter;
    assign o_sel = r_counter;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_counter <= 0;
        end else begin
            r_counter <= r_counter +1;
        end
    end
endmodule


module decoder_2x4(
    input [1:0] seg_sel,
    output reg [3:0] seg_comm // always 구문의 출력은 항상 reg 
);
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

module digit_splitter(
    input [7:0] bcd,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);
    assign digit_1 = bcd % 10;      // 1의 자리
    assign digit_10 = (bcd / 10) % 10;   // 10의 자리
    assign digit_100 = (bcd / 100) % 10;  // 100의 자리
    assign digit_1000 = (bcd / 1000) % 10;  // 1000의 자리
  

endmodule

module mux_4x1 (
    input [1:0] sel,
    input [3:0] digit_1,
    input [3:0] digit_10,
    input [3:0] digit_100,
    input [3:0] digit_1000,
    output [3:0] bcd
);
    reg [3:0] r_bcd;
    assign bcd = r_bcd;
    // * : input 모두 감시, 아니면 개별 입력 선택 가능
    // always : 항상 감시한다 @이벤트 이하를 ()의 변화가 있으면, begin - end를 수행하라.
    always @(sel, digit_1, digit_10, digit_100, digit_1000) begin
        case(sel)
            2'b00: r_bcd = digit_1;
            2'b01: r_bcd = digit_10;
            2'b10: r_bcd = digit_100;
            2'b11: r_bcd = digit_1000;
            default: r_bcd = 4'bx; // 상관없음
        endcase
    end

endmodule


module bcdtoseg(
    input [3:0] bcd, // [3:0] sum값
    output reg [7:0] seg
);
    // always 구문 출력으로 reg type을 가져야 한다.
    always @(bcd) begin // 항상 감시함 (sensitivity list)를
        // case문 -> 조건 따져서 행동분류할 때 사용
        case (bcd)
            4'h0: seg = 8'hC0; // 7segment에서 0
            4'h1: seg = 8'hF9; // 7segment에서 0
            4'h2: seg = 8'hA4; // 7segment에서 0
            4'h3: seg = 8'hB0; // 7segment에서 0
            4'h4: seg = 8'h99; // 7segment에서 0
            4'h5: seg = 8'h92; // 7segment에서 0
            4'h6: seg = 8'h82; // 7segment에서 0
            4'h7: seg = 8'hF8; // 7segment에서 0
            4'h8: seg = 8'h80; // 7segment에서 0
            4'h9: seg = 8'h90; // 7segment에서 0
            4'hA: seg = 8'h88; // 7segment에서 0
            4'hB: seg = 8'h83; // 7segment에서 0
            4'hC: seg = 8'hC6; // 7segment에서 0
            4'hD: seg = 8'hA1; // 7segment에서 0
            4'hE: seg = 8'h86; // 7segment에서 0
            4'hF: seg = 8'h8E; // 7segment에서 0 
            default: seg = 8'hff;
        endcase
    end
endmodule
