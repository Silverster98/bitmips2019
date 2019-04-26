`timescale 1ns / 1ps

module pc(
    input wire rst,
    input wire clk,
    input wire stall,
    input wire exception,
    input wire[31:0] exception_pc_i,
    input wire branch_enable_i,
    input wire[31:0] branch_addr_i,
    
    output reg[31:0] pc_o
//    output reg cs_o
    );
    
    always @ (posedge clk) begin
        if (rst == 1'b1) begin
            pc_o <= 32'h00000000;
        end else begin
            if (exception == 1'b1) begin
                pc_o <= exception_pc_i;
            end else if (stall == 1'b0) begin
                if (branch_enable_i == 1'b1) begin
                    pc_o <= branch_addr_i;
                end else begin
                    pc_o <= pc_o + 4;
                end
            end
        end
    end
endmodule
