`timescale 1ns / 1ps

`include "defines.vh"

module mips_top(
    input   wire        clk,
    input   wire        rst,
    
    input   wire[5:0]   interrupt,
    
    output  wire[31:0]  inst_sram_addr,
    input   wire[31:0]  inst_sram_rdata,
    output  wire        inst_sram_cache,
    
    output  wire        data_sram_en,
    output  wire[3:0]   data_sram_wen,
    output  wire[31:0]  data_sram_addr,
    output  wire[31:0]  data_sram_wdata,
    input   wire[31:0]  data_sram_rdata,
    output  wire        data_sram_cache,
    
    output  wire[31:0]  debug_wb_pc,
    output  wire[3:0]   debug_wb_wen,
    output  wire[4:0]   debug_wb_num,
    output  wire[31:0]  debug_wb_data,
    
    input   wire        inst_stall,
    input   wire        data_stall,
    output  wire        flush,
    output  wire[3:0]   stall_o
    );
    
    wire id_stall, ex_stall;
    wire[3:0] stall;
    assign stall = {inst_stall, id_stall, ex_stall, data_stall};
    assign stall_o = stall;
    
    wire exception_global;
    wire[31:0] exception_pc;
    wire branch_enable;
    wire[31:0] branch_pc;
    assign flush = exception_global;
    
    wire[31:0] cp0_rdata;
    wire[31:0] hilo_rdata;
    
    wire[31:0] if_pc_o;
    wire[31:0] if_exception_type_o;
    wire inst_paddr_refill, inst_paddr_invalid;
    wire inst_cache;
    wire[31:0] inst_paddr;
    assign inst_sram_addr = inst_paddr;
    assign inst_sram_cache = inst_cache;
    wire data_paddr_refill, data_paddr_invalid, data_paddr_modify;
    wire data_cache;
    wire[31:0] data_paddr;
    assign data_sram_addr = data_paddr;
    assign data_sram_cache = data_cache;
    
    wire[31:0] id_pc_i, id_pc_o;
    wire[31:0] id_exception_type_i, id_exception_type_o;
    wire[31:0] id_instruction_i, id_instruction_o;
    assign id_instruction_i = inst_sram_rdata;
    wire[31:0] id_rs_data_i, id_rt_data_i;
    wire[31:0] bypass_ex_regfile_wdata, bypass_mem_regfile_wdata;
    wire[4:0] bypass_ex_regfile_waddr, bypass_mem_regfile_waddr;
    wire bypass_ex_regfile_wen, bypass_mem_regfile_wen;
    wire ex_mem_to_reg, mem_mem_to_reg;
    wire now_in_delayslot;
    wire id_next_in_delayslot_o;
    wire id_in_delayslot_o;
    wire[7:0] id_aluop_o;
    wire id_regfile_wen_o;
    wire[4:0] id_regfile_waddr_o;
    wire id_hi_wen_o, id_lo_wen_o, id_hilo_addr_o;
    wire id_mem_en_o, id_mem_to_reg_o;
    wire id_cp0_wen_o;
    wire[4:0] id_cp0_addr_o;
    wire[2:0] id_cp0_sel_o;
    wire[31:0] id_rs_data_o, id_rt_data_o;
    
    wire[31:0] ex_pc_i;
    wire[31:0] ex_exception_type_i;
    wire[31:0] ex_instruction_i;
    wire ex_next_in_delayslot_i;
    assign now_in_delayslot = ex_next_in_delayslot_i;
    wire ex_in_delayslot_i;
    wire[7:0] ex_aluop_i;
    wire ex_regfile_wen_i;
    wire[4:0] ex_regfile_waddr_i;
    wire ex_hi_wen_i, ex_lo_wen_i, ex_hilo_addr_i;
    wire ex_mem_en_i, ex_mem_to_reg_i;
    wire ex_cp0_wen_i;
    wire[4:0] ex_cp0_addr_i;
    wire[2:0] ex_cp0_sel_i;
    wire[31:0] ex_rs_data_i, ex_rt_data_i;
    wire[31:0] ex_pc_o;
    wire[31:0] ex_exception_type_o;
    wire[31:0] ex_instruction_o;
    wire ex_in_delayslot_o;
    wire[7:0] ex_aluop_o;
    wire ex_regfile_wen_o;
    assign bypass_ex_regfile_wen = ex_regfile_wen_o;
    wire[4:0] ex_regfile_waddr_o;
    assign bypass_ex_regfile_waddr = ex_regfile_waddr_o;
    wire ex_hi_wen_o;
    wire[31:0] ex_hi_wdata_o;
    wire ex_lo_wen_o;
    wire[31:0] ex_lo_wdata_o;
    wire ex_cp0_wen_o;
    wire[4:0] ex_cp0_addr_o;
    wire[2:0] ex_cp0_sel_o;
    wire ex_mem_en_o;
    wire ex_mem_to_reg_o;
    assign ex_mem_to_reg = ex_mem_to_reg_o;
    wire[31:0] ex_alu_data_o;
    assign bypass_ex_regfile_wdata = ex_alu_data_o;
    wire[31:0] ex_rt_data_o;
    
    wire[31:0] mem_pc_i;
    wire[31:0] mem_exception_type_i;
    wire[31:0] mem_instruction_i;
    wire  mem_in_delayslot_i;
    wire[7:0]  mem_aluop_i;
    wire  mem_regfile_wen_i;
    wire[4:0] mem_regfile_waddr_i;
    wire  mem_hi_wen_i;
    wire[31:0] mem_hi_wdata_i;
    wire  mem_lo_wen_i;
    wire[31:0] mem_lo_wdata_i;
    wire mem_cp0_wen_i;
    wire[4:0] mem_cp0_addr_i;
    wire[2:0] mem_cp0_sel_i;
    wire mem_mem_en_i;
    wire mem_mem_to_reg_i;
    wire[31:0] mem_alu_data_i;
    wire[31:0] mem_rt_data_i;
    wire[31:0] mem_pc_o;
    wire[31:0] mem_exception_type_o;
    wire[31:0] mem_instruction_o;
    wire[7:0] mem_aluop_o;
    wire mem_regfile_wen_o;
    assign bypass_mem_regfile_wen = mem_regfile_wen_o;
    wire[4:0] mem_regfile_waddr_o;
    assign bypass_mem_regfile_waddr = mem_regfile_waddr_o;
    wire[31:0] mem_alu_data_o;
    assign bypass_mem_regfile_wdata = mem_alu_data_o;
    wire  mem_mem_to_reg_o;
    assign mem_mem_to_reg = mem_mem_to_reg_o;
    wire[31:0] mem_rt_data_o;
    wire mem_en_o;
    wire[3:0] mem_wen_o;
    wire[31:0] mem_wdata_o;
    wire[31:0] mem_addr_o;
    
    assign data_sram_en = mem_en_o;
    assign data_sram_wen = mem_wen_o;
    assign data_sram_wdata = mem_wdata_o;
    
    wire[31:0] wb_pc_i;
    wire[31:0] wb_instruction_i;
    wire[7:0] wb_aluop_i;
    wire wb_regfile_wen_i;
    wire[4:0] wb_regfile_waddr_i;
    wire[31:0] wb_alu_data_i;
    wire[31:0] wb_rt_data_i;
    wire wb_mem_to_reg_i;
    wire[31:0] wb_mem_addr_i;
    wire[31:0] mem_rdata;
    assign mem_rdata = data_sram_rdata;
    wire wb_regfile_wen_o;
    wire [4:0] wb_regfile_waddr_o;
    wire [31:0] wb_regfile_wdata_o;
    
    
    cp0 mips_cp0(
        .rst(rst),
        .clk(clk),
    
        .cp0_read_addr(ex_cp0_addr_i),          // i 5
        .cp0_read_sel(ex_cp0_sel_i),            // i 3
        .cp0_read_data(cp0_rdata),              // o 32
        .cp0_write_addr(mem_cp0_addr_i),        // i 5
        .cp0_write_sel(mem_cp0_sel_i),          // i 3
        .cp0_write_data(mem_rt_data_i),         // i 32
        .cp0_write_enable(mem_cp0_wen_i),       // i 1
    
        .aluop(mem_aluop_i),                    // i 8
    
        .int_i(interrupt),                      // i 6
        .pc(mem_pc_i),                          // i 32
        .mem_bad_vaddr(mem_addr_o),             // i 32
        .exception_type(mem_exception_type_o),  // i 32
        .in_delayslot(mem_in_delayslot_i),      // i 1
        .return_pc(exception_pc),               // o 32
        .exception(exception_global),           // o 1
    
        .inst_vaddr(if_pc_o),                   // i 32
        .inst_paddr(inst_paddr),                // o 32
        .inst_miss(inst_paddr_refill),          // o 1
        .inst_invalid(inst_paddr_invalid),      // o 1
        .inst_cache(inst_cache),                // o 1
    
        .data_vaddr(mem_addr_o),                // i 32
        .data_ren(mem_en_o),                    // i 1
        .data_wen(|mem_wen_o),                  // i 1
        .data_paddr(data_paddr),                // o 32
        .data_miss(data_paddr_refill),          // o 1
        .data_invalid(data_paddr_invalid),      // o 1
        .data_modified(data_paddr_modify),      // o 1
        .data_cache(data_cache)                 // o 1
    );
    
    pc mips_pc(
        .rst(rst),
        .clk(clk),
        .exception(exception_global),           // i 1
        .exception_pc(exception_pc),            // i 32
        .branch(branch_enable),                 // i 1
        .branch_pc(branch_pc),                  // i 32
        
        .pc(if_pc_o),                           // o 32
        .exception_type(if_exception_type_o),   // o 32
        
        .stall(stall),                          // i 4
        
        .inst_paddr_refill(inst_paddr_refill),  // i 1
        .inst_paddr_invalid(inst_paddr_invalid) // i 1
    );
    
    if_id mips_if_id(
        .rst(rst),
        .clk(clk),
        .exception(exception_global),
        .stall(stall),
    
        .pc_i(if_pc_o),
        .exception_type_i(if_exception_type_o),
    
        .pc_o(id_pc_i),
        .exception_type_o(id_exception_type_i)
    );
    
    id mips_id(
        .pc_i(id_pc_i),                         // i 32
        .exception_type_i(id_exception_type_i), // i 32
        .instruction_i(id_instruction_i),       // i 32
        .rs_data_i(id_rs_data_i),               // i 32
        .rt_data_i(id_rt_data_i),               // i 32
        .bypass_ex_regfile_wdata_i(bypass_ex_regfile_wdata),    // i 32
        .bypass_ex_regfile_waddr_i(bypass_ex_regfile_waddr),    // i 5
        .bypass_ex_regfile_wen_i(bypass_ex_regfile_wen),        // i 1
        .bypass_mem_regfile_wdata_i(bypass_mem_regfile_wdata),  // i 32
        .bypass_mem_regfile_waddr_i(bypass_mem_regfile_waddr),  // i 5
        .bypass_mem_regfile_wen_i(bypass_mem_regfile_wen),      // i 1
        .ex_mem_to_reg_i(ex_mem_to_reg),        // generate stall // i 1
        .mem_mem_to_reg_i(mem_mem_to_reg),      // generate stall // i 1
        .now_in_delayslot_i(now_in_delayslot),  // i 1
    
        .id_stall_o(id_stall),                  // o 1
        .pc_o(id_pc_o),                         // o 32
        .exception_type_o(id_exception_type_o), // o 32
        .instruction_o(id_instruction_o),       // o 32
        .next_in_delayslot_o(id_next_in_delayslot_o),           // o 1
        .in_delayslot_o(id_in_delayslot_o),     // o 1
        .aluop_o(id_aluop_o),                   // o 8
        .regfile_wen_o(id_regfile_wen_o),       // o 1
        .regfile_waddr_o(id_regfile_waddr_o),   // o 5
        .hi_wen_o(id_hi_wen_o),                 // o 1
        .lo_wen_o(id_lo_wen_o),                 // o 1
        .hilo_addr_o(id_hilo_addr_o),           // o 1
        .mem_en_o(id_mem_en_o),                 // o 1
        .mem_to_reg_o(id_mem_to_reg_o),         // o 1
        .cp0_wen_o(id_cp0_wen_o),               // o 1
        .cp0_addr_o(id_cp0_addr_o),             // o 5
        .cp0_sel_o(id_cp0_sel_o),               // o 3
        .rs_data_o(id_rs_data_o),               // o 32
        .rt_data_o(id_rt_data_o),               // o 32
        .branch(branch_enable),                 // o 1
        .branch_pc(branch_pc)                   // o 32
    );
    
    id_ex mips_id_ex(
        .clk(clk),
        .rst(rst),
        .exception(exception_global),
        .stall(stall),
    
        .pc_i(id_pc_o),
        .exception_type_i(id_exception_type_o),
        .instruction_i(id_instruction_o),
        .next_in_delayslot_i(id_next_in_delayslot_o),
        .in_delayslot_i(id_in_delayslot_o),
        .aluop_i(id_aluop_o),
        .regfile_wen_i(id_regfile_wen_o),
        .regfile_waddr_i(id_regfile_waddr_o),
        .hi_wen_i(id_hi_wen_o),
        .lo_wen_i(id_lo_wen_o),
        .hilo_addr_i(id_hilo_addr_o),
        .mem_en_i(id_mem_en_o),
        .mem_to_reg_i(id_mem_to_reg_o),
        .cp0_wen_i(id_cp0_wen_o),
        .cp0_addr_i(id_cp0_addr_o),
        .cp0_sel_i(id_cp0_sel_o),
        .rs_data_i(id_rs_data_o),
        .rt_data_i(id_rt_data_o),
    
        .pc_o(ex_pc_i),
        .exception_type_o(ex_exception_type_i),
        .instruction_o(ex_instruction_i),
        .next_in_delayslot_o(ex_next_in_delayslot_i),
        .in_delayslot_o(ex_in_delayslot_i),
        .aluop_o(ex_aluop_i),
        .regfile_wen_o(ex_regfile_wen_i),
        .regfile_waddr_o(ex_regfile_waddr_i),
        .hi_wen_o(ex_hi_wen_i),
        .lo_wen_o(ex_lo_wen_i),
        .hilo_addr_o(ex_hilo_addr_i),
        .mem_en_o(ex_mem_en_i),
        .mem_to_reg_o(ex_mem_to_reg_i),
        .cp0_wen_o(ex_cp0_wen_i),
        .cp0_addr_o(ex_cp0_addr_i),
        .cp0_sel_o(ex_cp0_sel_i),
        .rs_data_o(ex_rs_data_i),
        .rt_data_o(ex_rt_data_i)
    );
    
    ex mips_ex(
        .rst(rst),
        .clk(clk), // for div
    
        .pc_i(ex_pc_i),                         // i 32
        .exception_type_i(ex_exception_type_i), // i 32
        .instruction_i(ex_instruction_i),       // i 32
        .in_delayslot_i(ex_in_delayslot_i),     // i 1
        .aluop_i(ex_aluop_i),                   // i 8
        .regfile_wen_i(ex_regfile_wen_i),       // i 1
        .regfile_waddr_i(ex_regfile_waddr_i),   // i 5
        .hi_wen_i(ex_hi_wen_i),                 // i 1
        .lo_wen_i(ex_lo_wen_i),                 // i 1
        .mem_en_i(ex_mem_en_i),                 // i 1
        .mem_to_reg_i(ex_mem_to_reg_i),         // i 1
        .cp0_wen_i(ex_cp0_wen_i),               // i 1
        .cp0_addr_i(ex_cp0_addr_i),             // i 5
        .cp0_sel_i(ex_cp0_sel_i),               // i 3
        .rs_data_i(ex_rs_data_i),               // i 32
        .rt_data_i(ex_rt_data_i),               // i 32
        .cp0_rdata_i(cp0_rdata),                // i 32
        .hilo_rdata_i(hilo_rdata),              // i 32
    
        .pc_o(ex_pc_o),                         // o 32
        .exception_type_o(ex_exception_type_o), // o 32
        .instruction_o(ex_instruction_o),       // o 32
        .in_delayslot_o(ex_in_delayslot_o),     // o 1
        .aluop_o(ex_aluop_o),                   // o 8
        .regfile_wen_o(ex_regfile_wen_o),       // o 1
        .regfile_waddr_o(ex_regfile_waddr_o),   // o 5
        .hi_wen_o(ex_hi_wen_o),                 // o 1
        .hi_wdata_o(ex_hi_wdata_o),             // o 32
        .lo_wen_o(ex_lo_wen_o),                 // o 1
        .lo_wdata_o(ex_lo_wdata_o),             // o 32
        .cp0_wen_o(ex_cp0_wen_o),               // o 1
        .cp0_addr_o(ex_cp0_addr_o),             // o 5
        .cp0_sel_o(ex_cp0_sel_o),               // o 3
        .mem_en_o(ex_mem_en_o),                 // o 1
        .mem_to_reg_o(ex_mem_to_reg_o),         // o 1
        .alu_data_o(ex_alu_data_o),             // o 32
        .rt_data_o(ex_rt_data_o),               // o 32
        
        .ex_stall_o(ex_stall)                   // o 1
    );
    
    ex_mem mips_ex_mem(
        .clk(clk),
        .rst(rst),
        .exception(exception_global),
        .stall(stall),
    
        .pc_i(ex_pc_o),
        .exception_type_i(ex_exception_type_o),
        .instruction_i(ex_instruction_o),
        .in_delayslot_i(ex_in_delayslot_o),
        .aluop_i(ex_aluop_o),
        .regfile_wen_i(ex_regfile_wen_o),
        .regfile_waddr_i(ex_regfile_waddr_o),
        .hi_wen_i(ex_hi_wen_o),
        .hi_wdata_i(ex_hi_wdata_o),
        .lo_wen_i(ex_lo_wen_o),
        .lo_wdata_i(ex_lo_wdata_o),
        .cp0_wen_i(ex_cp0_wen_o),
        .cp0_addr_i(ex_cp0_addr_o),
        .cp0_sel_i(ex_cp0_sel_o),
        .mem_en_i(ex_mem_en_o),
        .mem_to_reg_i(ex_mem_to_reg_o),
        .alu_data_i(ex_alu_data_o),
        .rt_data_i(ex_rt_data_o),
    
        .pc_o(mem_pc_i),
        .exception_type_o(mem_exception_type_i),
        .instruction_o(mem_instruction_i),
        .in_delayslot_o(mem_in_delayslot_i),
        .aluop_o(mem_aluop_i),
        .regfile_wen_o(mem_regfile_wen_i),
        .regfile_waddr_o(mem_regfile_waddr_i),
        .hi_wen_o(mem_hi_wen_i),
        .hi_wdata_o(mem_hi_wdata_i),
        .lo_wen_o(mem_lo_wen_i),
        .lo_wdata_o(mem_lo_wdata_i),
        .cp0_wen_o(mem_cp0_wen_i),
        .cp0_addr_o(mem_cp0_addr_i),
        .cp0_sel_o(mem_cp0_sel_i),
        .mem_en_o(mem_mem_en_i),
        .mem_to_reg_o(mem_mem_to_reg_i),
        .alu_data_o(mem_alu_data_i),
        .rt_data_o(mem_rt_data_i)
    );
    
    mem mips_mem(
        .exception_i(exception_global),         // i 1
        .pc_i(mem_pc_i),                        // i 32
        .exception_type_i(mem_exception_type_i),// i 32
        .instruction_i(mem_instruction_i),      // i 32
        .aluop_i(mem_aluop_i),                  // i 8
        .regfile_wen_i(mem_regfile_wen_i),      // i 1
        .regfile_waddr_i(mem_regfile_waddr_i),  // i 5
        .mem_en_i(mem_mem_en_i),                // i 1
        .mem_to_reg_i(mem_mem_to_reg_i),        // i 1
        .alu_data_i(mem_alu_data_i),            // i 32
        .rt_data_i(mem_rt_data_i),              // i 32
        .data_paddr_refill_i(data_paddr_refill),// i 1
        .data_paddr_invalid_i(data_paddr_invalid),// i 1
        .data_paddr_modify_i(data_paddr_modify),// i 1
    
        .pc_o(mem_pc_o),                        // o 32
        .exception_type_o(mem_exception_type_o),// o 32
        .instruction_o(mem_instruction_o),      // o 32
        .aluop_o(mem_aluop_o),                  // o 8
        .regfile_wen_o(mem_regfile_wen_o),      // o 1
        .regfile_waddr_o(mem_regfile_waddr_o),  // o 5
        .alu_data_o(mem_alu_data_o),            // o 32
        .mem_to_reg_o(mem_mem_to_reg_o),        // o 1
        .rt_data_o(mem_rt_data_o),              // o 32
        
        .mem_en_o(mem_en_o),                    // o 1
        .mem_wen_o(mem_wen_o),                  // o 4
        .mem_wdata_o(mem_wdata_o),              // o 32
        .mem_addr_o(mem_addr_o)                 // o 32
    );
    
    mem_wb mips_mem_wb(
        .clk(clk),
        .rst(rst),
        .exception(exception_global),
        .stall(stall),
    
        .pc_i(mem_pc_o),
        .instruction_i(mem_instruction_o),
        .aluop_i(mem_aluop_o),
        .regfile_wen_i(mem_regfile_wen_o),
        .regfile_waddr_i(mem_regfile_waddr_o),
        .alu_data_i(mem_alu_data_o),
        .rt_data_i(mem_rt_data_o),
        .mem_to_reg_i(mem_mem_to_reg_o),
        .mem_addr_i(mem_addr_o),
    
        .pc_o(wb_pc_i),
        .instruction_o(wb_instruction_i),
        .aluop_o(wb_aluop_i),
        .regfile_wen_o(wb_regfile_wen_i),
        .regfile_waddr_o(wb_regfile_waddr_i),
        .alu_data_o(wb_alu_data_i),
        .rt_data_o(wb_rt_data_i),
        .mem_to_reg_o(wb_mem_to_reg_i),
        .mem_addr_o(wb_mem_addr_i)
    );
    
    wb mips_wb(
        .stall(stall),
        .pc_i(wb_pc_i),
        .instruction_i(wb_instruction_i),
        .aluop_i(wb_aluop_i),
        .regfile_wen_i(wb_regfile_wen_i),
        .regfile_waddr_i(wb_regfile_waddr_i),
        .alu_data_i(wb_alu_data_i),
        .rt_data_i(wb_rt_data_i),
        .mem_rdata_i(mem_rdata),
        .mem_addr_i(wb_mem_addr_i),
        .mem_to_reg_i(wb_mem_to_reg_i),
    
        .regfile_wen_o(wb_regfile_wen_o),
        .regfile_waddr_o(wb_regfile_waddr_o),
        .regfile_wdata_o(wb_regfile_wdata_o),
    
        .debug_pc(debug_wb_pc),
        .debug_regfile_wen(debug_wb_wen),
        .debug_regfile_waddr(debug_wb_num),
        .debug_regfile_wdata(debug_wb_data)
    );
    
    
    
    regfile mips_regfile(
        .clk(clk),
        .rst(rst),
        
        .regfile_write_enable(wb_regfile_wen_o),// i 1
        .regfile_write_addr(wb_regfile_waddr_o),// i 5
        .regfile_write_data(wb_regfile_wdata_o),// i 32
    
        .rs_read_addr(id_instruction_i[25:21]), // i 5
        .rt_read_addr(id_instruction_i[20:16]), // i 5
        .rs_data_o(id_rs_data_i),               // o 32
        .rt_data_o(id_rt_data_i)                // o 32
    );
    
    hilo mips_hilo(
        .clk(clk),
        .rst(rst),
        .hi_write_enable_i(mem_hi_wen_i),       // i 1
        .hi_write_data_i(mem_hi_wdata_i),       // i 32
        .lo_write_enable_i(mem_lo_wen_i),       // i 1
        .lo_write_data_i(mem_lo_wdata_i),       // i 32
        .hilo_read_addr_i(ex_hilo_addr_i),      //can be "0" or "1" only // i 1
        .hilo_read_data_o(hilo_rdata)           // o 32
    );
endmodule
