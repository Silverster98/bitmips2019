`timescale 1ns / 1ps

`include "defines.vh"

module ex(
    input   wire        rst,
    input   wire        clk, // for div
    
    input   wire[31:0]  pc_i,
    input   wire[31:0]  exception_type_i,
    input   wire[31:0]  instruction_i,
    input   wire        in_delayslot_i,
    input   wire[7:0]   aluop_i,
    input   wire        regfile_wen_i,
    input   wire[4:0]   regfile_waddr_i,
    input   wire        hi_wen_i,
    input   wire        lo_wen_i,
    input   wire        mem_en_i,
    input   wire        mem_to_reg_i,
    input   wire        cp0_wen_i,
    input   wire[4:0]   cp0_addr_i,
    input   wire[2:0]   cp0_sel_i,
    input   wire[31:0]  rs_data_i,
    input   wire[31:0]  rt_data_i,
    input   wire[31:0]  cp0_rdata_i,
    input   wire[31:0]  hilo_rdata_i,
    
    output  wire[31:0]  pc_o,
    output  wire[31:0]  exception_type_o,
    output  wire[31:0]  instruction_o,
    output  wire        in_delayslot_o,
    output  wire[7:0]   aluop_o,
    output  wire        regfile_wen_o,
    output  wire[4:0]   regfile_waddr_o,
    output  wire        hi_wen_o,
    output  wire[31:0]  hi_wdata_o,
    output  wire        lo_wen_o,
    output  wire[31:0]  lo_wdata_o,
    output  wire        cp0_wen_o,
    output  wire[4:0]   cp0_addr_o,
    output  wire[2:0]   cp0_sel_o,
    output  wire        mem_en_o,
    output  wire        mem_to_reg_o,
    output  wire[31:0]  alu_data_o,
    output  wire[31:0]  rt_data_o,
    
    output  wire        ex_stall_o
    );
    
    wire[31:0] sign_extend_imm16;
    assign sign_extend_imm16 = {{16{instruction_i[15]}}, instruction_i[15:0]};
    wire[15:0] imm16;
    assign imm16 = instruction_i[15:0];
    wire[4:0] sa;
    assign sa = instruction_i[10:6];
    wire[31:0] pc_return_addr;
    assign pc_return_addr = pc_i + 8;
    
    wire[31:0] alu_output_data;
    wire is_overflow;
    wire[63:0] mul_data, div_data, hilo_write_data;
    
    assign pc_o = pc_i;
    assign instruction_o = instruction_i;
    assign in_delayslot_o = in_delayslot_i;
    assign aluop_o = aluop_i;
    assign regfile_wen_o = regfile_wen_i;
    assign hi_wen_o = hi_wen_i;
    assign hi_wdata_o = hilo_write_data[63:32];
    assign lo_wen_o = lo_wen_i;
    assign lo_wdata_o = hilo_write_data[31:0];
    assign cp0_wen_o = cp0_wen_i;
    assign cp0_addr_o = cp0_addr_i;
    assign cp0_sel_o = cp0_sel_i;
    assign mem_en_o = mem_en_i;
    assign mem_to_reg_o = mem_to_reg_i;
    assign alu_data_o = alu_output_data;
    assign rt_data_o = rt_data_i;
    
    // div
    wire div_stall, start, flag_unsigned, div_done;
    assign start = (aluop_i == `ALUOP_DIV || aluop_i == `ALUOP_DIVU) ? 1 : 0;
    assign flag_unsigned = (aluop_i == `ALUOP_DIVU) ? 1 : 0;
    assign div_stall = (aluop_i == `ALUOP_DIV || aluop_i == `ALUOP_DIVU) ? !div_done : 0;
    assign ex_stall_o  = rst == `RST_ENABLE ? 1'b0 : div_stall;
    
    div_wrapper div_wrapper0(
        .clock(clk),
        .reset(rst),
        .start(start),
        .flag_unsigned(flag_unsigned),
        .operand1(rs_data_i),
        .operand2(rt_data_i),
        .result(div_data),
        .done(div_done)
    );
    
    
    //  get alu output
    assign alu_output_data = get_alu_data(aluop_i, sa, rs_data_i, rt_data_i, imm16, pc_return_addr, hilo_rdata_i, cp0_rdata_i);
    
function [31:0] get_alu_data(input [7:0] aluop, input [4:0] sa, input [31:0] rs_value, input [31:0] rt_value,
                             input [15:0] imm16, input [31:0] pc_return_addr, input [31:0] hilo_rdata, input [31:0] cp0_rdata);
    case (aluop)
        `ALUOP_ADD, `ALUOP_ADDU : begin
            get_alu_data = rs_value + rt_value;
        end
        `ALUOP_ADDI : begin
            get_alu_data = rs_value + {{16{imm16[15]}}, imm16};
        end
        `ALUOP_ADDIU : begin
            get_alu_data = rs_value + {{16{imm16[15]}}, imm16};
        end
        `ALUOP_SUB, `ALUOP_SUBU : begin
            get_alu_data = rs_value - rt_value;
        end
        `ALUOP_SLT : begin
            get_alu_data = $signed(rs_value) < $signed(rt_value);
        end
        `ALUOP_SLTI : begin
            get_alu_data = $signed(rs_value) < $signed({{16{imm16[15]}}, imm16});
        end
        `ALUOP_SLTU : begin
            get_alu_data = $unsigned(rs_value) < $unsigned(rt_value);
        end
        `ALUOP_SLTIU : begin
            get_alu_data = $unsigned(rs_value) < $unsigned({{16{imm16[15]}}, imm16});
        end
        `ALUOP_AND : begin
            get_alu_data = rs_value & rt_value;
        end
        `ALUOP_ANDI : begin
            get_alu_data = rs_value & {16'b0, imm16};
        end
        `ALUOP_LUI : begin
            get_alu_data = {imm16, 16'b0};
        end
        `ALUOP_NOR : begin
            get_alu_data = ~(rs_value | rt_value);
        end
        `ALUOP_OR : begin
            get_alu_data = rs_value | rt_value;
        end
        `ALUOP_ORI : begin
            get_alu_data = rs_value | {16'b0, imm16};
        end
        `ALUOP_XOR : begin
            get_alu_data = rs_value ^ rt_value;
        end
        `ALUOP_XORI : begin
            get_alu_data = rs_value ^ {16'b0, imm16};
        end
        `ALUOP_SLL : begin
            get_alu_data = rt_value << sa;
        end
        `ALUOP_SLLV : begin
            get_alu_data = rt_value << rs_value[4:0];
        end
        `ALUOP_SRA : begin
            get_alu_data = $signed(rt_value) >>> sa;
        end
        `ALUOP_SRAV : begin
            get_alu_data = $signed(rt_value) >>> rs_value[4:0];
        end
        `ALUOP_SRL : begin
            get_alu_data = rt_value >> sa;
        end
        `ALUOP_SRLV : begin
            get_alu_data = rt_value >> rs_value[4:0];
        end
        `ALUOP_BGEZAL, `ALUOP_BLTZAL, `ALUOP_JAL, `ALUOP_JALR : begin
            get_alu_data = pc_return_addr;
        end
        `ALUOP_MFHI, `ALUOP_MFLO: begin
            get_alu_data = hilo_rdata;
        end
        `ALUOP_LB, `ALUOP_LBU, `ALUOP_LH, `ALUOP_LHU, `ALUOP_LW, `ALUOP_LWL, `ALUOP_LWR,
        `ALUOP_SB, `ALUOP_SH, `ALUOP_SW, `ALUOP_SWL, `ALUOP_SWR : begin
            get_alu_data = rs_value + {{16{imm16[15]}}, imm16};
        end
        `ALUOP_MFC0 : begin
            get_alu_data = cp0_rdata;
        end
        `ALUOP_MOVN, `ALUOP_MOVZ : begin
            get_alu_data = rs_value;
        end
        `ALUOP_CLZ : begin
            get_alu_data =  rs_value[31] ? 0 : rs_value[30] ? 1 : rs_value[29] ? 2 : rs_value[28] ? 3 :
                            rs_value[27] ? 4 : rs_value[26] ? 5 : rs_value[25] ? 6 : rs_value[24] ? 7 :
                            rs_value[23] ? 8 : rs_value[22] ? 9 : rs_value[21] ? 10 : rs_value[20] ? 11 :
                            rs_value[19] ? 12 : rs_value[18] ? 13 : rs_value[17] ? 14 : rs_value[16] ? 15 :
                            rs_value[15] ? 16 : rs_value[14] ? 17 : rs_value[13] ? 18 : rs_value[12] ? 19 :
                            rs_value[11] ? 20 : rs_value[10] ? 21 : rs_value[9] ? 22 : rs_value[8] ? 23 :
                            rs_value[7] ? 24 : rs_value[6] ? 25 : rs_value[5] ? 26 : rs_value[4] ? 27 :
                            rs_value[3] ? 28 : rs_value[2] ? 29 : rs_value[1] ? 30 : rs_value[0] ? 31 : 32;
        end
        `ALUOP_CLO : begin
            get_alu_data =  ~rs_value[31] ? 0 : ~rs_value[30] ? 1 : ~rs_value[29] ? 2 : ~rs_value[28] ? 3 :
                            ~rs_value[27] ? 4 : ~rs_value[26] ? 5 : ~rs_value[25] ? 6 : ~rs_value[24] ? 7 :
                            ~rs_value[23] ? 8 : ~rs_value[22] ? 9 : ~rs_value[21] ? 10 : ~rs_value[20] ? 11 :
                            ~rs_value[19] ? 12 : ~rs_value[18] ? 13 : ~rs_value[17] ? 14 : ~rs_value[16] ? 15 :
                            ~rs_value[15] ? 16 : ~rs_value[14] ? 17 : ~rs_value[13] ? 18 : ~rs_value[12] ? 19 :
                            ~rs_value[11] ? 20 : ~rs_value[10] ? 21 : ~rs_value[9] ? 22 : ~rs_value[8] ? 23 :
                            ~rs_value[7] ? 24 : ~rs_value[6] ? 25 : ~rs_value[5] ? 26 : ~rs_value[4] ? 27 :
                            ~rs_value[3] ? 28 : ~rs_value[2] ? 29 : ~rs_value[1] ? 30 : ~rs_value[0] ? 31 : 32;
        end
        default : begin
            get_alu_data = 0;
        end
    endcase
endfunction
    
    assign is_overflow = get_is_overflow(aluop_i, rs_data_i, rt_data_i, sign_extend_imm16, alu_output_data);
function get_is_overflow(input [7:0] aluop, input [31:0] rs_value, input [31:0] rt_value, 
                         input [31:0] sign_extend_imm16, input [31:0] alu_output_data);
    begin
        if (aluop == `ALUOP_ADD) begin
            if ((rs_value[31] == 0 && rt_value[31] == 0 && alu_output_data[31] == 1) 
	    		|| (rs_value[31] == 1 && rt_value[31] == 1 && alu_output_data[31] == 0)) begin
	            get_is_overflow = 1;
	        end else get_is_overflow = 0;
        end
        else if (aluop == `ALUOP_ADDI) begin
            if ((rs_value[31] == 0 && sign_extend_imm16[31] == 0 && alu_output_data[31] == 1) 
	    		|| (rs_value[31] == 1 && sign_extend_imm16[31] == 1 && alu_output_data[31] == 0)) begin
	            get_is_overflow = 1;
	        end else get_is_overflow = 0;
        end
        else if (aluop == `ALUOP_SUB) begin
            if ((rs_value[31] == 0 && rt_value[31] == 1 && alu_output_data[31] == 1)
                || rs_value[31] == 1 && rt_value[31] == 0 && alu_output_data[31] == 0) begin
                get_is_overflow = 1;
            end else get_is_overflow = 0;
        end else get_is_overflow = 0;
    end
endfunction
    
    assign regfile_waddr_o = (is_overflow == 1'b1 || (aluop_i == `ALUOP_MOVN && rt_data_i == 32'b0) || 
                                (aluop_i == `ALUOP_MOVZ && rt_data_i != 32'b0)) ? 5'b0 : regfile_waddr_i;
    
    assign hilo_write_data = get_hilo_write_data(aluop_i, mul_data, div_data, rs_data_i);
function [63:0] get_hilo_write_data(input [7:0] aluop, input [63:0] mul_data, input [63:0] div_data, input [31:0] rs_value);
    begin
        case (aluop)
            `ALUOP_MTHI, `ALUOP_MTLO : begin
                get_hilo_write_data = {rs_value, rs_value};
            end
            `ALUOP_MULT, `ALUOP_MULTU : begin
                get_hilo_write_data = mul_data;
            end
            `ALUOP_DIV, `ALUOP_DIVU : begin
                get_hilo_write_data = div_data;
            end
            default : begin
                get_hilo_write_data = 0;
            end
        endcase
    end
endfunction
    
    assign mul_data = get_mult_data(aluop_i, rs_data_i, rt_data_i); 
function [63:0] get_mult_data(input [7:0] aluop, input [31:0] rs_value, input [31:0] rt_value);
    begin
        case (aluop)
            `ALUOP_MULT : begin
                get_mult_data = $signed(rs_value) * $signed(rt_value);
            end
            `ALUOP_MULTU : begin
                get_mult_data = $unsigned(rs_value) * $unsigned(rt_value);
            end
            default : begin
                get_mult_data = 0;
            end
        endcase
    end
endfunction

    wire is_trap;
    assign is_trap = get_is_trap(aluop_i, rs_data_i, rt_data_i, sign_extend_imm16);
function get_is_trap(input [7:0] aluop, input [31:0] rs_value, input [31:0] rt_value, input [31:0] sign_extend_imm16);
begin
    case (aluop)
        `ALUOP_TEQ : begin
            get_is_trap = (rs_value == rt_value) ? 1'b1 : 1'b0;
        end
        `ALUOP_TGE : begin
            get_is_trap = ($signed(rs_value) >= $signed(rt_value)) ? 1'b1 : 1'b0;
        end
        `ALUOP_TGEU : begin
            get_is_trap = ($unsigned(rs_value) >= $unsigned(rt_value)) ? 1'b1 : 1'b0;
        end
        `ALUOP_TLT  : begin
            get_is_trap = ($signed(rs_value) < $signed(rt_value)) ? 1'b1 : 1'b0;
        end
        `ALUOP_TLTU : begin
            get_is_trap = ($unsigned(rs_value) < $unsigned(rt_value)) ? 1'b1 : 1'b0;
        end
        `ALUOP_TNE  : begin
            get_is_trap = (rs_value != rt_value) ? 1'b1 : 1'b0;
        end
        `ALUOP_TEQI : begin
            get_is_trap = (rs_value == sign_extend_imm16) ? 1'b1 : 1'b0;
        end
        `ALUOP_TGEI : begin
            get_is_trap = ($signed(rs_value) >= $signed(sign_extend_imm16)) ? 1'b1 : 1'b0;
        end
        `ALUOP_TGEIU: begin
            get_is_trap = ($unsigned(rs_value) >= $unsigned(sign_extend_imm16)) ? 1'b1 : 1'b0;
        end
        `ALUOP_TLTI : begin
            get_is_trap = ($signed(rs_value) < $signed(sign_extend_imm16)) ? 1'b1 : 1'b0;
        end
        `ALUOP_TLTIU: begin
            get_is_trap = ($unsigned(rs_value) < $unsigned(sign_extend_imm16)) ? 1'b1 : 1'b0;
        end
        `ALUOP_TNEI : begin
            get_is_trap = (rs_value != sign_extend_imm16) ? 1'b1 : 1'b0;
        end
        default : begin
            get_is_trap = 1'b0;
        end
    endcase
end
endfunction

    assign exception_type_o = {exception_type_i[31:27], is_overflow, is_trap, exception_type_i[24:0]};

endmodule
