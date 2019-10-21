`include "defines.v"

module ex(
    input wire                   rst,
    input wire                   clk,
    input wire[`INST_ADDR_BUS]   pc_i,
    input wire[`GPR_BUS]         rs_data_i,
    input wire[`GPR_BUS]         rt_data_i,
    input wire[`INST_BUS]        instr_i,
    input wire[`ALUOP_BUS]       aluop_i,
    input wire[`GPR_ADDR_BUS]    regfile_write_addr_i,
    input wire                   now_in_delayslot_i,
    input wire[`EXCEP_TYPE_BUS]  exception_type_i,
    input wire                   regfile_write_enable_i,
    input wire                   ram_write_enable_i,
    input wire                   hi_write_enable_i,
    input wire                   lo_write_enable_i,
    input wire                   cp0_write_enable_i,
    input wire[`GPR_BUS]         hilo_data_i,
    input wire[`GPR_BUS]         cp0_data_i,
    input wire                   mem_to_reg_i,
    input wire[`INST_ADDR_BUS]   pc_return_addr_i,
    input wire[`GPR_BUS]         sign_extend_imm16_i,
    input wire[`GPR_BUS]         zero_extend_imm16_i,
    input wire[`GPR_BUS]         load_upper_imm16_i,
    
    input wire                   bypass_mem_hi_write_enable_i,
    input wire[`GPR_BUS]         bypass_mem_hi_write_data_i,
    input wire                   bypass_mem_lo_write_enable_i,
    input wire[`GPR_BUS]         bypass_mem_lo_write_data_i,
    input wire                   bypass_mem_cp0_write_enable_i,
    input wire[`CP0_ADDR_BUS]    bypass_mem_cp0_write_addr_i,
    input wire[`CP0_BUS]         bypass_mem_cp0_write_data_i,
    input wire                   bypass_wb_hi_write_enable_i,
    input wire[`GPR_BUS]         bypass_wb_hi_write_data_i,
    input wire                   bypass_wb_lo_write_enable_i,
    input wire[`GPR_BUS]         bypass_wb_lo_write_data_i,
//    input wire                   bypass_wb_cp0_write_enable_i,
//    input wire[`CP0_ADDR_BUS]    bypass_wb_cp0_write_addr_i,
//    input wire[`CP0_BUS]         bypass_wb_cp0_write_data_i,
    
    input wire                   hilo_read_addr_i,
    input wire[`CP0_ADDR_BUS]    cp0_read_addr_i,
    
    output wire[`INST_ADDR_BUS]   pc_o,
    output wire[`ALUOP_BUS]       aluop_o,
    output wire                   now_in_delayslot_o,
    output wire[`EXCEP_TYPE_BUS]  exception_type_o,       ///
    output wire                   regfile_write_enable_o,
    output wire                   ram_write_enable_o,
    output wire                   hi_write_enable_o,
    output wire                   lo_write_enable_o,
    output wire                   cp0_write_enable_o,
    output wire[`GPR_ADDR_BUS]    regfile_write_addr_o,  ///
//    output wire[`RAM_ADDR_BUS]   ram_write_addr_o,
    output wire[`CP0_ADDR_BUS]    cp0_write_addr_o,
    output wire[`GPR_BUS]         alu_data_o,
    output wire[`GPR_BUS]         ram_write_data_o,
    output wire[`GPR_BUS]         hi_write_data_o,
    output wire[`GPR_BUS]         lo_write_data_o,
    output wire[`GPR_BUS]         cp0_write_data_o,
    output wire                   mem_to_reg_o,
    output wire                   exe_stall_request_o,
    
    output wire[2:0]              sel
    );
    
    assign sel = instr_i[2:0];
    
    wire is_overflow;
    wire is_trap;
    //wire exception_temp;
    assign exception_type_o = {exception_type_i[31:30], is_overflow, exception_type_i[28:25], is_trap, exception_type_i[23:0]};
    
    wire[`GPR_BUS] alu_output_data;
    wire[`GPR_BUS] hilo_data_forward, cp0_data_forward;
    wire[63:0] mul_data, div_data, hilo_write_data;
    wire start, div_done, flag_unsigned, div_stall;
    assign start = (aluop_i == `ALUOP_DIV || aluop_i == `ALUOP_DIVU) ? 1 : 0;
    assign flag_unsigned = (aluop_i == `ALUOP_DIVU) ? 1 : 0;
    assign div_stall = (aluop_i == `ALUOP_DIV || aluop_i == `ALUOP_DIVU) ? !div_done : 0;
    
    
    assign hilo_data_forward = get_hilo_data_forward(hilo_data_i, hilo_read_addr_i,
                                                     bypass_mem_hi_write_enable_i, bypass_mem_hi_write_data_i,
                                                     bypass_mem_lo_write_enable_i, bypass_mem_lo_write_data_i,
                                                     bypass_wb_hi_write_enable_i, bypass_wb_hi_write_data_i,
                                                     bypass_wb_lo_write_enable_i, bypass_wb_lo_write_data_i);
    
function [31:0] get_hilo_data_forward(input [31:0] hilo_data, input hilo_read_addr, input bypass_mem_hi_write_enable,
                                      input [31:0] bypass_mem_hi_write_data, input bypass_mem_lo_write_enable,
                                      input [31:0] bypass_mem_lo_write_data, input bypass_wb_hi_write_enable,
                                      input [31:0] bypass_wb_hi_write_data, input bypass_wb_lo_write_enable,
                                      input [31:0] bypass_wb_lo_write_data);
    begin
        get_hilo_data_forward = hilo_data;
        
        if (hilo_read_addr == 0) begin //  read lo reg
            if (bypass_wb_lo_write_enable) get_hilo_data_forward = bypass_wb_lo_write_data;
            if (bypass_mem_lo_write_enable) get_hilo_data_forward = bypass_mem_lo_write_data;
        end else begin // read hi reg
            if (bypass_wb_hi_write_enable) get_hilo_data_forward = bypass_wb_hi_write_data;
            if (bypass_mem_hi_write_enable) get_hilo_data_forward = bypass_mem_hi_write_data;
        end
    end
endfunction

    assign cp0_data_forward = get_cp0_data_forward(cp0_data_i, cp0_read_addr_i,
                                                   bypass_mem_cp0_write_enable_i, bypass_mem_cp0_write_addr_i, bypass_mem_cp0_write_data_i);

function [31:0] get_cp0_data_forward(input [31:0] cp0_data, input [`CP0_ADDR_BUS] cp0_read_addr,
                                     input bypass_mem_cp0_write_enable, input [`CP0_ADDR_BUS] bypass_mem_cp0_write_addr, input [31:0] bypass_mem_cp0_write_data);
    begin
        get_cp0_data_forward = cp0_data;
        
        if (bypass_mem_cp0_write_enable == 1 && bypass_mem_cp0_write_addr == cp0_read_addr)
            get_cp0_data_forward = bypass_mem_cp0_write_data;
    end
endfunction

    
    assign pc_o                 = rst == `RST_ENABLE ? `ZEROWORD32 : pc_i;
    assign aluop_o              = rst == `RST_ENABLE ? 8'h00 : aluop_i;
    assign now_in_delayslot_o   = rst == `RST_ENABLE ? 1'b0 : now_in_delayslot_i;
    assign regfile_write_enable_o = rst == `RST_ENABLE ? 1'b0 : regfile_write_enable_i;
    assign ram_write_enable_o   = rst == `RST_ENABLE ? 1'b0 : ram_write_enable_i;
    assign hi_write_enable_o    = rst == `RST_ENABLE ? 1'b0 : hi_write_enable_i;
    assign lo_write_enable_o    = rst == `RST_ENABLE ? 1'b0 : lo_write_enable_i;
    assign cp0_write_enable_o   = rst == `RST_ENABLE ? 1'b0 : cp0_write_enable_i;
    assign regfile_write_addr_o = rst == `RST_ENABLE ? 5'b00000 : get_regfile_write_addr(aluop_i, regfile_write_addr_i, rs_data_i, rt_data_i,
                                                           sign_extend_imm16_i, alu_output_data, instr_i); // get regfile write addr
    assign cp0_write_addr_o     = rst == `RST_ENABLE ? 5'b00000 : instr_i[15:11];
    assign alu_data_o           = rst == `RST_ENABLE ? `ZEROWORD32 : alu_output_data;
    assign ram_write_data_o     = rst == `RST_ENABLE ? `ZEROWORD32 : rt_data_i;
    assign hi_write_data_o      = rst == `RST_ENABLE ? `ZEROWORD32 : hilo_write_data[63:32];
    assign lo_write_data_o      = rst == `RST_ENABLE ? `ZEROWORD32 : hilo_write_data[31:0];
    assign cp0_write_data_o     = rst == `RST_ENABLE ? `ZEROWORD32 : rt_data_i;
    assign mem_to_reg_o         = rst == `RST_ENABLE ? 1'b0 : mem_to_reg_i;
    assign exe_stall_request_o  = rst == `RST_ENABLE ? 1'b0 : div_stall;
    assign is_overflow          = rst == `RST_ENABLE ? 1'b0 : get_is_overflow(aluop_i, rs_data_i, rt_data_i, sign_extend_imm16_i, alu_output_data);
    
    assign alu_output_data = get_alu_data(aluop_i, instr_i, rs_data_i, rt_data_i, sign_extend_imm16_i, zero_extend_imm16_i,
                                       load_upper_imm16_i, pc_return_addr_i, hilo_data_forward, cp0_data_forward);

function [31:0] get_alu_data(input [7:0] aluop, input [31:0] instr, input [31:0] rs_value, input [31:0] rt_value,
                             input [31:0] sign_extend_imm16, input [31:0] zero_extend_imm16, input [31:0] load_upper_imm16,
                             input [31:0] pc_return_addr, input [31:0] hilo_data_forward, input [31:0] cp0_data_forward);
    case (aluop)
        `ALUOP_ADD : begin
            get_alu_data = rs_value + rt_value;
        end
        `ALUOP_ADDI : begin
            get_alu_data = rs_value + sign_extend_imm16;
        end
        `ALUOP_ADDU : begin
            get_alu_data = rs_value + rt_value;
        end
        `ALUOP_ADDIU : begin
            get_alu_data = rs_value + sign_extend_imm16;
        end
        `ALUOP_SUB : begin
            get_alu_data = rs_value - rt_value;
        end
        `ALUOP_SUBU : begin
            get_alu_data = rs_value - rt_value;
        end
        `ALUOP_SLT : begin
            get_alu_data = $signed(rs_value) < $signed(rt_value);
        end
        `ALUOP_SLTI : begin
            get_alu_data = $signed(rs_value) < $signed(sign_extend_imm16);
        end
        `ALUOP_SLTU : begin
            get_alu_data = $unsigned(rs_value) < $unsigned(rt_value);
        end
        `ALUOP_SLTIU : begin
            get_alu_data = $unsigned(rs_value) < $unsigned(sign_extend_imm16);
        end
//        `ALUOP_DIV : begin
//        end
//        `ALUOP_DIVU : begin
//        end
//        `ALUOP_MULT : begin
//        end
//        `ALUOP_MULU : begin
//        end
        `ALUOP_AND : begin
            get_alu_data = rs_value & rt_value;
        end
        `ALUOP_ANDI : begin
            get_alu_data = rs_value & zero_extend_imm16;
        end
        `ALUOP_LUI : begin
            get_alu_data = load_upper_imm16;
        end
        `ALUOP_NOR : begin
            get_alu_data = ~(rs_value | rt_value);
        end
        `ALUOP_OR : begin
            get_alu_data = rs_value | rt_value;
        end
        `ALUOP_ORI : begin
            get_alu_data = rs_value | zero_extend_imm16;
        end
        `ALUOP_XOR : begin
            get_alu_data = rs_value ^ rt_value;
        end
        `ALUOP_XORI : begin
            get_alu_data = rs_value ^ zero_extend_imm16;
        end
        `ALUOP_SLL : begin
            get_alu_data = rt_value << instr[10:6];
        end
        `ALUOP_SLLV : begin
            get_alu_data = rt_value << rs_value[4:0];
        end
        `ALUOP_SRA : begin
            get_alu_data = $signed(rt_value) >>> instr[10:6];
        end
        `ALUOP_SRAV : begin
            get_alu_data = $signed(rt_value) >>> rs_value[4:0];
        end
        `ALUOP_SRL : begin
            get_alu_data = rt_value >> instr[10:6];
        end
        `ALUOP_SRLV : begin
            get_alu_data = rt_value >> rs_value[4:0];
        end
        `ALUOP_BGEZAL : begin
            get_alu_data = pc_return_addr;
        end
        `ALUOP_BLTZAL : begin
            get_alu_data = pc_return_addr;
        end
//        `ALUOP_J : begin
//        end
        `ALUOP_JAL : begin
            get_alu_data = pc_return_addr;
        end
//        `ALUOP_JR : begin
//        end
        `ALUOP_JALR : begin
            get_alu_data = pc_return_addr;
        end
        `ALUOP_MFHI : begin
            get_alu_data = hilo_data_forward;
        end
        `ALUOP_MFLO : begin
            get_alu_data = hilo_data_forward;
        end
//        `ALUOP_MTHI : begin
//        end
//        `ALUOP_MTLO : begin
//        end
//        `ALUOP_BREAK : begin
//        end
//        `ALUOP_SYSCALL : begin
//        end
        `ALUOP_LB, `ALUOP_LBU, `ALUOP_LH, `ALUOP_LHU, `ALUOP_LW, `ALUOP_LWL, `ALUOP_LWR : begin
            get_alu_data = rs_value + sign_extend_imm16;
        end
        `ALUOP_SB, `ALUOP_SH, `ALUOP_SW, `ALUOP_SWL, `ALUOP_SWR : begin
            get_alu_data = rs_value + sign_extend_imm16;
        end
//        `ALUOP_ERET : begin
//        end
        `ALUOP_MFC0 : begin
            get_alu_data = cp0_data_forward;
        end
//        `ALUOP_MTC0 : begin
//        end
        `ALUOP_MOVN : begin
            get_alu_data = rs_value;
        end
        `ALUOP_MOVZ : begin
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

function get_is_overflow(input [7:0] aluop, input [31:0] rs_value, input [31:0] rt_value, 
                         input [31:0] sign_extend_imm16, input [31:0] alu_output_data);
    begin
        get_is_overflow = 0;
        
        if (aluop == `ALUOP_ADD) begin
            if ((rs_value[31] == 0 && rt_value[31] == 0 && alu_output_data[31] == 1) 
	    		|| (rs_value[31] == 1 && rt_value[31] == 1 && alu_output_data[31] == 0)) begin
	            get_is_overflow = 1;
	        end
        end
        else if (aluop == `ALUOP_ADDI) begin
            if ((rs_value[31] == 0 && sign_extend_imm16[31] == 0 && alu_output_data[31] == 1) 
	    		|| (rs_value[31] == 1 && sign_extend_imm16[31] == 1 && alu_output_data[31] == 0)) begin
	            get_is_overflow = 1;
	        end
        end
        else if (aluop == `ALUOP_SUB) begin
            if ((rs_value[31] == 0 && rt_value[31] == 1 && alu_output_data[31] == 1)
                || rs_value[31] == 1 && rt_value[31] == 0 && alu_output_data[31] == 0) begin
                get_is_overflow = 1;
            end
        end else get_is_overflow = 0;
    end
endfunction

function [4:0] get_regfile_write_addr(input [7:0] aluop, input [`GPR_ADDR_BUS] regfile_write_addr, input [31:0] rs_value,
                                      input [31:0] rt_value, input [31:0] sign_extend_imm16, input [31:0] alu_output_data,
                                      input [31:0] instr);
    begin
        get_regfile_write_addr = regfile_write_addr;
        
        if (aluop == `ALUOP_ADD) begin
            if ((rs_value[31] == 0 && rt_value[31] == 0 && alu_output_data[31] == 1) 
				|| (rs_value[31] == 1 && rt_value[31] == 1 && alu_output_data[31] == 0)) begin
	            get_regfile_write_addr = 0;
		    end
        end
        else if (aluop == `ALUOP_ADDI) begin
            if ((rs_value[31] == 0 && sign_extend_imm16[31] == 0 && alu_output_data[31] == 1) 
				|| (rs_value[31] == 1 && sign_extend_imm16[31] == 1 && alu_output_data[31] == 0)) begin
	            get_regfile_write_addr = 0;
		    end
        end
        else if (aluop == `ALUOP_SUB) begin
            if ((rs_value[31] == 0 && rt_value[31] == 1 && alu_output_data[31] == 1)
                || rs_value[31] == 1 && rt_value[31] == 0 && alu_output_data[31] == 0) begin
                get_regfile_write_addr = 0;
            end
        end
        else if (aluop == `ALUOP_JAL || aluop == `ALUOP_BLTZAL || aluop == `ALUOP_BGEZAL) begin
            get_regfile_write_addr = 5'b11111;
        end
        else if (aluop == `ALUOP_MFC0) begin
            get_regfile_write_addr = instr[20:16];
        end 
        else if (aluop == `ALUOP_MOVN) begin
            get_regfile_write_addr = rt_value == 32'b0 ? 0 : regfile_write_addr;
        end
        else if (aluop == `ALUOP_MOVZ) begin
            get_regfile_write_addr = rt_value == 32'b0 ? regfile_write_addr : 0;
        end
        else get_regfile_write_addr = regfile_write_addr;
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
    
    assign is_trap = get_is_trap(aluop_i, rs_data_i, rt_data_i, sign_extend_imm16_i);
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

endmodule
