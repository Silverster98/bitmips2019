`timescale 1ns / 1ps

`include "defines.vh"

module id_ex(
    input   wire        clk,
    input   wire        rst,
    input   wire        exception,
    input   wire[3:0]   stall,
    
    input   wire[31:0]  pc_i,
    input   wire[31:0]  exception_type_i,
    input   wire[31:0]  instruction_i,
    input   wire        next_in_delayslot_i,
    input   wire        in_delayslot_i,
    input   wire[7:0]   aluop_i,
    input   wire        regfile_wen_i,
    input   wire[4:0]   regfile_waddr_i,
    input   wire        hi_wen_i,
    input   wire        lo_wen_i,
    input   wire        hilo_addr_i,
    input   wire        mem_en_i,
    input   wire        mem_to_reg_i,
    input   wire        cp0_wen_i,
    input   wire[4:0]   cp0_addr_i,
    input   wire[2:0]   cp0_sel_i,
    input   wire[31:0]  rs_data_i,
    input   wire[31:0]  rt_data_i,
    
    output  reg [31:0]  pc_o,
    output  reg [31:0]  exception_type_o,
    output  reg [31:0]  instruction_o,
    output  reg         next_in_delayslot_o,
    output  reg         in_delayslot_o,
    output  reg [7:0]   aluop_o,
    output  reg         regfile_wen_o,
    output  reg [4:0]   regfile_waddr_o,
    output  reg         hi_wen_o,
    output  reg         lo_wen_o,
    output  reg         hilo_addr_o,
    output  reg         mem_en_o,
    output  reg         mem_to_reg_o,
    output  reg         cp0_wen_o,
    output  reg [4:0]   cp0_addr_o,
    output  reg [2:0]   cp0_sel_o,
    output  reg [31:0]  rs_data_o,
    output  reg [31:0]  rt_data_o
    );
    
    wire inst_stall = stall[3];
    wire id_stall = stall[2];
    wire ex_stall = stall[1];
    wire data_stall = stall[0];
    
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE) begin
            pc_o <= 32'b0;
            exception_type_o <= 32'b0;
            instruction_o <= 32'b0;
            next_in_delayslot_o <= 1'b0;
            in_delayslot_o <= 1'b0;
            aluop_o <= 8'b0;
            regfile_wen_o <= 1'b0;
            regfile_waddr_o <= 5'b0;
            hi_wen_o <= 1'b0;
            lo_wen_o <= 1'b0;
            hilo_addr_o <= 1'b0;
            mem_en_o <= 1'b0;
            mem_to_reg_o <= 1'b0;
            cp0_wen_o <= 1'b0;
            cp0_addr_o <= 5'b0;
            cp0_sel_o <= 3'b0;
            rs_data_o <= 32'b0;
            rt_data_o <= 32'b0;
        end else if (exception == 1'b1) begin
            pc_o <= 32'b0;
            exception_type_o <= 32'b0;
            instruction_o <= 32'b0;
            next_in_delayslot_o <= 1'b0;
            in_delayslot_o <= 1'b0;
            aluop_o <= 8'b0;
            regfile_wen_o <= 1'b0;
            regfile_waddr_o <= 5'b0;
            hi_wen_o <= 1'b0;
            lo_wen_o <= 1'b0;
            hilo_addr_o <= 1'b0;
            mem_en_o <= 1'b0;
            mem_to_reg_o <= 1'b0;
            cp0_wen_o <= 1'b0;
            cp0_addr_o <= 5'b0;
            cp0_sel_o <= 3'b0;
            rs_data_o <= 32'b0;
            rt_data_o <= 32'b0;
        end else begin
            if (ex_stall || data_stall) begin // do nothing
            end else if (inst_stall || id_stall) begin
                pc_o <= 32'b0;
                exception_type_o <= 32'b0;
                instruction_o <= 32'b0;
//                next_in_delayslot_o <= 1'b0;
                in_delayslot_o <= 1'b0;
                aluop_o <= 8'b0;
                regfile_wen_o <= 1'b0;
                regfile_waddr_o <= 5'b0;
                hi_wen_o <= 1'b0;
                lo_wen_o <= 1'b0;
                hilo_addr_o <= 1'b0;
                mem_en_o <= 1'b0;
                mem_to_reg_o <= 1'b0;
                cp0_wen_o <= 1'b0;
                cp0_addr_o <= 5'b0;
                cp0_sel_o <= 3'b0;
                rs_data_o <= 32'b0;
                rt_data_o <= 32'b0;
            end else begin
                pc_o <= pc_i;
                exception_type_o <= exception_type_i;
                instruction_o <= instruction_i;
                next_in_delayslot_o <= next_in_delayslot_i;
                in_delayslot_o <= in_delayslot_i;
                aluop_o <= aluop_i;
                regfile_wen_o <= regfile_wen_i;
                regfile_waddr_o <= regfile_waddr_i;
                hi_wen_o <= hi_wen_i;
                lo_wen_o <= lo_wen_i;
                hilo_addr_o <= hilo_addr_i;
                mem_en_o <= mem_en_i;
                mem_to_reg_o <= mem_to_reg_i;
                cp0_wen_o <= cp0_wen_i;
                cp0_addr_o <= cp0_addr_i;
                cp0_sel_o <= cp0_sel_i;
                rs_data_o <= rs_data_i;
                rt_data_o <= rt_data_i;
            end
        end
    end
endmodule
