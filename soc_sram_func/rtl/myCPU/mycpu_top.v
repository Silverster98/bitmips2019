`timescale 1ns / 1ps
module mycpu_top(
input wire clk,
input wire resetn,
input wire[5:0] int,

output wire inst_sram_en,
output wire[3:0] inst_sram_wen,
output wire[31:0] inst_sram_addr,
output wire[31:0] inst_sram_wdata,
input wire[31:0] inst_sram_rdata,

output wire data_sram_en,
output wire[3:0] data_sram_wen,
output wire[31:0] data_sram_addr,
output wire[31:0] data_sram_wdata,
input wire[31:0] data_sram_rdata,

output wire[31:0] debug_wb_pc,
output wire[3:0]  debug_wb_rf_wen,
output wire[4:0]  debug_wb_rf_wnum,
output wire[31:0] debug_wb_rf_wdata
);

mips_top mips_core(
    
);

endmodule
