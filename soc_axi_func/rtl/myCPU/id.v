`include "defines.v"
module id
(
input  wire                   rst,
input  wire [`INST_BUS]       pc_i,          
input  wire [`INST_BUS]       instr_i,
input  wire [`GPR_BUS]        rs_data_i,
input  wire [`GPR_BUS]        rt_data_i,
input  wire                   bypass_ex_regfile_write_enable_i,
input  wire [`GPR_ADDR_BUS]   bypass_ex_regfile_write_addr_i,
input  wire [`GPR_BUS]        bypass_ex_regfile_write_data_i,
input  wire                   bypass_mem_regfile_write_enable_i,
input  wire [`GPR_ADDR_BUS]   bypass_mem_regfile_write_addr_i,
input  wire [`GPR_BUS]        bypass_mem_regfile_write_data_i,
input  wire [`GPR_ADDR_BUS]   exe_regfile_write_addr_i,
input  wire                   now_in_delayslot_i,
input  wire                   exe_mem_to_reg_i,
input  wire [`EXCEP_TYPE_BUS] exception_type_i,

output reg  [`INST_BUS]       pc_o,
output reg  [`INST_BUS]       instr_o,
output reg  [`GPR_BUS]        rs_data_o,
output reg  [`GPR_BUS]        rt_data_o,
output reg  [`ALUOP_BUS]      aluop_o,              
output reg  [`GPR_ADDR_BUS]   regfile_write_addr_o,
output reg                    now_in_delayslot_o,  
output reg                    next_in_delayslot_o,     
output wire                   id_stall_request_o,     
output reg                    regfile_write_enable_o,                
output reg                    ram_write_enable_o,
output reg                    hi_write_enable_o,
output reg                    lo_write_enable_o,
output reg                    cp0_write_enable_o,
output reg                    mem_to_reg_o,
output reg  [`INST_BUS]       pc_return_addr_o,  
output reg  [`CP0_ADDR_BUS]   cp0_read_addr_o,   
output reg                    hilo_read_addr_o,
output wire [15:0]            imm16_o,
output reg                    branch_enable_o,
output reg  [`INST_BUS]       branch_addr_o,
output wire [`EXCEP_TYPE_BUS] exception_type_o
);

reg instr_valid;

reg is_break;
reg is_syscall;
reg is_eret;

reg rs_read_enable;
reg rt_read_enable;
reg rs_stall_request;
reg rt_stall_request;

wire [5:0]op = instr_i[31:26];
wire [4:0]rs = instr_i[25:21];
wire [4:0]rt = instr_i[20:16];
wire [4:0]rd = instr_i[15:11];
wire [4:0]shamt = instr_i[10:6];
wire [5:0]funct = instr_i[5:0];
wire [15:0]offset = instr_i[15:0];


wire [31:0] pc_add4;
wire [31:0] pc_add8;
wire [31:0] signed_extend_sll2 ={{14{instr_i[15]}},instr_i[15:0],2'b00};
wire [31:0] signed_extend = {{16{instr_i[15]}},instr_i[15:0]};

assign pc_add4 = pc_i + 32'h4;
assign pc_add8 = pc_i + 32'h8;
assign imm16_o = instr_i[15:0];

assign id_stall_request_o = rs_stall_request | rt_stall_request;



assign exception_type_o = {exception_type_i[31],~instr_valid,exception_type_i[29],is_break,is_syscall,exception_type_i[26:1],is_eret};
// load relevant
always @ (*)
begin
	rs_stall_request <= 1'b0;
	rt_stall_request <= 1'b0;
	if(rst == `RST_ENABLE)
		;
	else if(exe_mem_to_reg_i == 1'b1 && rs_read_enable == 1'b1 && exe_regfile_write_addr_i == rs)
		rs_stall_request <= 1'b1;
	else if(exe_mem_to_reg_i == 1'b1 && rt_read_enable == 1'b1 && exe_regfile_write_addr_i == rt)
		rt_stall_request <= 1'b1;
end

//handle bypass
always @ (*)
begin
    if(rst == `RST_ENABLE)
        rs_data_o <= 32'h0;
    else if(rs_read_enable == 1'b1 && bypass_ex_regfile_write_addr_i == rs 
    && bypass_ex_regfile_write_enable_i == 1'b1) 
        rs_data_o <= bypass_ex_regfile_write_data_i;
	else if(rs_read_enable == 1'b1 && bypass_mem_regfile_write_addr_i == rs
	&& bypass_mem_regfile_write_enable_i == 1'b1)
		rs_data_o <= bypass_mem_regfile_write_data_i;
	else if(rs_read_enable == 1'b1)
		rs_data_o <= rs_data_i;
	else rs_data_o <= 32'h0;
    
end

always @ (*)
begin
    if(rst == `RST_ENABLE)
        rt_data_o <= 32'h0;
    else if(rt_read_enable == 1'b1 && bypass_ex_regfile_write_addr_i == rt 
    && bypass_ex_regfile_write_enable_i == 1'b1) 
        rt_data_o <= bypass_ex_regfile_write_data_i;
	else if(rt_read_enable == 1'b1 && bypass_mem_regfile_write_addr_i == rt
	&& bypass_mem_regfile_write_enable_i == 1'b1)
		rt_data_o <= bypass_mem_regfile_write_data_i;
	else if(rt_read_enable == 1'b1)
		rt_data_o <= rt_data_i;
	else rt_data_o <= 32'h0;
end

always @ (*)
begin
    if(rst == `RST_ENABLE)
    begin
        pc_o <= `ZEROWORD32;
		instr_o <= `ZEROWORD32;
        aluop_o <= 8'h0;   
        rs_read_enable <= 1'b0;
        rt_read_enable <= 1'b0;
        regfile_write_addr_o <= 5'h0;
        now_in_delayslot_o <= 1'b0;
		next_in_delayslot_o <= 1'b0;
		regfile_write_enable_o <= 1'b0;
		ram_write_enable_o <= 1'b0;
		hi_write_enable_o <= 1'b0;
		lo_write_enable_o <= 1'b0;
        cp0_write_enable_o <= 1'b0;
		mem_to_reg_o <= 1'b0;
		pc_return_addr_o <= `ZEROWORD32;
		cp0_read_addr_o <= 5'b00000;
		hilo_read_addr_o <= 1'b0;
		branch_enable_o <= 1'b0;
        branch_addr_o <= `ZEROWORD32;
        instr_valid <= 1'b0;
        is_eret<= 1'b0;
        is_syscall <= 1'b0;
        is_break <= 1'b0;
    end else begin
        pc_o <= pc_i;
		instr_o <= instr_i;
		aluop_o <= 8'b00000000;
        regfile_write_addr_o <= rd;
		regfile_write_enable_o <= 1'b0; 
		now_in_delayslot_o <= now_in_delayslot_i;
		next_in_delayslot_o <= 1'b0;
        branch_enable_o <= 1'h0;
        branch_addr_o <= `ZEROWORD32;
		pc_return_addr_o <= `ZEROWORD32;
		ram_write_enable_o <= 1'b0;
        hi_write_enable_o <= 1'b0;
        lo_write_enable_o <= 1'b0;
        cp0_write_enable_o <= 1'b0;
		mem_to_reg_o <= 1'b0;		
        rs_read_enable <= 1'b0;          
        rt_read_enable <= 1'b0; 
		instr_valid <= 1'b0;
		cp0_read_addr_o <= rd;
		hilo_read_addr_o <= 1'b0;
		is_eret <= 1'b0;
        is_syscall <= 1'b0;
        is_break <= 1'b0;
        case(op)
		6'b000000: begin  
				case(funct)
				`ID_AND: begin
					regfile_write_enable_o <= 1'b1;
					aluop_o <= `ALUOP_AND;
					rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
					instr_valid <= 1'b1;
				end
				`ID_OR: begin
					regfile_write_enable_o <= 1'b1;
					aluop_o <= `ALUOP_OR;
					rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
					instr_valid <= 1'b1;
				end
				`ID_XOR: begin
					regfile_write_enable_o <= 1'b1;
					aluop_o <= `ALUOP_XOR;
					rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
					instr_valid <= 1'b1;
				end
				`ID_NOR: begin
					regfile_write_enable_o <= 1'b1;
					aluop_o <= `ALUOP_NOR;
					rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
					instr_valid <= 1'b1;
				end
				`ID_ADD: begin
				    regfile_write_enable_o <= 1'b1;
					aluop_o <= `ALUOP_ADD;
					rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
					instr_valid <= 1'b1;
				end
				`ID_ADDU: begin
					regfile_write_enable_o <= 1'b1;
					aluop_o <= `ALUOP_ADDU;
					rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
					instr_valid <= 1'b1;
				end
				`ID_SUB:begin
				    regfile_write_enable_o <= 1'b1;
					aluop_o <= `ALUOP_SUB;
					rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
					instr_valid <= 1'b1;
				end
				`ID_SUBU: begin
					regfile_write_enable_o <= 1'b1;
					aluop_o <= `ALUOP_SUBU;
					rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
					instr_valid <= 1'b1;
				end
				`ID_SLT: begin
					regfile_write_enable_o <= 1'b1;
					aluop_o <= `ALUOP_SLT;
					rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
					instr_valid <= 1'b1;
				end
				`ID_SLTU: begin
					regfile_write_enable_o <= 1'b1;
					aluop_o <= `ALUOP_SLTU;
					rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
					instr_valid <= 1'b1;
				end
				`ID_MULT: begin    
                    aluop_o <= `ALUOP_MULT;
                    instr_valid <= 1'b1;
                    rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
                    hi_write_enable_o <= 1'b1; lo_write_enable_o <= 1'b1;
                 end
                `ID_MULTU: begin    
                    aluop_o <= `ALUOP_MULTU;
                    instr_valid <= 1'b1;
                    rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
                    hi_write_enable_o <= 1'b1; lo_write_enable_o <= 1'b1;
                 end
                `ID_DIV: begin    
                    aluop_o <= `ALUOP_DIV;
                    instr_valid <= 1'b1;
                    rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
                    hi_write_enable_o <= 1'b1; lo_write_enable_o <= 1'b1;
                 end
                `ID_DIVU: begin    
                    aluop_o <= `ALUOP_DIVU;
                    instr_valid <= 1'b1;
                    rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
                    hi_write_enable_o <= 1'b1; lo_write_enable_o <= 1'b1;
                 end
				`ID_SLLV: begin
					regfile_write_enable_o <= 1'b1;
					aluop_o <= `ALUOP_SLLV;
					rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
					instr_valid <= 1'b1;
				end
				`ID_SRLV: begin
					regfile_write_enable_o <= 1'b1;
					aluop_o <= `ALUOP_SRLV;
					rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
					instr_valid <= 1'b1;
				end
				`ID_SRAV: begin
					regfile_write_enable_o <= 1'b1;
					aluop_o <= `ALUOP_SRAV;
					rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
					instr_valid <= 1'b1;
				end
				`ID_MFHI: begin
					if(rs == 5'h0 && rt == 5'h0) begin
						instr_valid <= 1'b1;
						aluop_o <= `ALUOP_MFHI;
						regfile_write_enable_o <= 1'b1; //high
						hilo_read_addr_o <= 1'b1;
						instr_valid <= 1'b1;
					end
				end
				`ID_MFLO: begin
					if(rs == 5'h0 && rt == 5'h0) begin
						instr_valid <= 1'b1;
						aluop_o <= `ALUOP_MFLO;
						regfile_write_enable_o <= 1'b1;
						instr_valid <= 1'b1;
					end
				end
				`ID_MTHI:begin
					if(rt == 5'h0 && rd == 5'h0) begin
						aluop_o <= `ALUOP_MTHI;
						hi_write_enable_o <= 1'b1;
						instr_valid <= 1'b1;
						rs_read_enable <= 1'b1;
					end
				end
				`ID_MTLO:begin;
					if(rt == 5'h0 && rd == 5'h0) begin
						aluop_o <= `ALUOP_MTLO;
						lo_write_enable_o <= 1'b1;
						instr_valid <= 1'b1;
						rs_read_enable <= 1'b1;
					end
				end
				`ID_JR: begin
					if(rt == 5'h0 && rd == 5'h0) begin
						aluop_o <= `ALUOP_JR;
						rs_read_enable <= 1'b1;
						branch_addr_o <= rs_data_o;
						branch_enable_o <= 1'b1;
						next_in_delayslot_o <= 1'b1;
						instr_valid <= 1'b1;
					end
				end
				`ID_JALR: begin
					if(rt == 5'h0) begin
						aluop_o <= `ALUOP_JALR;
						regfile_write_enable_o <= 1'b1;
						rs_read_enable <= 1'b1;
						pc_return_addr_o <= pc_add8;
						branch_addr_o <= rs_data_o;
						branch_enable_o <= 1'b1;
						instr_valid <= 1'b1;
						next_in_delayslot_o <= 1'b1;
						regfile_write_enable_o <= 1'b1;
					end
				end
			    `ID_SYSCALL: begin
				    aluop_o <= `ALUOP_SYSCALL;
				    instr_valid <= 1'b1;
                    is_syscall <= 1'b1;
                end
                `ID_BREAK: begin
				    aluop_o <= `ALUOP_BREAK;
				    instr_valid <= 1'b1;
                    is_break <= 1'b1;
                end
                default:;
				endcase 
		end
		6'b000001: begin//bgez bltz bgezal bltzal
			case(rt)
			`ID_BGEZ: begin
				rs_read_enable <= 1'b1;
				instr_valid <= 1'b1;
				aluop_o <= `ALUOP_BGEZ;
				next_in_delayslot_o <= 1'b1;
				if(rs_data_o[31] == 1'b0) begin
					branch_addr_o <=  pc_add4 + signed_extend_sll2;
					branch_enable_o <= 1'b1;
				end
			end
			`ID_BLTZ: begin
				rs_read_enable <= 1'b1;
				instr_valid <= 1'b1;
				aluop_o <= `ALUOP_BLTZ;
				next_in_delayslot_o <= 1'b1;
				if(rs_data_o[31] == 1'b1) begin
					branch_addr_o <=  pc_add4 + signed_extend_sll2;
					branch_enable_o <= 1'b1;
				end
			end
			`ID_BGEZAL: begin
			    rs_read_enable <= 1'b1;
				instr_valid <= 1'b1;
				aluop_o <= `ALUOP_BGEZAL;
				regfile_write_enable_o <= 1'b1;
				pc_return_addr_o <= pc_add8;
				next_in_delayslot_o <= 1'b1;
				if(rs_data_o[31] == 1'b0) begin
					branch_addr_o <=  pc_add4 + signed_extend_sll2;
					branch_enable_o <= 1'b1;
				end
			end
			`ID_BLTZAL: begin
			    rs_read_enable <= 1'b1;
				instr_valid <= 1'b1;
				aluop_o <= `ALUOP_BLTZAL;
				regfile_write_enable_o <= 1'b1;
				pc_return_addr_o <= pc_add8;
				next_in_delayslot_o <= 1'b1;
				if(rs_data_o[31] == 1'b1) begin
					branch_addr_o <=  pc_add4 + signed_extend_sll2;
					branch_enable_o <= 1'b1;
				end
			end  
			default:;
			endcase
		end
        `ID_ANDI: begin
            regfile_write_enable_o <= 1'b1;
            aluop_o <= `ALUOP_ANDI;
            rs_read_enable <= 1'b1;
            regfile_write_addr_o <= rt;
            instr_valid <= 1'b1;
        end
        `ID_LUI: begin
            regfile_write_enable_o <= 1'b1;
            aluop_o <= `ALUOP_LUI;
            rs_read_enable <= 1'b1;
            regfile_write_addr_o <= rt;
            instr_valid <= 1'b1;
        end
        `ID_ORI: begin
            regfile_write_enable_o <= 1'b1;
            aluop_o <= `ALUOP_ORI;
            rs_read_enable <= 1'b1;
            regfile_write_addr_o <= rt;
            instr_valid <= 1'b1;
        end
        `ID_XORI: begin
            regfile_write_enable_o <= 1'b1;
            aluop_o <= `ALUOP_XORI;
            rs_read_enable <= 1'b1;
            regfile_write_addr_o <= rt;
            instr_valid <= 1'b1;
        end
        `ID_ADDI: begin
            regfile_write_enable_o <= 1'b1;
            aluop_o <= `ALUOP_ADDI;
            rs_read_enable <= 1'b1;
            regfile_write_addr_o <= rt;
            instr_valid <= 1'b1;
        end
        `ID_ADDIU: begin
            regfile_write_enable_o <= 1'b1;
            aluop_o <= `ALUOP_ADDIU;
            rs_read_enable <= 1'b1;
            regfile_write_addr_o <= rt;
            instr_valid <= 1'b1;
        end
        `ID_SLTI: begin
            regfile_write_enable_o <= 1'b1;
            aluop_o <= `ALUOP_SLTI;
            rs_read_enable <= 1'b1;
            regfile_write_addr_o <= rt;
            instr_valid <= 1'b1;
        end
        `ID_SLTIU: begin
            regfile_write_enable_o <= 1'b1;
            aluop_o <= `ALUOP_SLTIU;
            rs_read_enable <= 1'b1;
            regfile_write_addr_o <= rt;
            instr_valid <= 1'b1;
        end
		`ID_J: begin
			branch_addr_o <= {pc_add4[31:28],instr_i[25:0],2'b00};
			branch_enable_o <= 1'b1;
			aluop_o <= `ALUOP_J;
			instr_valid <= 1'b1;
			next_in_delayslot_o <= 1'b1;
		end
		`ID_JAL: begin
			aluop_o <= `ALUOP_JAL;
			pc_return_addr_o <= pc_add8;
			branch_enable_o <= 1'b1;
			branch_addr_o <= {pc_add4[31:28],instr_i[25:0],2'b00};
			instr_valid <= 1'b1;
			next_in_delayslot_o <= 1'b1;
			regfile_write_enable_o <= 1'b1;
		end
		`ID_BEQ: begin
			aluop_o <= `ALUOP_BEQ;
			rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
			instr_valid <= 1'b1;
			next_in_delayslot_o <= 1'b1;
			if(rs_data_o == rt_data_o) begin
				branch_addr_o <= pc_add4 + signed_extend_sll2;
				branch_enable_o <= 1'b1;
			end			
		end
		`ID_BNE: begin
			aluop_o <= `ALUOP_BNE;
			rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
			instr_valid <= 1'b1;
			next_in_delayslot_o <= 1'b1;
			if(rs_data_o != rt_data_o) begin
				branch_addr_o <= pc_add4 + signed_extend_sll2;
				branch_enable_o <= 1'b1;
			end			
		end
		`ID_BGTZ:begin
		    aluop_o <= `ALUOP_BGTZ;
		    rs_read_enable <= 1'b1;
		    instr_valid <= 1'b1;
		    next_in_delayslot_o <= 1'b1;
		    if(rs_data_o[31] == 1'b0 && rs_data_o != 32'h0) begin
		        branch_addr_o <= pc_add4 + signed_extend_sll2;
		        branch_enable_o <= 1'b1;
		    end
		end
		`ID_BLEZ:begin
		    aluop_o <= `ALUOP_BLEZ;
		    rs_read_enable <= 1'b1;
		    instr_valid <= 1'b1;
		    next_in_delayslot_o <= 1'b1;
		    if(rs_data_o[31] == 1'b1 || rs_data_o == 32'h0) begin
		        branch_addr_o <= pc_add4 + signed_extend_sll2;
		        branch_enable_o <= 1'b1;
		    end
		end
		`ID_LB: begin
			aluop_o <= `ALUOP_LB;
			rs_read_enable <= 1'b1;
			rt_read_enable <= 1'b1;
			instr_valid <= 1'b1;
			regfile_write_addr_o <= rt;
			regfile_write_enable_o <= 1'b1;
			mem_to_reg_o <= 1'b1;
		end
		`ID_LBU: begin
			aluop_o <= `ALUOP_LBU;
			rs_read_enable <= 1'b1;
			rt_read_enable <= 1'b1;
			instr_valid <= 1'b1;
			regfile_write_addr_o <= rt;
			regfile_write_enable_o <= 1'b1;
			mem_to_reg_o <= 1'b1;
		end
		`ID_LH: begin
			aluop_o <= `ALUOP_LH;
			rs_read_enable <= 1'b1;
			rt_read_enable <= 1'b1;
			instr_valid <= 1'b1;
			regfile_write_addr_o <= rt;
			regfile_write_enable_o <= 1'b1;
			mem_to_reg_o <= 1'b1;
		end
		`ID_LHU: begin
			aluop_o <= `ALUOP_LHU;
			rs_read_enable <= 1'b1;
			rt_read_enable <= 1'b1;
			instr_valid <= 1'b1;
			regfile_write_addr_o <= rt;
			regfile_write_enable_o <= 1'b1;
			mem_to_reg_o <= 1'b1;
		end
		`ID_LW: begin
			aluop_o <= `ALUOP_LW;
			rs_read_enable <= 1'b1;
			rt_read_enable <= 1'b1;
			instr_valid <= 1'b1;
			regfile_write_addr_o <= rt;
			regfile_write_enable_o <= 1'b1;
			mem_to_reg_o <= 1'b1;
		end
		`ID_SB: begin
			aluop_o <= `ALUOP_SB;
			instr_valid <= 1'b1;
			rt_read_enable <= 1'b1;
			rs_read_enable <= 1'b1;
			ram_write_enable_o <= 1'b1;
		end
		`ID_SH: begin
			aluop_o <= `ALUOP_SH;
			instr_valid <= 1'b1;
			rt_read_enable <= 1'b1;
			rs_read_enable <= 1'b1;
			ram_write_enable_o <= 1'b1;
		end
		`ID_SW: begin
			aluop_o <= `ALUOP_SW;
			rt_read_enable <= 1'b1;
			rs_read_enable <= 1'b1;
			instr_valid <= 1'b1;
			ram_write_enable_o <= 1'b1;
		end
		endcase
		if(instr_i[31:21] == 11'b00000000000) begin
			if(funct == `ID_SLL) begin
				aluop_o <= `ALUOP_SLL;
				regfile_write_enable_o <= 1'b1;
				rt_read_enable <= 1'b1;
				instr_valid <= 1'b1;
			end
			else if(funct == `ID_SRA) begin
				aluop_o <= `ALUOP_SRA;
				regfile_write_enable_o <= 1'b1;
				rt_read_enable <= 1'b1;
				instr_valid <= 1'b1;
			end
			else if(funct == `ID_SRL) begin
				aluop_o <= `ALUOP_SRL;
				regfile_write_enable_o <= 1'b1;
				rt_read_enable <= 1'b1;
				instr_valid <= 1'b1;
			end
		end
		if(instr_i == `ID_ERET) begin
			aluop_o <= `ALUOP_ERET;
		  	instr_valid <= 1'b1; 			
	        is_eret <= 1'b1;
        end else if(instr_i[31:21] == 11'b01000000000 && instr_i[10:3] == 8'b00000000) begin
			aluop_o <= `ALUOP_MFC0;		
			instr_valid <= 1'b1;
			rt_read_enable <= 1'b1;
			regfile_write_enable_o <= 1'b1;
        end else if(instr_i[31:21] == 11'b01000000100 && instr_i[10:3] == 8'b00000000) begin
            aluop_o <= `ALUOP_MTC0;
            instr_valid <= 1'b1;	
            rt_read_enable <= 1'b1;
            cp0_write_enable_o <= 1'b1;		
		end
    end
end
endmodule
