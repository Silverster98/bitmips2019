`timescale 1ns / 1ps
`include "defines.v"

module mem_wb(
    input wire clk,
    input wire rst,
    input wire exception,
    input wire[3:0] stall,
    input wire mem_regfile_write_enable,
    input wire[`GPR_ADDR_BUS] mem_regfile_write_addr,
    input wire mem_hi_write_enable,
    input wire mem_lo_write_enable,
    input wire[`GPR_BUS] mem_hi_write_data,
    input wire[`GPR_BUS] mem_lo_write_data,
    input wire mem_cp0_write_enable,
    input wire[`CP0_ADDR_BUS] mem_cp0_write_addr,
    input wire[`GPR_BUS] mem_cp0_write_data,
    input wire[`GPR_BUS] mem_regfile_write_data,
    
    output reg wb_regfile_write_enable,
    output reg[`GPR_ADDR_BUS] wb_regfile_write_addr,
    output reg[`GPR_BUS] wb_regfile_write_data,
    output reg wb_hi_write_enable,
    output reg[`GPR_BUS] wb_hi_write_data,
    output reg wb_lo_write_enable,
    output reg[`GPR_BUS] wb_lo_write_data,
    output reg wb_cp0_write_enable,
    output reg[`CP0_ADDR_BUS] wb_cp0_write_addr,
    output reg[`GPR_BUS] wb_cp0_write_data,
    
    input wire[31:0] in_wb_pc,
    output reg[31:0] wb_pc
    );
    
    wire inst_stall, id_stall, exe_stall, data_stall;
    assign inst_stall = stall[0];
    assign id_stall = stall[1];
    assign exe_stall = stall[2];
    assign data_stall = stall[3];
    
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE || exception == `EXCEPTION_ON || data_stall == 1'b1) begin
            wb_regfile_write_enable <= 1'b0;
            wb_regfile_write_addr <= `ZEROWORD5;
            wb_regfile_write_data <= `ZEROWORD32;
            wb_hi_write_enable <= 1'b0;
            wb_hi_write_data <= `ZEROWORD32;
            wb_lo_write_enable <= 1'b0;
            wb_lo_write_data <= `ZEROWORD32;
            wb_cp0_write_enable <= 1'b0;
            wb_cp0_write_addr <= `ZEROWORD5;
            wb_cp0_write_data <= `ZEROWORD32;
            wb_pc <= `ZEROWORD32;
        end else begin
            wb_regfile_write_enable <= mem_regfile_write_enable;
            wb_regfile_write_addr <= mem_regfile_write_addr;
            wb_regfile_write_data <= mem_regfile_write_data;
            wb_hi_write_enable <= mem_hi_write_enable;
            wb_hi_write_data <= mem_hi_write_data;
            wb_lo_write_enable <= mem_lo_write_enable;
            wb_lo_write_data <= mem_lo_write_data;
            wb_cp0_write_enable <= mem_cp0_write_enable;
            wb_cp0_write_addr <= mem_cp0_write_addr;
            wb_cp0_write_data <= mem_cp0_write_data;
            wb_pc <= in_wb_pc;
        end
    end
endmodule
