`include "defines.v"

module mips_top(
    input   wire        clk,
    input   wire        rst,
    
    input   wire[5:0]   interrupt,
    output  wire        time_int_out,
    output  [31:0]      inst_sram_addr,
    input   [31:0]      inst_sram_rdata,
    
    output              data_sram_ren,
    output  [3:0]       data_sram_wen,
    output  [31:0]      data_sram_addr,
    output  [31:0]      data_sram_wdata,
    input   [31:0]      data_sram_rdata,
    
    output  [31:0]      debug_wb_pc,
    output  [3:0]       debug_wb_wen,
    output  [4:0]       debug_wb_num,
    output  [31:0]      debug_wb_data,
    
    input   wire        inst_stall,
    input   wire        data_stall,
    output              flush
    );
    
    wire[`INST_ADDR_BUS] if_pc_if_id;
    wire[`EXCEP_TYPE_BUS] if_exception_type_if_id;
    wire[`INST_BUS] rom_instr_if_id;
    
    wire[`INST_BUS] if_id_instr_id;
    wire[`INST_ADDR_BUS] if_id_pc_id;
    wire[`EXCEP_TYPE_BUS] if_id_exception_type_id;
    
    wire[`GPR_BUS] regfile_rs_data_id, regfile_rt_data_id;
    wire[`INST_ADDR_BUS] id_pc_id_ex;
    wire[`INST_BUS] id_instr_id_ex;
    wire[`GPR_BUS] id_rs_data_id_ex, id_rt_data_id_ex;
    wire[`ALUOP_BUS] id_aluop_id_ex;
    wire[`GPR_ADDR_BUS] id_regfile_write_addr_id_ex;
    wire id_now_in_delayslot_id_ex, id_next_in_delayslot_id_ex;
    wire id_stall_request;
    wire id_regfile_write_enable_id_ex, id_ram_write_enable_id_ex, id_hi_write_enable_id_ex, id_lo_write_enable_id_ex, id_cp0_write_enable_id_ex;
    wire id_mem_to_reg_id_ex;
    wire[`INST_ADDR_BUS] id_pc_return_addr_id_ex;
    wire[`CP0_ADDR_BUS] id_cp0_read_addr_id_ex;
    wire id_hilo_read_addr_id_ex;
    wire[15:0] id_imm16_id_ex;
    wire[`EXCEP_TYPE_BUS] id_exception_type_id_ex;
    wire id_branch_enable;
    wire[`INST_ADDR_BUS] id_branch_addr;
    
    wire[`GPR_BUS] hilo_data_id_ex, cp0_data_id_ex;
    wire[`INST_ADDR_BUS] id_ex_pc_ex;
    wire[`GPR_BUS] id_ex_rs_data_ex, id_ex_rt_data_ex;
    wire[`INST_BUS] id_ex_instr_ex;
    wire[`ALUOP_BUS] id_ex_aluop_ex;
    wire[`GPR_ADDR_BUS] id_ex_regfile_write_addr_ex;
    wire id_ex_now_in_delayslot_ex;
    wire[`EXCEP_TYPE_BUS] id_ex_exception_type_ex;
    wire id_ex_regfile_write_enable_ex, id_ex_ram_write_enable_ex, id_ex_hi_write_enable_ex, id_ex_lo_write_enable_ex, id_ex_cp0_write_enable_ex;
    wire[`GPR_BUS] id_ex_hilo_data_ex, id_ex_cp0_data_ex;
    wire id_ex_mem_to_reg_ex;
    wire[`INST_ADDR_BUS] id_ex_pc_return_addr_ex;
    wire[`GPR_BUS] id_ex_sign_extend_imm16_ex;
    wire[`GPR_BUS] id_ex_zero_extend_imm16_ex;
    wire[`GPR_BUS] id_ex_load_upper_imm16_ex;
    wire id_ex_hilo_read_addr_ex;
    wire[`CP0_ADDR_BUS] id_ex_cp0_read_addr_ex;
    wire exe_id_now_in_delayslot;
    
    wire[`INST_ADDR_BUS] ex_pc_ex_mem;
    wire[`ALUOP_BUS] ex_aluop_ex_mem;
    wire ex_now_in_delayslot_ex_mem;
    wire[`EXCEP_TYPE_BUS] ex_exception_type_ex_mem;
    wire ex_regfile_write_enable_ex_mem, ex_ram_write_enable_ex_mem, ex_hi_write_enable_ex_mem, ex_lo_write_enable_ex_mem, ex_cp0_write_enable_ex_mem;
    wire[`GPR_ADDR_BUS] ex_regfile_write_addr_ex_mem;
    wire[`CP0_ADDR_BUS] ex_cp0_write_addr_ex_mem;
    wire[`GPR_BUS] ex_alu_data_ex_mem;
    wire[`GPR_BUS] ex_ram_write_data_ex_mem;
    wire[`GPR_BUS] ex_hi_write_data_ex_mem;
    wire[`GPR_BUS] ex_lo_write_data_ex_mem;
    wire[`GPR_BUS] ex_cp0_write_data_ex_mem;
    wire ex_mem_to_reg_ex_mem;
    wire exe_stall_request;
    
    wire[`INST_ADDR_BUS] ex_mem_pc_mem;
    wire[`ALUOP_BUS] ex_mem_aluop_mem;
    wire ex_mem_now_in_delayslot_mem;
    wire[`EXCEP_TYPE_BUS] ex_mem_exception_type_mem;
    wire ex_mem_regfile_write_enable_mem, ex_mem_ram_write_enable_mem, ex_mem_hi_write_enable_mem, ex_mem_lo_write_enable_mem, ex_mem_cp0_write_enable_mem;
    wire[`GPR_ADDR_BUS] ex_mem_regfile_write_addr_mem;
    wire[`RAM_ADDR_BUS] ex_mem_ram_write_addr_mem;
    wire[`CP0_ADDR_BUS] ex_mem_cp0_write_addr_mem;
    wire[`GPR_BUS] ex_mem_alu_data_mem;
    wire[`GPR_BUS] ex_mem_ram_write_data_mem;
    wire[`GPR_BUS] ex_mem_hi_write_data_mem;
    wire[`GPR_BUS] ex_mem_lo_write_data_mem;
    wire[`GPR_BUS] ex_mem_cp0_write_data_mem;
    wire ex_mem_mem_to_reg_mem;
    wire[`RAM_ADDR_BUS] ex_mem_ram_read_addr_mem;
    
    wire[`INST_ADDR_BUS] mem_store_pc;
    wire[`RAM_ADDR_BUS] mem_access_mem_addr;
    wire mem_now_in_delayslot;
    wire[`EXCEP_TYPE_BUS] mem_exception_type;
    wire mem_regfile_write_enable_mem_wb;
    wire[`GPR_ADDR_BUS] mem_regfile_write_addr_mem_wb;
    wire mem_hi_write_enable_mem_wb;
    wire mem_lo_write_enable_mem_wb;
    wire[`GPR_BUS] mem_hi_write_data_mem_wb;
    wire[`GPR_BUS] mem_lo_write_data_mem_wb;
    wire mem_cp0_write_enable;
    wire[`CP0_ADDR_BUS] mem_cp0_write_addr;
    wire[`GPR_BUS] mem_cp0_write_data;
    wire[`GPR_BUS] mem_regfile_write_data_mem_wb;
    wire[3:0] mem_ram_write_select;
    wire mem_ram_write_enable;
    wire mem_ram_read_enable;
    wire[`RAM_ADDR_BUS] mem_ram_write_addr;
    wire[`GPR_BUS] mem_ram_write_data;
    wire[`RAM_ADDR_BUS] mem_ram_read_addr;
    
    wire[`GPR_BUS] ram_read_data;
    
    wire mem_wb_regfile_write_enable;
    wire[`GPR_ADDR_BUS] mem_wb_regfile_write_addr;
    wire[`GPR_BUS] mem_wb_regfile_write_data;
    wire mem_wb_hi_write_enable, mem_wb_lo_write_enable;
    wire[`GPR_BUS] mem_wb_hi_write_data, mem_wb_lo_write_data;
    
    
    wire is_exception;
    wire [`INST_ADDR_BUS] cp0_return_pc;
    
    assign inst_sram_addr = if_pc_if_id;
    assign rom_instr_if_id = inst_sram_rdata;
    
    assign data_sram_ren  = mem_ram_read_enable;
    assign data_sram_wen = mem_ram_write_enable ? mem_ram_write_select : 4'b0000;
    assign data_sram_addr = mem_ram_write_enable ? mem_ram_write_addr : mem_ram_read_addr;
    assign data_sram_wdata = mem_ram_write_data;
    assign ram_read_data = data_sram_rdata;
    
    wire stall_all;
    assign stall_all = data_stall || exe_stall_request || inst_stall;
    assign debug_wb_wen = ((rst == `RST_ENABLE || stall_all == 1'b1) && flush == 1'b0) ? 4'b0000 : {4{mem_wb_regfile_write_enable}};
    
    assign debug_wb_num = (rst == `RST_ENABLE) ? 5'b00000 : mem_wb_regfile_write_addr;
    assign debug_wb_data = (rst == `RST_ENABLE) ? 32'h00000000 : mem_wb_regfile_write_data;

    assign flush = rst == `RST_ENABLE ? 1'b0: is_exception;
    
    pc mips_pc(
        .rst(rst),
        .clk(clk),
        .stall({data_stall, exe_stall_request, id_stall_request, inst_stall}),
        .exception(is_exception),
        .exception_pc_i(cp0_return_pc),
        .branch_enable_i(id_branch_enable),
        .branch_addr_i(id_branch_addr),
        
        .pc_o(if_pc_if_id),
        .exception_type_o(if_exception_type_if_id)
    );

    if_id mips_if_id(
        .rst(rst),
        .clk(clk),
        .if_pc(if_pc_if_id),
        .if_instr(rom_instr_if_id), 
        .exception(is_exception),
        .stall({data_stall, exe_stall_request, id_stall_request, inst_stall}),
        .if_exception_type(if_exception_type_if_id),
                
        .id_instr(if_id_instr_id),
        .id_pc(if_id_pc_id),
        .id_exception_type(if_id_exception_type_id)
    );
    
    id mips_id(
        .rst(rst),
        .instr_i(if_id_instr_id),
        .pc_i(if_id_pc_id),
        .rs_data_i(regfile_rs_data_id),
        .rt_data_i(regfile_rt_data_id),
        .exe_regfile_write_addr_i(ex_regfile_write_addr_ex_mem),
        .now_in_delayslot_i(exe_id_now_in_delayslot),
        .exe_mem_to_reg_i(ex_mem_to_reg_ex_mem),
        .bypass_ex_regfile_write_enable_i(ex_regfile_write_enable_ex_mem),
        .bypass_ex_regfile_write_addr_i(ex_regfile_write_addr_ex_mem),
        .bypass_ex_regfile_write_data_i(ex_alu_data_ex_mem),
        .bypass_mem_regfile_write_enable_i(mem_regfile_write_enable_mem_wb),
        .bypass_mem_regfile_write_addr_i(mem_regfile_write_addr_mem_wb),
        .bypass_mem_regfile_write_data_i(mem_regfile_write_data_mem_wb),
        .exception_type_i(if_id_exception_type_id),
        
        .pc_o(id_pc_id_ex),
        .instr_o(id_instr_id_ex),
        .rs_data_o(id_rs_data_id_ex),
        .rt_data_o(id_rt_data_id_ex),
        .aluop_o(id_aluop_id_ex),
        .regfile_write_addr_o(id_regfile_write_addr_id_ex),
        .now_in_delayslot_o(id_now_in_delayslot_id_ex),
        .next_in_delayslot_o(id_next_in_delayslot_id_ex),
        .id_stall_request_o(id_stall_request),
        .regfile_write_enable_o(id_regfile_write_enable_id_ex),
        .ram_write_enable_o(id_ram_write_enable_id_ex),
        .hi_write_enable_o(id_hi_write_enable_id_ex),
        .lo_write_enable_o(id_lo_write_enable_id_ex),
        .cp0_write_enable_o(id_cp0_write_enable_id_ex),
        .mem_to_reg_o(id_mem_to_reg_id_ex),
        .pc_return_addr_o(id_pc_return_addr_id_ex),
        .cp0_read_addr_o(id_cp0_read_addr_id_ex),
        .hilo_read_addr_o(id_hilo_read_addr_id_ex),
        .imm16_o(id_imm16_id_ex),
        .exception_type_o(id_exception_type_id_ex),
        .branch_enable_o(id_branch_enable),
        .branch_addr_o(id_branch_addr)
    );
    
    id_ex mips_id_ex(
        .id_pc(id_pc_id_ex),
        .id_rs_data(id_rs_data_id_ex),
        .id_rt_data(id_rt_data_id_ex),
        .id_instr(id_instr_id_ex),
        .id_aluop(id_aluop_id_ex),
        .id_regfile_write_addr(id_regfile_write_addr_id_ex),
        .id_now_in_delayslot(id_now_in_delayslot_id_ex),
        .id_next_in_delayslot(id_next_in_delayslot_id_ex),
        .id_exception_type(id_exception_type_id_ex),
        .id_regfile_write_enable(id_regfile_write_enable_id_ex),
        .id_ram_write_enable(id_ram_write_enable_id_ex),
        .id_hi_write_enable(id_hi_write_enable_id_ex),
        .id_lo_write_enable(id_lo_write_enable_id_ex),
        .id_cp0_write_enable(id_cp0_write_enable_id_ex),
        .id_mem_to_reg(id_mem_to_reg_id_ex),
        .id_pc_return_addr(id_pc_return_addr_id_ex),
        .id_hilo_data(hilo_data_id_ex),
        .id_cp0_data(cp0_data_id_ex),
        .id_imm16(id_imm16_id_ex),
        .id_hilo_read_addr(id_hilo_read_addr_id_ex),
        .id_cp0_read_addr(id_cp0_read_addr_id_ex),
        .exception(is_exception),
        .stall({data_stall, exe_stall_request, id_stall_request, inst_stall}),
        .clk(clk),
        .rst(rst),
        
        .ex_pc(id_ex_pc_ex),
        .ex_rs_data(id_ex_rs_data_ex),
        .ex_rt_data(id_ex_rt_data_ex),
        .ex_instr(id_ex_instr_ex),
        .ex_aluop(id_ex_aluop_ex),
        .ex_regfile_write_addr(id_ex_regfile_write_addr_ex),
        .ex_now_in_delayslot(id_ex_now_in_delayslot_ex),
        .ex_exception_type(id_ex_exception_type_ex),
        .ex_regfile_write_enable(id_ex_regfile_write_enable_ex),
        .ex_ram_write_enable(id_ex_ram_write_enable_ex),
        .ex_hi_write_enable(id_ex_hi_write_enable_ex),
        .ex_lo_write_enable(id_ex_lo_write_enable_ex),
        .ex_cp0_write_enable(id_ex_cp0_write_enable_ex),
        .ex_hilo_data(id_ex_hilo_data_ex),
        .ex_cp0_data(id_ex_cp0_data_ex),
        .ex_mem_to_reg(id_ex_mem_to_reg_ex),
        .ex_pc_return_addr(id_ex_pc_return_addr_ex),
        .ex_sign_extend_imm16(id_ex_sign_extend_imm16_ex),
        .ex_zero_extend_imm16(id_ex_zero_extend_imm16_ex),
        .ex_load_upper_imm16(id_ex_load_upper_imm16_ex),
        .ex_hilo_read_addr(id_ex_hilo_read_addr_ex),
        .ex_cp0_read_addr(id_ex_cp0_read_addr_ex),
        .ex_id_now_in_delayslot(exe_id_now_in_delayslot)
    );
    
    ex mips_ex(
        .pc_i(id_ex_pc_ex),
        .rs_data_i(id_ex_rs_data_ex),
        .rt_data_i(id_ex_rt_data_ex),
        .instr_i(id_ex_instr_ex),
        .aluop_i(id_ex_aluop_ex),
        .regfile_write_addr_i(id_ex_regfile_write_addr_ex),
        .now_in_delayslot_i(id_ex_now_in_delayslot_ex),
        .exception_type_i(id_ex_exception_type_ex),
        .regfile_write_enable_i(id_ex_regfile_write_enable_ex),
        .ram_write_enable_i(id_ex_ram_write_enable_ex),
        .hi_write_enable_i(id_ex_hi_write_enable_ex),
        .lo_write_enable_i(id_ex_lo_write_enable_ex),
        .cp0_write_enable_i(id_ex_cp0_write_enable_ex),
        .hilo_data_i(id_ex_hilo_data_ex),
        .cp0_data_i(id_ex_cp0_data_ex),
        .mem_to_reg_i(id_ex_mem_to_reg_ex),
        .pc_return_addr_i(id_ex_pc_return_addr_ex),
        .sign_extend_imm16_i(id_ex_sign_extend_imm16_ex),
        .zero_extend_imm16_i(id_ex_zero_extend_imm16_ex),
        .load_upper_imm16_i(id_ex_load_upper_imm16_ex),
        .bypass_mem_hi_write_enable_i(mem_hi_write_enable_mem_wb),
        .bypass_mem_hi_write_data_i(mem_hi_write_data_mem_wb),
        .bypass_mem_lo_write_enable_i(mem_lo_write_enable_mem_wb),
        .bypass_mem_lo_write_data_i(mem_lo_write_data_mem_wb),
        .bypass_mem_cp0_write_enable_i(mem_cp0_write_enable),
        .bypass_mem_cp0_write_addr_i(mem_cp0_write_addr),
        .bypass_mem_cp0_write_data_i(mem_cp0_write_data),
        .bypass_wb_hi_write_enable_i(mem_wb_hi_write_enable),
        .bypass_wb_hi_write_data_i(mem_wb_hi_write_data),
        .bypass_wb_lo_write_enable_i(mem_wb_lo_write_enable),
        .bypass_wb_lo_write_data_i(mem_wb_lo_write_data),
        .hilo_read_addr_i(id_ex_hilo_read_addr_ex),
        .cp0_read_addr_i(id_ex_cp0_read_addr_ex),
        .clk(clk),
        .rst(rst),
        
        .pc_o(ex_pc_ex_mem),
        .aluop_o(ex_aluop_ex_mem),
        .now_in_delayslot_o(ex_now_in_delayslot_ex_mem),
        .exception_type_o(ex_exception_type_ex_mem),
        .regfile_write_enable_o(ex_regfile_write_enable_ex_mem),
        .ram_write_enable_o(ex_ram_write_enable_ex_mem),
        .hi_write_enable_o(ex_hi_write_enable_ex_mem),
        .lo_write_enable_o(ex_lo_write_enable_ex_mem),
        .cp0_write_enable_o(ex_cp0_write_enable_ex_mem),
        .regfile_write_addr_o(ex_regfile_write_addr_ex_mem),
        .cp0_write_addr_o(ex_cp0_write_addr_ex_mem),
        .alu_data_o(ex_alu_data_ex_mem),
        .ram_write_data_o(ex_ram_write_data_ex_mem),
        .hi_write_data_o(ex_hi_write_data_ex_mem),
        .lo_write_data_o(ex_lo_write_data_ex_mem),
        .cp0_write_data_o(ex_cp0_write_data_ex_mem),
        .mem_to_reg_o(ex_mem_to_reg_ex_mem),
        .exe_stall_request_o(exe_stall_request)
    );
    
    ex_mem mips_ex_mem(
        .exe_pc(ex_pc_ex_mem),
        .exe_aluop(ex_aluop_ex_mem),
        .exe_now_in_delayslot(ex_now_in_delayslot_ex_mem),
        .exe_exception_type(ex_exception_type_ex_mem),
        .exe_regfile_write_enable(ex_regfile_write_enable_ex_mem),
        .exe_ram_write_enable(ex_ram_write_enable_ex_mem),
        .exe_hi_write_enable(ex_hi_write_enable_ex_mem),
        .exe_lo_write_enable(ex_lo_write_enable_ex_mem),
        .exe_cp0_write_enable(ex_cp0_write_enable_ex_mem),
        .exe_regfile_write_addr(ex_regfile_write_addr_ex_mem),
        .exe_cp0_write_addr(ex_cp0_write_addr_ex_mem),
        .exe_alu_data(ex_alu_data_ex_mem),
        .exe_ram_write_data(ex_ram_write_data_ex_mem),
        .exe_hi_write_data(ex_hi_write_data_ex_mem),
        .exe_lo_write_data(ex_lo_write_data_ex_mem),
        .exe_cp0_write_data(ex_cp0_write_data_ex_mem),
        .exe_mem_to_reg(ex_mem_to_reg_ex_mem),
        .exception(is_exception),
        .stall({data_stall, exe_stall_request, id_stall_request, inst_stall}),
        .rst(rst),
        .clk(clk),
        
        .mem_pc(ex_mem_pc_mem),
        .mem_aluop(ex_mem_aluop_mem),
        .mem_now_in_delayslot(ex_mem_now_in_delayslot_mem),
        .mem_exception_type(ex_mem_exception_type_mem),
        .mem_regfile_write_enable(ex_mem_regfile_write_enable_mem),
        .mem_ram_write_enable(ex_mem_ram_write_enable_mem),
        .mem_hi_write_enable(ex_mem_hi_write_enable_mem),
        .mem_lo_write_enable(ex_mem_lo_write_enable_mem),
        .mem_cp0_write_enable(ex_mem_cp0_write_enable_mem),
        .mem_regfile_write_addr(ex_mem_regfile_write_addr_mem),
        .mem_ram_write_addr(ex_mem_ram_write_addr_mem),
        .mem_cp0_write_addr(ex_mem_cp0_write_addr_mem),
        .mem_alu_data(ex_mem_alu_data_mem),
        .mem_ram_write_data(ex_mem_ram_write_data_mem),
        .mem_hi_write_data(ex_mem_hi_write_data_mem),
        .mem_lo_write_data(ex_mem_lo_write_data_mem),
        .mem_cp0_write_data(ex_mem_cp0_write_data_mem),
        .mem_mem_to_reg(ex_mem_mem_to_reg_mem),
        .mem_ram_read_addr(ex_mem_ram_read_addr_mem)
    );
    
    mem mips_mem(
        .pc_i(ex_mem_pc_mem),
        .aluop_i(ex_mem_aluop_mem),
        .now_in_delayslot_i(ex_mem_now_in_delayslot_mem),
        .exception_type_i(ex_mem_exception_type_mem),
        .regfile_write_enable_i(ex_mem_regfile_write_enable_mem),
        .ram_write_enable_i(ex_mem_ram_write_enable_mem),
        .hi_write_enable_i(ex_mem_hi_write_enable_mem),
        .lo_write_enable_i(ex_mem_lo_write_enable_mem),
        .cp0_write_enable_i(ex_mem_cp0_write_enable_mem),
        .regfile_write_addr_i(ex_mem_regfile_write_addr_mem),
        .ram_write_addr_i(ex_mem_ram_write_addr_mem),
        .cp0_write_addr_i(ex_mem_cp0_write_addr_mem),
        .alu_data_i(ex_mem_alu_data_mem),
        .ram_write_data_i(ex_mem_ram_write_data_mem),
        .hi_write_data_i(ex_mem_hi_write_data_mem),
        .lo_write_data_i(ex_mem_lo_write_data_mem),
        .cp0_write_data_i(ex_mem_cp0_write_data_mem),
        .mem_to_reg_i(ex_mem_mem_to_reg_mem),
        .ram_read_addr_i(ex_mem_ram_read_addr_mem),
        .ram_read_data_i(ram_read_data),
        .rst(rst),
        
        .store_pc_o(mem_store_pc),
        .access_mem_addr_o(mem_access_mem_addr),
        .now_in_delayslot_o(mem_now_in_delayslot),
        .exception_type_o(mem_exception_type),
        .regfile_write_enable_o(mem_regfile_write_enable_mem_wb),
        .regfile_write_addr_o(mem_regfile_write_addr_mem_wb),
        .hi_write_enable_o(mem_hi_write_enable_mem_wb),
        .lo_write_enable_o(mem_lo_write_enable_mem_wb),
        .hi_write_data_o(mem_hi_write_data_mem_wb),
        .lo_write_data_o(mem_lo_write_data_mem_wb),
        .cp0_write_enable_o(mem_cp0_write_enable),
        .cp0_write_addr_o(mem_cp0_write_addr),
        .cp0_write_data_o(mem_cp0_write_data),
        .regfile_write_data_o(mem_regfile_write_data_mem_wb),
        
        .ram_write_select_o(mem_ram_write_select),
        .ram_write_enable_o(mem_ram_write_enable),
        .ram_write_addr_o(mem_ram_write_addr),
        .ram_write_data_o(mem_ram_write_data),
        .ram_read_addr_o(mem_ram_read_addr),
        .ram_read_enable_o(mem_ram_read_enable)
    );
    
    mem_wb mips_mem_wb(
        .mem_regfile_write_enable(mem_regfile_write_enable_mem_wb),
        .mem_regfile_write_addr(mem_regfile_write_addr_mem_wb),
        .mem_hi_write_enable(mem_hi_write_enable_mem_wb),
        .mem_lo_write_enable(mem_lo_write_enable_mem_wb),
        .mem_hi_write_data(mem_hi_write_data_mem_wb),
        .mem_lo_write_data(mem_lo_write_data_mem_wb),
        .mem_cp0_write_enable(mem_cp0_write_enable),
        .mem_cp0_write_addr(mem_cp0_write_addr),
        .mem_cp0_write_data(mem_cp0_write_data),
        .mem_regfile_write_data(mem_regfile_write_data_mem_wb),
        .stall({data_stall, exe_stall_request, id_stall_request, inst_stall}),
        .exception(is_exception),
        .rst(rst),
        .clk(clk),
        
        .wb_regfile_write_enable(mem_wb_regfile_write_enable),
        .wb_regfile_write_addr(mem_wb_regfile_write_addr),
        .wb_regfile_write_data(mem_wb_regfile_write_data),
        .wb_hi_write_enable(mem_wb_hi_write_enable),
        .wb_lo_write_enable(mem_wb_lo_write_enable),
        .wb_hi_write_data(mem_wb_hi_write_data),
        .wb_lo_write_data(mem_wb_lo_write_data),
        
        .in_wb_pc(mem_store_pc),
        .wb_pc(debug_wb_pc)
    );
    
    regfile mips_regfile(
        .rs_read_addr(if_id_instr_id[25:21]),
        .rt_read_addr(if_id_instr_id[20:16]),
        .clk(clk),
        .rst(rst),
        .regfile_write_enable(mem_wb_regfile_write_enable),
        .regfile_write_addr(mem_wb_regfile_write_addr),
        .regfile_write_data(mem_wb_regfile_write_data),
        
        .rs_data_o(regfile_rs_data_id),
        .rt_data_o(regfile_rt_data_id)
    );
    
    hilo mips_hilo(
        .clk(clk),
        .rst(rst),
        .hilo_read_addr_i(id_hilo_read_addr_id_ex),
        .hi_write_enable_i(mem_wb_hi_write_enable),
        .hi_write_data_i(mem_wb_hi_write_data),
        .lo_write_enable_i(mem_wb_lo_write_enable),
        .lo_write_data_i(mem_wb_lo_write_data),
        
        .hilo_read_data_o(hilo_data_id_ex)
    );
    
    cp0 mips_cp0(
        .clk(clk),
        .rst(rst),
        .cp0_read_addr_i(id_cp0_read_addr_id_ex),   //maybe problems
        .cp0_write_enable_i(mem_cp0_write_enable),
        .cp0_write_addr_i(mem_cp0_write_addr),
        .cp0_write_data_i(mem_cp0_write_data),
        .exception_type_i(mem_exception_type),
        .pc_i(mem_store_pc),    
        .exception_addr_i(mem_access_mem_addr),
        .int_i(interrupt),
        .now_in_delayslot_i(mem_now_in_delayslot),
        .cp0_read_data_o(cp0_data_id_ex),
        .cp0_return_pc_o(cp0_return_pc),    
        .timer_int_o(time_int_out),    
        .flush_o(is_exception)
    );
endmodule
