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
assign inst_sram_wen = 4'b0000;

assign data_sram_en = (resetn == `RST_ENABLE) ? 1'b0 : 1'b1;

wire time_int_out;
wire[31:0] _data_ram_addr;

reg[31:0] inst_addr;
reg[31:0] data_addr;
reg inst_stall, data_stall;
wire data_sram_read_enable;

assign data_sram_addr = (_data_ram_addr[31:30] == 2'b11) ? _data_ram_addr : {3'b000, _data_ram_addr[28:0]}; // mmu

mips_top mips_core(
.clk(clk),
.rst(resetn),
.interrupt({time_int_out || int[5],int[4:0]}),
.time_int_out(time_int_out),
.inst_sram_addr(inst_sram_addr),
.inst_sram_rdata(inst_sram_rdata),

.data_sram_read_enable(data_sram_read_enable),
.data_sram_wen(data_sram_wen),
.data_sram_addr(_data_ram_addr),
.data_sram_wdata(data_sram_wdata),
.data_sram_rdata(data_sram_rdata),

.debug_wb_pc(debug_wb_pc),
.debug_wb_wen(debug_wb_rf_wen),
.debug_wb_num(debug_wb_rf_wnum),
.debug_wb_data(debug_wb_rf_wdata),

.inst_stall(inst_stall),
.data_stall(data_stall)
);

always @ (negedge clk) begin
    if (resetn == `RST_ENABLE) begin
        inst_addr <= 32'b0;
        inst_stall <= 1'b0;
    end else begin
        if (inst_addr != inst_sram_addr) begin
            inst_addr <= inst_sram_addr;
            inst_stall <= 1'b1;
        end else begin
            inst_stall <= 1'b0;
        end
    end
end

always @ (negedge clk) begin
    if (resetn == `RST_ENABLE) begin
        data_addr <= 32'b0;
        data_stall <= 1'b0;
    end else begin
        if (data_addr != data_sram_addr && data_sram_read_enable == 1'b1) begin
            data_addr <= data_sram_addr;
            data_stall <= 1'b1;
        end else begin
            data_stall <= 1'b0;
            data_addr <= `ZEROWORD32;
        end
    end
end

endmodule
