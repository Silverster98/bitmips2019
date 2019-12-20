`timescale 1ns / 1ps

`include "defines.vh"

module wb(
    input   wire[3:0]   stall,
    input   wire[31:0]  pc_i,
    input   wire[31:0]  instruction_i,
    input   wire[7:0]   aluop_i,
    input   wire        regfile_wen_i,
    input   wire[4:0]   regfile_waddr_i,
    input   wire[31:0]  alu_data_i,
    input   wire[31:0]  rt_data_i,
    input   wire[31:0]  mem_rdata_i,
    input   wire[31:0]  mem_addr_i,
    input   wire        mem_to_reg_i,
    
    output  wire        regfile_wen_o,
    output  wire[4:0]   regfile_waddr_o,
    output  wire[31:0]  regfile_wdata_o,
    
    output  wire[31:0]  debug_pc,
    output  wire[3:0]   debug_regfile_wen,
    output  wire[4:0]   debug_regfile_waddr,
    output  wire[31:0]  debug_regfile_wdata
    );
    
    wire data_stall = stall[0];
    
    assign regfile_wen_o = data_stall ? 1'b0 : regfile_wen_i;
    assign regfile_waddr_o = regfile_waddr_i;
    assign regfile_wdata_o = (mem_to_reg_i == 1'b0) ? alu_data_i : get_load_data(aluop_i, rt_data_i, mem_rdata_i, mem_addr_i);
function [31:0] get_load_data(input [7:0] aluop, input [31:0] rt_data, input [31:0] mem_rdata, input [31:0] mem_addr);
    begin
        case(aluop)
        `ALUOP_LB: begin
            case(mem_addr[1:0])
            2'b00: get_load_data = {{24{mem_rdata[7]}}, mem_rdata[7:0]};
            2'b01: get_load_data = {{24{mem_rdata[15]}}, mem_rdata[15:8]};
            2'b10: get_load_data = {{24{mem_rdata[23]}}, mem_rdata[23:16]};
            2'b11: get_load_data = {{24{mem_rdata[31]}}, mem_rdata[31:24]};
            default: get_load_data = 32'b0;
            endcase
        end
        `ALUOP_LBU: begin
            case(mem_addr[1:0])
            2'b00: get_load_data = {24'b0, mem_rdata[7:0]};
            2'b01: get_load_data = {24'b0, mem_rdata[15:8]};
            2'b10: get_load_data = {24'b0, mem_rdata[23:16]};
            2'b11: get_load_data = {24'b0, mem_rdata[31:24]};
            default: get_load_data = 32'b0;
            endcase
        end
        `ALUOP_LH: begin
            case(mem_addr[1])
            1'b0: get_load_data = {{16{mem_rdata[15]}}, mem_rdata[15:0]};
            1'b1: get_load_data = {{16{mem_rdata[31]}}, mem_rdata[31:16]};
            default: get_load_data = 32'b0;
            endcase
        end
        `ALUOP_LHU: begin
            case(mem_addr[1])
            1'b0: get_load_data = {16'b0, mem_rdata[15:0]};
            1'b1: get_load_data = {16'b0, mem_rdata[31:16]};
            default: get_load_data = 32'b0;
            endcase
        end
        `ALUOP_LW: begin
            get_load_data = mem_rdata;
        end
        `ALUOP_LWL: begin
            case(mem_addr[1:0])
            2'b00: get_load_data = {mem_rdata[7:0], rt_data[23:0]};
            2'b01: get_load_data = {mem_rdata[15:0], rt_data[15:0]};
            2'b10: get_load_data = {mem_rdata[23:0], rt_data[7:0]};
            2'b11: get_load_data = mem_rdata;
            default: get_load_data = 32'b0;
            endcase
        end
        `ALUOP_LWR: begin
            case(mem_addr[1:0])
            2'b00: get_load_data = mem_rdata;
            2'b01: get_load_data = {rt_data[31:24], mem_rdata[31:8]};
            2'b10: get_load_data = {rt_data[31:16], mem_rdata[31:16]};
            2'b11: get_load_data = {rt_data[31:8], mem_rdata[31:24]};
            default: get_load_data = 32'b0;
            endcase
        end
        default: get_load_data = 32'b0;
        endcase
    end
endfunction
    
    
    assign debug_pc = pc_i;
    assign debug_regfile_wen = data_stall ? 4'b0000 : {4{regfile_wen_i}};
    assign debug_regfile_waddr = regfile_waddr_o;
    assign debug_regfile_wdata = regfile_wdata_o;
endmodule
