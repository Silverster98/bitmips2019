`include "defines.v"

module ex(
    input   wire                    rst,
    input   wire                    clk,
    input   wire[`INST_ADDR_BUS]    pc_i,
    input   wire[`GPR_BUS]          rs_data_i,
    input   wire[`GPR_BUS]          rt_data_i,
    input   wire[`INST_BUS]         instr_i,
    input   wire[`ALUOP_BUS]        aluop_i,
    input   wire[`GPR_ADDR_BUS]     regfile_write_addr_i,
    input   wire                    now_in_delayslot_i,
    input   wire[`EXCEP_TYPE_BUS]   exception_type_i,
    input   wire                    regfile_write_enable_i,
    input   wire                    ram_write_enable_i,
    input   wire                    hi_write_enable_i,
    input   wire                    lo_write_enable_i,
    input   wire                    cp0_write_enable_i,
    input   wire[`GPR_BUS]          hilo_data_i,
    input   wire[`GPR_BUS]          cp0_data_i,
    input   wire                    mem_to_reg_i,
    input   wire[`INST_ADDR_BUS]    pc_return_addr_i,
    input   wire[`GPR_BUS]          sign_extend_imm16_i,
    input   wire[`GPR_BUS]          zero_extend_imm16_i,
    input   wire[`GPR_BUS]          load_upper_imm16_i,
    
    input   wire                    bypass_mem_hi_write_enable_i,
    input   wire[`GPR_BUS]          bypass_mem_hi_write_data_i,
    input   wire                    bypass_mem_lo_write_enable_i,
    input   wire[`GPR_BUS]          bypass_mem_lo_write_data_i,
    input   wire                    bypass_mem_cp0_write_enable_i,
    input   wire[`CP0_ADDR_BUS]     bypass_mem_cp0_write_addr_i,
    input   wire[`CP0_BUS]          bypass_mem_cp0_write_data_i,
    input   wire                    bypass_wb_hi_write_enable_i,
    input   wire[`GPR_BUS]          bypass_wb_hi_write_data_i,
    input   wire                    bypass_wb_lo_write_enable_i,
    input   wire[`GPR_BUS]          bypass_wb_lo_write_data_i,
    
    input   wire                    hilo_read_addr_i,
    input   wire[`CP0_ADDR_BUS]     cp0_read_addr_i,
    
    output  reg[`INST_ADDR_BUS]     pc_o,
    output  reg[`ALUOP_BUS]         aluop_o,
    output  reg                     now_in_delayslot_o,
    output  wire[`EXCEP_TYPE_BUS]   exception_type_o,
    output  reg                     regfile_write_enable_o,
    output  reg                     ram_write_enable_o,
    output  reg                     hi_write_enable_o,
    output  reg                     lo_write_enable_o,
    output  reg                     cp0_write_enable_o,
    output  reg[`GPR_ADDR_BUS]      regfile_write_addr_o,
    output  reg[`CP0_ADDR_BUS]      cp0_write_addr_o,
    output  reg[`GPR_BUS]           alu_data_o,
    output  reg[`GPR_BUS]           ram_write_data_o,
    output  reg[`GPR_BUS]           hi_write_data_o,
    output  reg[`GPR_BUS]           lo_write_data_o,
    output  reg[`GPR_BUS]           cp0_write_data_o,
    output  reg                     mem_to_reg_o,
    output  reg                     exe_stall_request_o
    );
    
    reg is_overflow;
    assign exception_type_o = {exception_type_i[31:30], is_overflow, exception_type_i[28:0]};
    
    wire[`GPR_BUS] alu_output_data;
    wire[`GPR_BUS] hilo_data_forward, cp0_data_forward;
    wire[63:0] mul_data, div_data, hilo_write_data;
    wire start, div_done, flag_unsigned, div_stall;
    assign start = (aluop_i == `ALUOP_DIV || aluop_i == `ALUOP_DIVU) ? 1 : 0;
    assign flag_unsigned = (aluop_i == `ALUOP_DIVU) ? 1 : 0;
    
    reg div_done_t;
    assign div_stall = (aluop_i == `ALUOP_DIV || aluop_i == `ALUOP_DIVU) ? !div_done_t : 0;
    reg [31:0] pre_pc;
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE) begin
            pre_pc = 32'b0;
            div_done_t = 1'b0;
        end else begin
            if (pre_pc != pc_i) begin
                pre_pc = pc_i;
                div_done_t = 1'b0;
            end else begin
                if (div_done == 1'b1) div_done_t = 1'b1; 
            end
        end
    end
    
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

    
    
    always @ (*) begin
        if (rst == `RST_ENABLE) begin
            pc_o <= `ZEROWORD32;
            aluop_o <= 8'h00;
            now_in_delayslot_o <= 1'b0;
            regfile_write_enable_o <= 1'b0;
            ram_write_enable_o <= 1'b0;
            hi_write_enable_o <= 1'b0;
            lo_write_enable_o <= 1'b0;
            cp0_write_enable_o <= 1'b0;
            regfile_write_addr_o <= 5'b00000;
            cp0_write_addr_o <= 5'b00000;
            alu_data_o <= `ZEROWORD32;
            ram_write_data_o <= `ZEROWORD32;
            hi_write_data_o <= `ZEROWORD32;
            lo_write_data_o <= `ZEROWORD32;
            cp0_write_data_o <= `ZEROWORD32;
            mem_to_reg_o <= 1'b0;
            exe_stall_request_o <= 1'b0;
            is_overflow <= 1'b0;
        end else begin
            pc_o <= pc_i;
            aluop_o <= aluop_i;
            now_in_delayslot_o <= now_in_delayslot_i;
            regfile_write_enable_o <= regfile_write_enable_i;
            ram_write_enable_o <= ram_write_enable_i;
            hi_write_enable_o <= hi_write_enable_i;
            lo_write_enable_o <= lo_write_enable_i;
            cp0_write_enable_o <= cp0_write_enable_i;
            regfile_write_addr_o <= get_regfile_write_addr(aluop_i, regfile_write_addr_i, rs_data_i, rt_data_i,
                                                           sign_extend_imm16_i, alu_output_data, instr_i); // get regfile write addr
            is_overflow <= get_is_overflow(aluop_i, rs_data_i, rt_data_i, sign_extend_imm16_i, alu_output_data);
            cp0_write_addr_o <= instr_i[15:11];  // MTC0:cp0 write addr is rd
            alu_data_o <= alu_output_data; // alu data output
            
            ram_write_data_o <= rt_data_i;
            
            hi_write_data_o <= hilo_write_data[63:32];
            lo_write_data_o <= hilo_write_data[31:0];
            
            cp0_write_data_o <= rt_data_i;
            mem_to_reg_o <= mem_to_reg_i;
            exe_stall_request_o <= div_stall;
        end
    end
    
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
        `ALUOP_JAL : begin
            get_alu_data = pc_return_addr;
        end
        `ALUOP_JALR : begin
            get_alu_data = pc_return_addr;
        end
        `ALUOP_MFHI : begin
            get_alu_data = hilo_data_forward;
        end
        `ALUOP_MFLO : begin
            get_alu_data = hilo_data_forward;
        end
        `ALUOP_LB : begin
            get_alu_data = rs_value + sign_extend_imm16;
        end
        `ALUOP_LBU : begin
            get_alu_data = rs_value + sign_extend_imm16;
        end
        `ALUOP_LH : begin
            get_alu_data = rs_value + sign_extend_imm16;
        end
        `ALUOP_LHU : begin
            get_alu_data = rs_value + sign_extend_imm16;
        end
        `ALUOP_LW : begin
            get_alu_data = rs_value + sign_extend_imm16;
        end
        `ALUOP_SB : begin
            get_alu_data = rs_value + sign_extend_imm16;
        end
        `ALUOP_SH : begin
            get_alu_data = rs_value + sign_extend_imm16;
        end
        `ALUOP_SW : begin
            get_alu_data = rs_value + sign_extend_imm16;
        end
        `ALUOP_MFC0 : begin
            get_alu_data = cp0_data_forward;
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
        end else get_regfile_write_addr = regfile_write_addr;
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
