`timescale 1ns / 1ps

`include "defines.vh"

module mem(
    input   wire        exception_i,
    input   wire[31:0]  pc_i,
    input   wire[31:0]  exception_type_i,
    input   wire[31:0]  instruction_i,
    input   wire[7:0]   aluop_i,
    input   wire        regfile_wen_i,
    input   wire[4:0]   regfile_waddr_i,
    input   wire        mem_en_i,
    input   wire        mem_to_reg_i,
    input   wire[31:0]  alu_data_i,
    input   wire[31:0]  rt_data_i,
    input   wire        data_paddr_refill_i,
    input   wire        data_paddr_invalid_i,
    input   wire        data_paddr_modify_i,
    
    output  wire[31:0]  pc_o,
    output  wire[31:0]  exception_type_o,
    output  wire[31:0]  instruction_o,
    output  wire[7:0]   aluop_o,
    output  wire        regfile_wen_o,
    output  wire[4:0]   regfile_waddr_o,
    output  wire[31:0]  alu_data_o,
    output  wire        mem_to_reg_o,
    output  wire[31:0]  rt_data_o,
    
    output  wire        mem_en_o,
    output  wire[3:0]   mem_wen_o,
    output  wire[31:0]  mem_wdata_o,
    output  wire[31:0]  mem_addr_o
    );
    
    assign pc_o = pc_i;
    assign instruction_o = instruction_i;
    assign aluop_o = aluop_i;
    assign regfile_wen_o = regfile_wen_i;
    assign regfile_waddr_o = regfile_waddr_i;
    assign alu_data_o = alu_data_i;
    assign mem_to_reg_o = mem_to_reg_i;
    assign rt_data_o = rt_data_i;
    
    assign mem_addr_o = alu_data_i;
    assign mem_en_o = exception_i ? 1'b0 : mem_en_i;
    assign mem_wen_o = get_mem_wen_o(aluop_i, mem_addr_o);
function [3:0] get_mem_wen_o(input [7:0] aluop, input [31:0] mem_addr);
    begin
        case(aluop)
        `ALUOP_SB: begin
            case(mem_addr[1:0])
            2'b00: get_mem_wen_o = 4'b0001;
            2'b01: get_mem_wen_o = 4'b0010;
            2'b10: get_mem_wen_o = 4'b0100;
            2'b11: get_mem_wen_o = 4'b1000;
            default: get_mem_wen_o = 4'b0000;
            endcase
        end
        `ALUOP_SH: begin
            get_mem_wen_o = mem_addr[1] == 1'b0 ? 4'b0011 : 4'b1100;
        end
        `ALUOP_SW: get_mem_wen_o = 4'b1111;
        `ALUOP_SWL: begin
            case(mem_addr[1:0])
            2'b00: get_mem_wen_o = 4'b0001;
            2'b01: get_mem_wen_o = 4'b0011;
            2'b10: get_mem_wen_o = 4'b0111;
            2'b11: get_mem_wen_o = 4'b1111;
            default: get_mem_wen_o = 4'b0000;
            endcase
        end 
        `ALUOP_SWR: begin
            case(mem_addr[1:0])
            2'b00: get_mem_wen_o = 4'b1111;
            2'b01: get_mem_wen_o = 4'b1110;
            2'b10: get_mem_wen_o = 4'b1100;
            2'b11: get_mem_wen_o = 4'b1000;
            default: get_mem_wen_o = 4'b0000;
            endcase
        end
        default: get_mem_wen_o = 4'b0000;
        endcase
    end
endfunction

    assign mem_wdata_o = get_mem_wdata_o(aluop_i, rt_data_i, mem_addr_o);
function [31:0] get_mem_wdata_o(input [7:0] aluop, input [31:0] rt_data, input [31:0] mem_addr);
begin
    case(aluop)
    `ALUOP_SB: begin
        get_mem_wdata_o = {rt_data[7:0], rt_data[7:0], rt_data[7:0], rt_data[7:0]};
    end
    `ALUOP_SH: begin
        get_mem_wdata_o = {rt_data[15:0], rt_data[15:0]};
    end
    `ALUOP_SW: begin
        get_mem_wdata_o = rt_data;
    end
    `ALUOP_SWL: begin
        case(mem_addr[1:0])
        2'b00: get_mem_wdata_o = {24'b0, rt_data[31:24]};
        2'b01: get_mem_wdata_o = {16'b0, rt_data[31:16]};
        2'b10: get_mem_wdata_o = {8'b0,  rt_data[31:8]};
        2'b11: get_mem_wdata_o = rt_data;
        default: get_mem_wdata_o = 32'b0;
        endcase
    end
    `ALUOP_SWR: begin
        case(mem_addr[1:0])
        2'b00: get_mem_wdata_o = rt_data;
        2'b01: get_mem_wdata_o = {rt_data[23:0], 8'b0};
        2'b10: get_mem_wdata_o = {rt_data[15:0], 16'b0};
        2'b11: get_mem_wdata_o = {rt_data[7:0],  24'b0};
        default: get_mem_wdata_o = 32'b0;
        endcase
    end
    default: get_mem_wdata_o = 32'b0;
    endcase
end
endfunction

    wire is_mem_ADE;
    assign exception_type_o = {exception_type_i[31:23], is_mem_ADE, data_paddr_refill_i, data_paddr_invalid_i, data_paddr_modify_i, 
                               exception_type_i[18:0]};
    
    assign is_mem_ADE = get_is_mem_ADE(aluop_i, mem_addr_o);
function get_is_mem_ADE(input [7:0] aluop, input [31:0] mem_addr);
    begin
        case(aluop)
        `ALUOP_SH, `ALUOP_LH, `ALUOP_LHU: begin
            get_is_mem_ADE = mem_addr[0] == 1'b0 ? 1'b0 : 1'b1;
        end
        `ALUOP_SW, `ALUOP_LW: begin
            get_is_mem_ADE = mem_addr[1:0] == 2'b00 ? 1'b0 : 1'b1;
        end
        default: get_is_mem_ADE = 1'b0;
        endcase
    end
endfunction
endmodule
