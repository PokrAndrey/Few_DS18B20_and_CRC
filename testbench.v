`timescale 1 ns / 100 ps
module test_counter;

reg clk=1'b0; 
wire signal = 0;
reg reg_signal=1'b0;
reg [15:0]count = 0;
assign signal = reg_signal;

top_level top_level( .local_clk(clk), .local_signal(signal));
/*
always
begin
reg_signal = 0;
#8000;
reg_signal = 1;
count = count + 1;
#1000;
reg_signal = ((count > 8) & ((count == 9) | (count == 15))) ? 1 : 0;
#14000;
reg_signal = 0;
#38000;
end*/

always
begin
#10 clk=~clk;
end


initial
begin
    $dumpvars;
    #10340000 $finish;
end
endmodule
