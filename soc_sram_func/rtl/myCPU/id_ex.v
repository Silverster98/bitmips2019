`include "defines.v"

module id_ex(
    input wire rst,
    input wire clk,
    input wire exception,
    input wire[3:0] stall,
    
    input wire[`INST_ADDR_BUS] id_pc,
    input wire[`GPR_BUS] id_rs_data,
    input wire[`GPR_BUS] id_rt_data,
    input wire[`INST_BUS] id_instr,
    input wire[`ALUOP_BUS] id_aluop,
    input wire[`GPR_ADDR_BUS] id_regfile_write_addr,
    input wire id_now_in_delayslot,
    input wire id_next_in_delayslot,
    input wire id_regfile_write_enable,
    input wire id_ram_write_enable,
    input wire id_hi_write_enable,
    input wire id_lo_write_enable,
    input wire id_cp0_write_enable,
    input wire id_mem_to_reg,
    input wire[`INST_ADDR_BUS] id_pc_return_addr,
    input wire[`GPR_BUS] id_hilo_data,
    input wire[`GPR_BUS] id_cp0_data,
    input wire[15:0] id_imm16,
    input wire[`EXCEP_TYPE_BUS] id_exception_type,
    input wire id_hilo_read_addr,
    input wire[`CP0_ADDR_BUS] id_cp0_read_addr,
    
    output reg[`INST_ADDR_BUS] ex_pc,
    output reg[`GPR_BUS] ex_rs_data,
    output reg[`GPR_BUS] ex_rt_data,
    output reg[`INST_BUS] ex_instr,
    output reg[`ALUOP_BUS] ex_aluop,
    output reg[`GPR_ADDR_BUS] ex_regfile_write_addr,
    output reg ex_now_in_delayslot,
    output reg ex_regfile_write_enable,
    output reg ex_ram_write_enable,
    output reg ex_hi_write_enable,
    output reg ex_lo_write_enable,
    output reg ex_cp0_write_enable,
    output reg[`GPR_BUS] ex_hilo_data,
    output reg[`GPR_BUS] ex_cp0_data,
    output reg ex_mem_to_reg,
    output reg[`INST_ADDR_BUS] ex_pc_return_addr,
    output reg[`GPR_BUS] ex_sign_extend_imm16,
    output reg[`GPR_BUS] ex_zero_extend_imm16,
    output reg[`GPR_BUS] ex_load_upper_imm16,
    output reg ex_hilo_read_addr,
    output reg[`CP0_ADDR_BUS] ex_cp0_read_addr,
    output reg ex_id_now_in_delayslot,
    output reg [`EXCEP_TYPE_BUS] ex_exception_type
    );
    
    wire inst_stall, id_stall, exe_stall, data_stall;
    assign inst_stall = stall[0];
    assign id_stall = stall[1];
    assign exe_stall = stall[2];
    assign data_stall = stall[3];
    
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE || exception == `EXCEPTION_ON || id_stall == 1'b1) begin
            ex_pc <= `ZEROWORD32;
            ex_rs_data <= `ZEROWORD32;
            ex_rt_data <= `ZEROWORD32;
            ex_instr <= `ZEROWORD32;
            ex_aluop <= 8'h00;
            ex_regfile_write_addr <= 5'b00000;
            ex_now_in_delayslot <= 1'b0;
            ex_exception_type <= `ZEROWORD32;
            ex_regfile_write_enable <= 1'b0;
            ex_ram_write_enable <= 1'b0;
            ex_hi_write_enable <= 1'b0;
            ex_lo_write_enable <= 1'b0;
            ex_cp0_write_enable <= 1'b0;
            ex_hilo_data <= `ZEROWORD32;
            ex_cp0_data <= `ZEROWORD32;
            ex_mem_to_reg <= 1'b0;
            ex_pc_return_addr <= `ZEROWORD32;
            ex_sign_extend_imm16 <= `ZEROWORD32;
            ex_zero_extend_imm16 <= `ZEROWORD32;
            ex_load_upper_imm16 <= `ZEROWORD32;
            ex_hilo_read_addr <= 1'b0;
            ex_cp0_read_addr <= 5'b00000;
            ex_id_now_in_delayslot <= 1'b0;
            ex_exception_type <= 6'h0;
        end else begin
            if (exe_stall == 1'b1) begin
            end else if (inst_stall == 1'b1) begin
                ex_pc <= `ZEROWORD32;
                ex_rs_data <= `ZEROWORD32;
                ex_rt_data <= `ZEROWORD32;
                ex_instr <= `ZEROWORD32;
                ex_aluop <= 8'h00;
                ex_regfile_write_addr <= 5'b00000;
                ex_now_in_delayslot <= 1'b0;
                ex_exception_type <= `ZEROWORD32;
                ex_regfile_write_enable <= 1'b0;
                ex_ram_write_enable <= 1'b0;
                ex_hi_write_enable <= 1'b0;
                ex_lo_write_enable <= 1'b0;
                ex_cp0_write_enable <= 1'b0;
                ex_hilo_data <= `ZEROWORD32;
                ex_cp0_data <= `ZEROWORD32;
                ex_mem_to_reg <= 1'b0;
                ex_pc_return_addr <= `ZEROWORD32;
                ex_sign_extend_imm16 <= `ZEROWORD32;
                ex_zero_extend_imm16 <= `ZEROWORD32;
                ex_load_upper_imm16 <= `ZEROWORD32;
                ex_hilo_read_addr <= 1'b0;
                ex_cp0_read_addr <= 5'b00000;
                ex_id_now_in_delayslot <= ex_id_now_in_delayslot; // delayslot signal need to stall
                ex_exception_type <= 6'h0;
            end else begin
                if (data_stall != 1'b1) begin
                    ex_pc <= id_pc;
                    ex_rs_data <= id_rs_data;
                    ex_rt_data <= id_rt_data;
                    ex_instr <= id_instr;
                    ex_aluop <= id_aluop;
                    ex_regfile_write_addr <= id_regfile_write_addr;
                    ex_now_in_delayslot <= id_now_in_delayslot;
                    ex_exception_type <= id_exception_type;
                    ex_regfile_write_enable <= id_regfile_write_enable;
                    ex_ram_write_enable <= id_ram_write_enable;
                    ex_hi_write_enable <= id_hi_write_enable;
                    ex_lo_write_enable <= id_lo_write_enable;
                    ex_cp0_write_enable <= id_cp0_write_enable;
                    ex_hilo_data <= id_hilo_data;
                    ex_cp0_data <= id_cp0_data;
                    ex_mem_to_reg <= id_mem_to_reg;
                    ex_pc_return_addr <= id_pc_return_addr;
                    ex_sign_extend_imm16 <= {{16{id_imm16[15]}}, id_imm16};
                    ex_zero_extend_imm16 <= {16'h0000, id_imm16};
                    ex_load_upper_imm16 <= {id_imm16, 16'h0000};
                    ex_hilo_read_addr <= id_hilo_read_addr;
                    ex_cp0_read_addr <= id_cp0_read_addr;
                    ex_id_now_in_delayslot <= id_next_in_delayslot;
                    ex_exception_type <= id_exception_type;
                end
            end
        end
    end
endmodule
