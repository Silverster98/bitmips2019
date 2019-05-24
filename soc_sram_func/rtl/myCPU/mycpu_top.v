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
assign inst_sram_en = (resetn == `RST_ENABLE) ? 1'b0 : 1'b1;
assign inst_sram_wen = (resetn == `RST_ENABLE) ? 4'b0000 : 4'b1111;

assign data_sram_en = (resetn == `RST_ENABLE) ? 1'b0 : 1'b1;

assign debug_wb_pc = `ZEROWORD32;
assign debug_wb_rf_wen = 1'b0;
assign debug_wb_rf_wnum = 1'b0;
assign debug_wb_rf_wdata = 32'b0;

wire time_int_out;

mips_top mips_core(
.clk(clk),
.rst(resetn),
.int({time_int_out || int[5],int[4:0]}),
.time_int_out(time_int_out),
.inst_sram_addr(inst_sram_addr),
.inst_sram_rdata(inst_sram_rdata),

.data_sram_wen(data_sram_wen),
.data_sram_addr(data_sram_addr),
.data_sram_wdata(data_sram_wdata),
.data_sram_rdata(inst_sram_rdata)
);
endmodule
