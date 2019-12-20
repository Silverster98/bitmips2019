`timescale 1ns / 1ps

`include "defines.vh"

module id(
    input   wire[31:0]  pc_i,
    input   wire[31:0]  exception_type_i,
    input   wire[31:0]  instruction_i,
    input   wire[31:0]  rs_data_i,
    input   wire[31:0]  rt_data_i,
    input   wire[31:0]  bypass_ex_regfile_wdata_i,
    input   wire[4:0]   bypass_ex_regfile_waddr_i,
    input   wire        bypass_ex_regfile_wen_i,
    input   wire[31:0]  bypass_mem_regfile_wdata_i,
    input   wire[4:0]   bypass_mem_regfile_waddr_i,
    input   wire        bypass_mem_regfile_wen_i,
    input   wire        ex_mem_to_reg_i,  // generate stall
    input   wire        mem_mem_to_reg_i, // generate stall
    input   wire        now_in_delayslot_i,
    
    output  wire        id_stall_o,
    output  wire[31:0]  pc_o,
    output  wire[31:0]  exception_type_o,
    output  wire[31:0]  instruction_o,
    output  wire        next_in_delayslot_o,
    output  wire        in_delayslot_o,
    output  wire[7:0]   aluop_o,
    output  wire        regfile_wen_o,
    output  wire[4:0]   regfile_waddr_o,
    output  wire        hi_wen_o,
    output  wire        lo_wen_o,
    output  wire        hilo_addr_o,
    output  wire        mem_en_o,
    output  wire        mem_to_reg_o,
    output  wire        cp0_wen_o,
    output  wire[4:0]   cp0_addr_o,
    output  wire[2:0]   cp0_sel_o,
    output  wire[31:0]  rs_data_o,
    output  wire[31:0]  rt_data_o,
    output  wire        branch,
    output  wire[31:0]  branch_pc
    );
    
    wire[7:0] aluop;
    wire[5:0] op;
    wire[5:0] funct;
    wire[4:0] rs,rt,rd,sa;
    assign op = instruction_i[31:26];
    assign rs = instruction_i[25:21];
    assign rt = instruction_i[20:16];
    assign rd = instruction_i[15:11];
    assign sa = instruction_i[10:6];
    assign funct = instruction_i[5:0];
    assign in_delayslot_o = now_in_delayslot_i;
    
    assign pc_o = pc_i;
    assign aluop_o = aluop;
    assign instruction_o = instruction_i;
    assign aluop = get_aluop(op, rs, rt, rd, sa, funct);

function [7:0] get_aluop(input [5:0] op, input [4:0] rs, input [4:0] rt, input [4:0] rd, input [4:0] sa, input [5:0] funct);
begin
    if ({op, rs, rt, rd, sa, funct} == `ID_NOP) get_aluop = `ALUOP_NOP;
    else begin
        case (op)
        `ID_SPECIAL: begin
            case (funct)
            `ID_AND     : get_aluop = `ALUOP_AND     ;
            `ID_ADD     : get_aluop = `ALUOP_ADD     ;
            `ID_ADDU    : get_aluop = `ALUOP_ADDU    ;
            `ID_NOR     : get_aluop = `ALUOP_NOR     ;
            `ID_OR      : get_aluop = `ALUOP_OR      ;
            `ID_XOR     : get_aluop = `ALUOP_XOR     ;
            `ID_SLL     : get_aluop = `ALUOP_SLL     ;
            `ID_SLLV    : get_aluop = `ALUOP_SLLV    ;
            `ID_SRL     : get_aluop = `ALUOP_SRL     ;
            `ID_SRLV    : get_aluop = `ALUOP_SRLV    ;
            `ID_SRA     : get_aluop = `ALUOP_SRA     ;
            `ID_SRAV    : get_aluop = `ALUOP_SRAV    ;
            `ID_SLT     : get_aluop = `ALUOP_SLT     ;
            `ID_SLTU    : get_aluop = `ALUOP_SLTU    ;
            `ID_SUB     : get_aluop = `ALUOP_SUB     ;
            `ID_SUBU    : get_aluop = `ALUOP_SUBU    ;
            `ID_MULT    : get_aluop = `ALUOP_MULT    ;
            `ID_MULTU   : get_aluop = `ALUOP_MULTU   ;
            `ID_DIV     : get_aluop = `ALUOP_DIV     ;
            `ID_DIVU    : get_aluop = `ALUOP_DIVU    ;
            `ID_JALR    : get_aluop = `ALUOP_JALR    ;
            `ID_JR      : get_aluop = `ALUOP_JR      ;
            `ID_SYSCALL : get_aluop = `ALUOP_SYSCALL ;
            `ID_BREAK   : get_aluop = `ALUOP_BREAK   ;
            `ID_MFHI    : get_aluop = `ALUOP_MFHI    ;
            `ID_MTHI    : get_aluop = `ALUOP_MTHI    ;
            `ID_MFLO    : get_aluop = `ALUOP_MFLO    ;
            `ID_MTLO    : get_aluop = `ALUOP_MTLO    ;
            `ID_TEQ     : get_aluop = `ALUOP_TEQ     ;
            `ID_TGE     : get_aluop = `ALUOP_TGE     ;
            `ID_TGEU    : get_aluop = `ALUOP_TGEU    ;
            `ID_TLT     : get_aluop = `ALUOP_TLT     ;
            `ID_TLTU    : get_aluop = `ALUOP_TLTU    ;
            `ID_TNE     : get_aluop = `ALUOP_TNE     ;
            `ID_MOVN    : get_aluop = `ALUOP_MOVN    ;
            `ID_MOVZ    : get_aluop = `ALUOP_MOVZ    ;
            default: get_aluop = `ALUOP_RI;
            endcase
        end
        `ID_SPECIAL2: begin
            if (funct == `ID_CLO && sa == 5'b0) get_aluop = `ALUOP_CLO;
            else if (funct == `ID_CLZ && sa == 5'b0) get_aluop = `ALUOP_CLZ;
            else get_aluop = `ALUOP_RI;
        end
        `ID_REGIMM: begin
            case (rt)
            `ID_BGEZ    : get_aluop = `ALUOP_BGEZ    ;
            `ID_BGEZAL  : get_aluop = `ALUOP_BGEZAL  ;
            `ID_BLTZ    : get_aluop = `ALUOP_BLTZ    ;
            `ID_BLTZAL  : get_aluop = `ALUOP_BLTZAL  ;
            `ID_TEQI    : get_aluop = `ALUOP_TEQI    ;
            `ID_TGEI    : get_aluop = `ALUOP_TGEI    ;
            `ID_TGEIU   : get_aluop = `ALUOP_TGEIU   ;
            `ID_TLTI    : get_aluop = `ALUOP_TLTI    ;
            `ID_TLTIU   : get_aluop = `ALUOP_TLTIU   ;
            `ID_TNEI    : get_aluop = `ALUOP_TNEI    ;
            default: get_aluop = `ALUOP_RI;
            endcase
        end
        `ID_COP0: begin
            if (rs == `ID_MFC0) get_aluop = `ALUOP_MFC0;
            else if (rs == `ID_MTC0) get_aluop = `ALUOP_MTC0;
            else if ({op, rs, rt, rd, sa, funct} == `ID_ERET) get_aluop = `ALUOP_ERET;
            else if ({op, rs, rt, rd, sa, funct} == `ID_TLBP) get_aluop = `ALUOP_TLBP;
            else if ({op, rs, rt, rd, sa, funct} == `ID_TLBR) get_aluop = `ALUOP_TLBR;
            else if ({op, rs, rt, rd, sa, funct} == `ID_TLBWI) get_aluop = `ALUOP_TLBWI;
            else if ({op, rs, rt, rd, sa, funct} == `ID_TLBWR) get_aluop = `ALUOP_TLBWR;
            else get_aluop = `ALUOP_RI;
        end
        `ID_ADDI    : get_aluop = `ALUOP_ADDI    ;
        `ID_ADDIU   : get_aluop = `ALUOP_ADDIU   ;
        `ID_ANDI    : get_aluop = `ALUOP_ANDI    ;
        `ID_ORI     : get_aluop = `ALUOP_ORI     ;
        `ID_XORI    : get_aluop = `ALUOP_XORI    ;
        `ID_LUI     : get_aluop = `ALUOP_LUI     ;
        `ID_SLTI    : get_aluop = `ALUOP_SLTI    ;
        `ID_SLTIU   : get_aluop = `ALUOP_SLTIU   ;
        `ID_BEQ     : get_aluop = `ALUOP_BEQ     ;
        `ID_BNE     : get_aluop = `ALUOP_BNE     ;
        `ID_BGTZ    : get_aluop = `ALUOP_BGTZ    ;
        `ID_BLEZ    : get_aluop = `ALUOP_BLEZ    ;
        `ID_LB      : get_aluop = `ALUOP_LB      ;
        `ID_LBU     : get_aluop = `ALUOP_LBU     ;
        `ID_LH      : get_aluop = `ALUOP_LH      ;
        `ID_LHU     : get_aluop = `ALUOP_LHU     ;
        `ID_LW      : get_aluop = `ALUOP_LW      ;
        `ID_SB      : get_aluop = `ALUOP_SB      ;
        `ID_SH      : get_aluop = `ALUOP_SH      ;
        `ID_SW      : get_aluop = `ALUOP_SW      ;
        `ID_LWL     : get_aluop = `ALUOP_LWL     ;
        `ID_LWR     : get_aluop = `ALUOP_LWR     ;
        `ID_SWL     : get_aluop = `ALUOP_SWL     ;
        `ID_SWR     : get_aluop = `ALUOP_SWR     ;
        `ID_J       : get_aluop = `ALUOP_J       ;
        `ID_JAL     : get_aluop = `ALUOP_JAL     ;
        default: get_aluop = `ALUOP_RI;
        endcase
    end
end
endfunction
    
    wire is_NOP      = aluop == `ALUOP_NOP      ? 1'b1 : 1'b0;
    wire is_AND      = aluop == `ALUOP_AND      ? 1'b1 : 1'b0;
    wire is_ADD      = aluop == `ALUOP_ADD      ? 1'b1 : 1'b0;
    wire is_ADDU     = aluop == `ALUOP_ADDU     ? 1'b1 : 1'b0;
    wire is_NOR      = aluop == `ALUOP_NOR      ? 1'b1 : 1'b0;
    wire is_OR       = aluop == `ALUOP_OR       ? 1'b1 : 1'b0;
    wire is_XOR      = aluop == `ALUOP_XOR      ? 1'b1 : 1'b0;
    wire is_SLL      = aluop == `ALUOP_SLL      ? 1'b1 : 1'b0;
    wire is_SLLV     = aluop == `ALUOP_SLLV     ? 1'b1 : 1'b0;
    wire is_SRL      = aluop == `ALUOP_SRL      ? 1'b1 : 1'b0;
    wire is_SRLV     = aluop == `ALUOP_SRLV     ? 1'b1 : 1'b0;
    wire is_SRA      = aluop == `ALUOP_SRA      ? 1'b1 : 1'b0;
    wire is_SRAV     = aluop == `ALUOP_SRAV     ? 1'b1 : 1'b0;
    wire is_SLT      = aluop == `ALUOP_SLT      ? 1'b1 : 1'b0;
    wire is_SLTU     = aluop == `ALUOP_SLTU     ? 1'b1 : 1'b0;
    wire is_SUB      = aluop == `ALUOP_SUB      ? 1'b1 : 1'b0;
    wire is_SUBU     = aluop == `ALUOP_SUBU     ? 1'b1 : 1'b0;
    wire is_MULT     = aluop == `ALUOP_MULT     ? 1'b1 : 1'b0;
    wire is_MULTU    = aluop == `ALUOP_MULTU    ? 1'b1 : 1'b0;
    wire is_DIV      = aluop == `ALUOP_DIV      ? 1'b1 : 1'b0;
    wire is_DIVU     = aluop == `ALUOP_DIVU     ? 1'b1 : 1'b0;
    wire is_JALR     = aluop == `ALUOP_JALR     ? 1'b1 : 1'b0;
    wire is_JR       = aluop == `ALUOP_JR       ? 1'b1 : 1'b0;
    wire is_SYSCALL  = aluop == `ALUOP_SYSCALL  ? 1'b1 : 1'b0;
    wire is_BREAK    = aluop == `ALUOP_BREAK    ? 1'b1 : 1'b0;
    wire is_MFHI     = aluop == `ALUOP_MFHI     ? 1'b1 : 1'b0;
    wire is_MTHI     = aluop == `ALUOP_MTHI     ? 1'b1 : 1'b0;
    wire is_MFLO     = aluop == `ALUOP_MFLO     ? 1'b1 : 1'b0;
    wire is_MTLO     = aluop == `ALUOP_MTLO     ? 1'b1 : 1'b0;
    wire is_TEQ      = aluop == `ALUOP_TEQ      ? 1'b1 : 1'b0;
    wire is_TGE      = aluop == `ALUOP_TGE      ? 1'b1 : 1'b0;
    wire is_TGEU     = aluop == `ALUOP_TGEU     ? 1'b1 : 1'b0;
    wire is_TLT      = aluop == `ALUOP_TLT      ? 1'b1 : 1'b0;
    wire is_TLTU     = aluop == `ALUOP_TLTU     ? 1'b1 : 1'b0;
    wire is_TNE      = aluop == `ALUOP_TNE      ? 1'b1 : 1'b0;
    wire is_MOVN     = aluop == `ALUOP_MOVN     ? 1'b1 : 1'b0;
    wire is_MOVZ     = aluop == `ALUOP_MOVZ     ? 1'b1 : 1'b0;
    wire is_CLO      = aluop == `ALUOP_CLO      ? 1'b1 : 1'b0;
    wire is_CLZ      = aluop == `ALUOP_CLZ      ? 1'b1 : 1'b0;
    wire is_BGEZ     = aluop == `ALUOP_BGEZ     ? 1'b1 : 1'b0;
    wire is_BGEZAL   = aluop == `ALUOP_BGEZAL   ? 1'b1 : 1'b0;
    wire is_BLTZ     = aluop == `ALUOP_BLTZ     ? 1'b1 : 1'b0;
    wire is_BLTZAL   = aluop == `ALUOP_BLTZAL   ? 1'b1 : 1'b0;
    wire is_TEQI     = aluop == `ALUOP_TEQI     ? 1'b1 : 1'b0;
    wire is_TGEI     = aluop == `ALUOP_TGEI     ? 1'b1 : 1'b0;
    wire is_TGEIU    = aluop == `ALUOP_TGEIU    ? 1'b1 : 1'b0;
    wire is_TLTI     = aluop == `ALUOP_TLTI     ? 1'b1 : 1'b0;
    wire is_TLTIU    = aluop == `ALUOP_TLTIU    ? 1'b1 : 1'b0;
    wire is_TNEI     = aluop == `ALUOP_TNEI     ? 1'b1 : 1'b0;
    wire is_MFC0     = aluop == `ALUOP_MFC0     ? 1'b1 : 1'b0;
    wire is_MTC0     = aluop == `ALUOP_MTC0     ? 1'b1 : 1'b0;
    wire is_ERET     = aluop == `ALUOP_ERET     ? 1'b1 : 1'b0; 
    wire is_TLBP     = aluop == `ALUOP_TLBP     ? 1'b1 : 1'b0;
    wire is_TLBR     = aluop == `ALUOP_TLBR     ? 1'b1 : 1'b0;
    wire is_TLBWR    = aluop == `ALUOP_TLBWR    ? 1'b1 : 1'b0;
    wire is_TLBWI    = aluop == `ALUOP_TLBWI    ? 1'b1 : 1'b0; 
    wire is_ADDI     = aluop == `ALUOP_ADDI     ? 1'b1 : 1'b0;
    wire is_ADDIU    = aluop == `ALUOP_ADDIU    ? 1'b1 : 1'b0;
    wire is_ANDI     = aluop == `ALUOP_ANDI     ? 1'b1 : 1'b0;
    wire is_ORI      = aluop == `ALUOP_ORI      ? 1'b1 : 1'b0;
    wire is_XORI     = aluop == `ALUOP_XORI     ? 1'b1 : 1'b0;
    wire is_LUI      = aluop == `ALUOP_LUI      ? 1'b1 : 1'b0;
    wire is_SLTI     = aluop == `ALUOP_SLTI     ? 1'b1 : 1'b0;
    wire is_SLTIU    = aluop == `ALUOP_SLTIU    ? 1'b1 : 1'b0;
    wire is_BEQ      = aluop == `ALUOP_BEQ      ? 1'b1 : 1'b0;
    wire is_BNE      = aluop == `ALUOP_BNE      ? 1'b1 : 1'b0;
    wire is_BGTZ     = aluop == `ALUOP_BGTZ     ? 1'b1 : 1'b0;
    wire is_BLEZ     = aluop == `ALUOP_BLEZ     ? 1'b1 : 1'b0;
    wire is_LB       = aluop == `ALUOP_LB       ? 1'b1 : 1'b0;
    wire is_LBU      = aluop == `ALUOP_LBU      ? 1'b1 : 1'b0;
    wire is_LH       = aluop == `ALUOP_LH       ? 1'b1 : 1'b0;
    wire is_LHU      = aluop == `ALUOP_LHU      ? 1'b1 : 1'b0;
    wire is_LW       = aluop == `ALUOP_LW       ? 1'b1 : 1'b0;
    wire is_SB       = aluop == `ALUOP_SB       ? 1'b1 : 1'b0;
    wire is_SH       = aluop == `ALUOP_SH       ? 1'b1 : 1'b0;
    wire is_SW       = aluop == `ALUOP_SW       ? 1'b1 : 1'b0;
    wire is_LWL      = aluop == `ALUOP_LWL      ? 1'b1 : 1'b0;
    wire is_LWR      = aluop == `ALUOP_LWR      ? 1'b1 : 1'b0;
    wire is_SWL      = aluop == `ALUOP_SWL      ? 1'b1 : 1'b0;
    wire is_SWR      = aluop == `ALUOP_SWR      ? 1'b1 : 1'b0;
    wire is_J        = aluop == `ALUOP_J        ? 1'b1 : 1'b0;
    wire is_JAL      = aluop == `ALUOP_JAL      ? 1'b1 : 1'b0;
    wire is_RI       = aluop == `ALUOP_RI       ? 1'b1 : 1'b0;
    
    wire rs_read_en, rt_read_en;
    assign rs_read_en = is_AND | is_ADD | is_ADDU | is_NOR | is_OR | is_XOR | is_SLLV | is_SRLV | is_SRAV | is_SLT | is_SLTU |
                        is_SUB | is_SUBU | is_MULT | is_MULTU | is_DIV | is_DIVU | is_JR | is_JALR | is_MTHI | is_MTLO | is_TEQ |
                        is_TGE | is_TGEU | is_TLT | is_TLTU | is_TNE | is_MOVN | is_MOVZ | is_CLO | is_CLZ | is_BGEZ | is_BGEZAL |
                        is_BLTZ | is_BLTZAL | is_TEQI | is_TGEI | is_TGEIU | is_TLTI | is_TLTIU | is_TNEI | is_ADDI | is_ADDIU |
                        is_ANDI | is_ORI | is_XORI | is_SLTI | is_SLTIU | is_BEQ | is_BNE | is_BGTZ | is_BLEZ | is_LB | is_LBU | 
                        is_LH | is_LHU | is_LW | is_SB | is_SH | is_SW | is_LWL | is_LWR | is_SWL | is_SWR;
                        
    assign rt_read_en = is_AND | is_ADD | is_ADDU | is_NOR | is_OR | is_XOR | is_SLL | is_SLLV | is_SRL | is_SRLV | is_SRA | is_SRAV |
                        is_SLT | is_SLTU | is_SUB | is_SUBU | is_MULT | is_MULTU | is_DIV | is_DIVU | is_TEQ | is_TGE | is_TGEU | is_TLT |
                        is_TLTU | is_TNE | is_MOVN | is_MOVZ | is_MTC0 | is_BEQ | is_BNE | is_BGTZ | is_BLEZ | is_SB | is_SH | is_SW | 
                        is_LWL | is_LWR | is_SWL | is_SWR;
                        
    wire[4:0] ex_mem_reg_waddr, mem_mem_reg_waddr;
    wire[4:0] rs_reg_read_addr, rt_reg_read_addr;
    assign ex_mem_reg_waddr = bypass_ex_regfile_waddr_i & {5{ex_mem_to_reg_i}};
    assign mem_mem_reg_waddr = bypass_mem_regfile_waddr_i & {5{mem_mem_to_reg_i}};
    assign rs_reg_read_addr = {5{rs_read_en}} & rs;
    assign rt_reg_read_addr = {5{rt_read_en}} & rt;
    assign id_stall_o = (ex_mem_reg_waddr != 5'b0 && (ex_mem_reg_waddr == rs_reg_read_addr || ex_mem_reg_waddr == rt_reg_read_addr)) ||
                        (mem_mem_reg_waddr != 5'b0 && (mem_mem_reg_waddr == rs_reg_read_addr || mem_mem_reg_waddr == rt_reg_read_addr));
    
    assign rs_data_o = get_reg_data_o(rs_data_i, rs_reg_read_addr,
                                     bypass_ex_regfile_wdata_i, bypass_ex_regfile_waddr_i, bypass_ex_regfile_wen_i,
                                     bypass_mem_regfile_wdata_i, bypass_mem_regfile_waddr_i, bypass_mem_regfile_wen_i);
    assign rt_data_o = get_reg_data_o(rt_data_i, rt_reg_read_addr,
                                     bypass_ex_regfile_wdata_i, bypass_ex_regfile_waddr_i, bypass_ex_regfile_wen_i,
                                     bypass_mem_regfile_wdata_i, bypass_mem_regfile_waddr_i, bypass_mem_regfile_wen_i);
// regfile read data forward                                  
function [31:0] get_reg_data_o(input [31:0] reg_data, input [4:0] reg_read_addr, 
                              input [31:0] ex_regfile_wdata,  input [4:0] ex_regfile_waddr, input ex_regfile_wen,
                              input [31:0] mem_regfile_wdata,  input [4:0] mem_regfile_waddr, input mem_regfile_wen);
    begin
        if (reg_read_addr != 5'b0 && reg_read_addr == ex_regfile_waddr && ex_regfile_wen)
            get_reg_data_o = ex_regfile_wdata;
        else if (reg_read_addr != 5'b0 && reg_read_addr == mem_regfile_waddr && mem_regfile_wen)
            get_reg_data_o = mem_regfile_wdata;
        else get_reg_data_o = reg_data;
    end
endfunction


    assign regfile_wen_o = is_AND | is_ADD | is_ADDU | is_NOR | is_OR | is_XOR | is_SLL | is_SLLV | is_SRL | is_SRLV | is_SRA | is_SRAV |
                           is_SLT | is_SLTU | is_SUB | is_SUBU | is_JALR | is_MFHI | is_MFLO | is_MOVN | is_MOVZ | is_CLO | is_CLZ | 
                           is_BGEZAL | is_BLTZAL | is_MFC0 | is_ADDI | is_ADDIU | is_ANDI | is_ORI | is_XORI | is_LUI | is_SLTI | is_SLTIU |
                           is_LB | is_LBU | is_LH | is_LHU | is_LW | is_LWL | is_LWR | is_JAL;
    
    wire waddr_is_rt, waddr_is_31;
    assign waddr_is_rt = is_MFC0 | is_ADDI | is_ADDIU | is_ANDI | is_ORI | is_XORI | is_LUI | is_SLTI | is_SLTIU | is_LB | is_LBU | is_LH | 
                         is_LHU | is_LW | is_LWL | is_LWR;
    assign waddr_is_31 = is_BGEZAL | is_BLTZAL | is_JAL;
    assign regfile_waddr_o = waddr_is_31 ? 5'b11111 : (waddr_is_rt ? rt : rd);
    
    assign hi_wen_o = is_DIV || is_DIVU || is_MULT || is_MULTU || is_MTHI;
    assign lo_wen_o = is_DIV || is_DIVU || is_MULT || is_MULTU || is_MTLO;
    assign hilo_addr_o = (is_MFHI == 1'b1) ? 1'b1 : 1'b0;
    
    assign mem_to_reg_o = is_LB || is_LBU || is_LH || is_LHU || is_LW || is_LWL || is_LWR;
    
    assign cp0_wen_o = is_MTC0;
    assign cp0_addr_o = rd;
    assign cp0_sel_o = instruction_i[2:0];
    
    wire is_jump, is_branch;
    wire exe_BEQ, exe_BNE, exe_BGEZ, exe_BGEZAL, exe_BLTZ, exe_BLTZAL, exe_BGTZ, exe_BLEZ, exe_branch;
    wire exe_jump;
    wire[31:0] pc_add4 = pc_i + 4;
    assign next_in_delayslot_o = is_jump || is_branch;
    assign is_jump = is_J || is_JAL || is_JR || is_JALR;
    assign is_branch = is_BEQ || is_BNE || is_BGEZ || is_BGEZAL || is_BLTZ || is_BLTZAL || is_BGTZ || is_BLEZ;
    assign exe_jump = is_jump;
    assign exe_branch = exe_BEQ | exe_BNE | exe_BGEZ | exe_BGEZAL | exe_BLTZ | exe_BLTZAL | exe_BGTZ | exe_BLEZ;
    assign branch = exe_jump || exe_branch;
    assign branch_pc = (exe_branch == 1'b1) ? pc_add4 + {{14{instruction_i[15]}}, instruction_i[15:0], 2'b00} : 
                       (is_JR || is_JALR) ? rs_data_o : {pc_add4[31:28], instruction_i[25:0], 2'b00};
    assign exe_BEQ = (rs_data_o == rt_data_o && is_BEQ == 1'b1) ? 1'b1 : 1'b0;
    assign exe_BNE = (rs_data_o != rt_data_o && is_BNE == 1'b1) ? 1'b1 : 1'b0;
    assign exe_BGEZ = (rs_data_o[31] == 1'b0 && is_BGEZ == 1'b1) ? 1'b1 : 1'b0;
    assign exe_BGEZAL = (rs_data_o[31] == 1'b0 && is_BGEZAL == 1'b1) ? 1'b1 : 1'b0;
    assign exe_BLTZ = (rs_data_o[31] == 1'b1 && is_BLTZ == 1'b1) ? 1'b1 : 1'b0;
    assign exe_BLTZAL = (rs_data_o[31] == 1'b1 && is_BLTZAL == 1'b1) ? 1'b1 : 1'b0;
    assign exe_BGTZ = (rs_data_o[31] == 1'b0 && rs_data_o != 32'b0 && is_BGTZ == 1'b1) ? 1'b1 : 1'b0;
    assign exe_BLEZ = ((rs_data_o[31] == 1'b1 || rs_data_o == 32'b0) && is_BLEZ == 1'b1) ? 1'b1 : 1'b0;
    
    
    
    wire is_write_mem;
    assign mem_en_o = is_write_mem || is_LW || is_LH || is_LHU || is_LB || is_LBU || is_LWL || is_LWR;
    assign is_write_mem = is_SB || is_SH || is_SW || is_SWL || is_SWR;
    assign exception_type_o = {exception_type_i[31:28], is_RI, exception_type_i[26:25], is_SYSCALL, is_BREAK, exception_type_i[22:2], is_write_mem, is_ERET};
endmodule
