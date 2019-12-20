`timescale 1ns / 1ps

`include "defines.vh"

module pc(
    input   wire        rst,
    input   wire        clk,
    input   wire        exception,
    input   wire[31:0]  exception_pc,
    input   wire        branch,
    input   wire[31:0]  branch_pc,
    
    output  reg [31:0]  pc,
    output  wire[31:0]  exception_type,
    
    input   wire[3:0]   stall,
    
    input   wire        inst_paddr_refill,
    input   wire        inst_paddr_invalid
    );
    
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE) begin
            pc <= 32'hbfc0_0000;
        end else if (exception == 1'b1) begin
            pc <= exception_pc;
        end else begin
            if (branch == 1'b1) begin
                if (stall == 4'b0000) pc <= branch_pc;
            end else begin
                if (stall == 4'b0000) pc <= pc + 4;
            end
        end 
    end
    
    wire non_word_aligned = (pc[1:0] == 2'b00) ? 1'b0 : 1'b1;
    
    assign exception_type = {1'b0, non_word_aligned, inst_paddr_refill, inst_paddr_invalid, 28'b0};
    
endmodule
