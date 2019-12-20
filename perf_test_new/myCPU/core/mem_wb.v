`timescale 1ns / 1ps

`include "defines.vh"

module mem_wb(
    input   wire        clk,
    input   wire        rst,
    input   wire        exception,
    input   wire[3:0]   stall,
    
    input   wire[31:0]  pc_i,
    input   wire[31:0]  instruction_i,
    input   wire[7:0]   aluop_i,
    input   wire        regfile_wen_i,
    input   wire[4:0]   regfile_waddr_i,
    input   wire[31:0]  alu_data_i,
    input   wire[31:0]  rt_data_i,
    input   wire        mem_to_reg_i,
    input   wire[31:0]  mem_addr_i,
    
    output  reg [31:0]  pc_o,
    output  reg [31:0]  instruction_o,
    output  reg [7:0]   aluop_o,
    output  reg         regfile_wen_o,
    output  reg [4:0]   regfile_waddr_o,
    output  reg [31:0]  alu_data_o,
    output  reg [31:0]  rt_data_o,
    output  reg         mem_to_reg_o,
    output  reg [31:0]  mem_addr_o
    );
    
    wire inst_stall = stall[3];
    wire id_stall = stall[2];
    wire ex_stall = stall[1];
    wire data_stall = stall[0];
    
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE) begin
            pc_o <= 32'b0;
            instruction_o <= 32'b0;
            aluop_o <= 8'b0;
            regfile_wen_o <= 1'b0;
            regfile_waddr_o <= 5'b0;
            alu_data_o <= 32'b0;
            rt_data_o <= 32'b0;
            mem_to_reg_o <= 1'b0;
            mem_addr_o <= 32'b0;
        end else begin
            if (data_stall) begin
            end else begin
                if (exception) begin
                    pc_o <= 32'b0;
                    instruction_o <= 32'b0;
                    aluop_o <= 8'b0;
                    regfile_wen_o <= 1'b0;
                    regfile_waddr_o <= 5'b0;
                    alu_data_o <= 32'b0;
                    rt_data_o <= 32'b0;
                    mem_to_reg_o <= 1'b0;
                    mem_addr_o <= 32'b0;
                end else begin
                    pc_o <= pc_i;
                    instruction_o <= instruction_i;
                    aluop_o <= aluop_i;
                    regfile_wen_o <= regfile_wen_i;
                    regfile_waddr_o <= regfile_waddr_i;
                    alu_data_o <= alu_data_i;
                    rt_data_o <= rt_data_i;
                    mem_to_reg_o <= mem_to_reg_i;
                    mem_addr_o <= mem_addr_i;
                end
            end
        end
    end
endmodule
