`timescale 1ns / 1ps

module testbench();

    reg rst;
    reg clk;
    
    mips_top mymips_test(
        .clk(clk),
        .rst(rst)
    );
    
    initial begin
        clk = 0;
        rst = 1;
        #37 rst = 0;
        #2000 $stop;
    end
    
    always #10 clk = ~clk;
endmodule
