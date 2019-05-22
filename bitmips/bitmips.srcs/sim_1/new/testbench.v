`timescale 1ns / 1ps

module testbench();

    reg rst;
    reg clk;
    wire[5:0] interrupt;
    wire time_int;
    
    mips_top mymips_test(
        .clk(clk),
        .rst(rst),
        .interrupt(interrupt),
        .time_int_out(time_int)
    );
    
    assign interrupt[0] = time_int;
    
    initial begin
        clk = 0;
        rst = 1;
        #37 rst = 0;
        #2000 $stop;
    end
    
    always #10 clk = ~clk;
endmodule
