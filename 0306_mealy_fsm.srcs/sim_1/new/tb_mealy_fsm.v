`timescale 1ns / 1ps

module tb_mealy_fsm();

reg clk, reset, din_bit;
wire dout_bit;

mealy_fsm dut (

    .clk(clk), 
    .reset(reset), 
    .din_bit(din_bit), 
    .dout_bit(dout_bit)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    
    #5 reset = 1;
    #5 reset = 0;

    
    #5; din_bit=0;
    #5; din_bit=0;
    #5; din_bit=1;
    #5; din_bit=1;
    #5; din_bit=0;
    #5; din_bit=1;
    #5; din_bit=0;
    #5; din_bit=0;

end

endmodule
