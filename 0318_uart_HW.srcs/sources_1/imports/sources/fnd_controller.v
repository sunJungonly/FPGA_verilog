`timescale 1ns / 1ps

module fnd_controller (
    input clk,
    input reset,
    input [7:0] rx_data,
    output [7:0] seg,
    output [3:0] seg_comm
);

//    wire [3:0] w_bcd;

    // rx_to_bcd U_RX_to_BCD (
    // // .clk(clk),
    // // .reset(reset),
    // .rx_data(rx_data),
    // .bcd(w_bcd)
    // );


    bcdtoseg U_bcdtoseg (
        .bcd(rx_data), 
        .seg(seg),
        .seg_comm(seg_comm)
    );

endmodule

// module rx_to_bcd (
//     input [7:0] rx_data,
//     output reg [3:0] bcd
// );
//     always @(rx_data) begin

//         case (rx_data)
//             8'h30: bcd = 4'h0;
//             8'h31: bcd = 4'h1;
//             8'h32: bcd = 4'h2;
//             8'h33: bcd = 4'h3;
//             8'h34: bcd = 4'h4;
//             8'h35: bcd = 4'h5;
//             8'h36: bcd = 4'h6;
//             8'h37: bcd = 4'h7;
//             8'h38: bcd = 4'h8;
//             8'h39: bcd = 4'h9;
//             8'h41: bcd = 4'hA;
//             8'h42: bcd = 4'hB;
//             8'h43: bcd = 4'hC;
//             8'h44: bcd = 4'hD;
//             8'h45: bcd = 4'hE;
//             8'h46: bcd = 4'hF;
//             default: bcd = 4'h0;
//         endcase
//     end
        
//endmodule

module bcdtoseg (
    input [7:0] bcd,  // [3:0] sum 값 
    output reg [7:0] seg,
    output [3:0] seg_comm
);

    assign seg_comm = 4'b1110;

    // always 구문 출력으로 reg type을 가져야 한다.
    always @(bcd) begin

        case (bcd)
            8'h30: seg = 8'hc0;
            8'h31: seg = 8'hF9;
            8'h32: seg = 8'hA4;
            8'h33: seg = 8'hB0;
            8'h34: seg = 8'h99;
            8'h35: seg = 8'h92;
            8'h36: seg = 8'h82;
            8'h37: seg = 8'hF8;
            8'h38: seg = 8'h80;
            8'h39: seg = 8'h90;
            8'h41: seg = 8'h88;
            8'h42: seg = 8'h03;
            8'h43: seg = 8'hC6;
            8'h44: seg = 8'h21;
            8'h45: seg = 8'h86;
            8'h46: seg = 8'h8E;
            default: seg = 8'hff;
        endcase
    end
endmodule
