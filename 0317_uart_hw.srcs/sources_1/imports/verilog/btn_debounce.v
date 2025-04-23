`timescale 1ns / 1ps

module btn_debounce(
    input clk,
    input reset,
    input i_btn,
    output o_btn
    );


    //reg state, next;
    reg [7:0] q_reg, q_next; // shift register
    reg edge_detect;
    wire btn_debounce;

    // 1khz clk
    reg [$clog2(100_000)-1 : 0] counter;
    reg r_1khz;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
           // r_1khz <= 0;
        end

        else begin
            if(counter == 100_000 -1) begin
                counter <= 0;
                r_1khz <= 1;
            end

            else begin
                counter <= counter + 1;
                r_1khz <= 0;
            end
        end

    end

    // // next
    // always @(*) begin
    //     counter_next = counter_reg;
    //     r_1khz = 0;

    //     if (counter_reg == 100_000 - 1) begin
    //         counter_reg = 0;
    //         r_1khz = 1;
    //     end

    //     else begin // 1khz 1tick
    //         counter_next = counter_reg + 1;
    //         r_1khz = 0;
    //     end

    // end




    //state logic, shift register
    always@(posedge r_1khz, posedge reset) begin
        if (reset) begin
            q_reg <= 0;
        end

        else begin 
            q_reg <= q_next;
        end
    end


    // next logic
    always @(i_btn, r_1khz) begin
        // q_reg 현재의 상위 7bit를 다음 하위 7bit에 넣고, 최상위에는 i_btn 넣기
        q_next = {i_btn, q_reg[7:1]}; // 8 shift의 동작 설명
    end

    // 8 input And gate
    assign btn_debounce = &q_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            edge_detect <= 0;
        end

        else begin
            edge_detect <= btn_debounce;
        end

    end
    
    // 최종 출력
    assign o_btn = btn_debounce & (~edge_detect);

endmodule

module aand_debounce (
    input clk,
    input reset,
    input sw_mode,
    input btn_in,
    output btn_out
);

    wire w_btn;
    assign btn_out = w_btn & sw_mode;

    btn_debounce U_btn_debounce(
    .clk(clk),
    .reset(reset),
    .i_btn(btn_in),
    .o_btn(w_btn)
    );
endmodule
