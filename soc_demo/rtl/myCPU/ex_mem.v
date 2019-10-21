`include "defines.v"

module ex_mem(
    input wire rst,
    input wire clk,
    input wire exception,
    input wire[3:0] stall,
    
    input wire[`INST_ADDR_BUS] exe_pc,
    input wire[`ALUOP_BUS] exe_aluop,
    input wire exe_now_in_delayslot,
    input wire[`EXCEP_TYPE_BUS] exe_exception_type,
    input wire exe_regfile_write_enable,
    input wire exe_ram_write_enable,
    input wire exe_hi_write_enable,
    input wire exe_lo_write_enable,
    input wire exe_cp0_write_enable,
    input wire[`GPR_ADDR_BUS] exe_regfile_write_addr,
    input wire[`CP0_ADDR_BUS] exe_cp0_write_addr,
    input wire[`GPR_BUS] exe_alu_data,
    input wire[`GPR_BUS] exe_ram_write_data,
    input wire[`GPR_BUS] exe_hi_write_data,
    input wire[`GPR_BUS] exe_lo_write_data,
    input wire[`GPR_BUS] exe_cp0_write_data,
    input wire exe_mem_to_reg,
    input wire[2:0] exe_sel,
    
    output reg[`INST_ADDR_BUS] mem_pc,
    output reg[`ALUOP_BUS] mem_aluop,
    output reg mem_now_in_delayslot,
    output reg[`EXCEP_TYPE_BUS] mem_exception_type,
    output reg mem_regfile_write_enable,
    output reg mem_ram_write_enable,
    output reg mem_hi_write_enable,
    output reg mem_lo_write_enable,
    output reg mem_cp0_write_enable,
    output reg[`GPR_ADDR_BUS] mem_regfile_write_addr,
    output reg[`RAM_ADDR_BUS] mem_ram_write_addr,
    output reg[`CP0_ADDR_BUS] mem_cp0_write_addr,
    output reg[`GPR_BUS] mem_alu_data,
    output reg[`GPR_BUS] mem_ram_write_data,
    output reg[`GPR_BUS] mem_hi_write_data,
    output reg[`GPR_BUS] mem_lo_write_data,
    output reg[`GPR_BUS] mem_cp0_write_data,
    output reg mem_mem_to_reg,
    output reg[`RAM_ADDR_BUS] mem_ram_read_addr,
    output reg[2:0] mem_sel,
    
    input wire[31:0] exe_rt_data,
    output reg[31:0] mem_rt_data
    );
    
    wire inst_stall, id_stall, exe_stall, data_stall;
    assign inst_stall = stall[0];
    assign id_stall = stall[1];
    assign exe_stall = stall[2];
    assign data_stall = stall[3];
    
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE || exception == `EXCEPTION_ON || exe_stall == 1'b1) begin
            mem_pc <= `ZEROWORD32;
            mem_aluop <= 8'h00;
            mem_now_in_delayslot <= 1'b0;
            mem_exception_type <= `ZEROWORD32;
            mem_regfile_write_enable <= 1'b0;
            mem_ram_write_enable <= 1'b0;
            mem_hi_write_enable <= 1'b0;
            mem_lo_write_enable <= 1'b0;
            mem_cp0_write_enable <= 1'b0;
            mem_regfile_write_addr <= `ZEROWORD5;
            mem_ram_write_addr <= `ZEROWORD32;
            mem_cp0_write_addr <= `ZEROWORD32;
            mem_alu_data <= `ZEROWORD32;
            mem_ram_write_data <= `ZEROWORD32;
            mem_hi_write_data <= `ZEROWORD32;
            mem_lo_write_data <= `ZEROWORD32;
            mem_cp0_write_data <= `ZEROWORD32;
            mem_mem_to_reg <= 1'b0;
            mem_ram_read_addr <= `ZEROWORD32;
            mem_sel <= 3'b0;
            mem_rt_data <= 32'b0;
        end else begin
            if (data_stall == 1'b0) begin
                mem_pc <= exe_pc;
                mem_aluop <= exe_aluop;
                mem_now_in_delayslot <= exe_now_in_delayslot;
                mem_exception_type <= exe_exception_type;
                mem_regfile_write_enable <= exe_regfile_write_enable;
                mem_ram_write_enable <= exe_ram_write_enable;
                mem_hi_write_enable <= exe_hi_write_enable;
                mem_lo_write_enable <= exe_lo_write_enable;
                mem_cp0_write_enable <= exe_cp0_write_enable;
                mem_regfile_write_addr <= exe_regfile_write_addr;
                mem_ram_write_addr <= exe_alu_data;
                mem_cp0_write_addr <= exe_cp0_write_addr;
                mem_alu_data <= exe_alu_data;
                mem_ram_write_data <= exe_ram_write_data;
                mem_hi_write_data <= exe_hi_write_data;
                mem_lo_write_data <= exe_lo_write_data;
                mem_cp0_write_data <= exe_cp0_write_data;
                mem_mem_to_reg <= exe_mem_to_reg;
                mem_ram_read_addr <= exe_alu_data;
                mem_sel <= exe_sel;
                mem_rt_data <= exe_rt_data;
            end
        end
    end
endmodule
