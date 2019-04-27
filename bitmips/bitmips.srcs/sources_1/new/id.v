`include "defines.v"

module id
(
    input wire         rst,
    input wire  [31:0] pc_i,          
    input wire  [31:0] instr_i,
    input wire  [4:0]  regfile_write_addr_i,
    input wire         regfile_write_enable_i,
    input wire  [31:0] regfile_write_data_i,          
    input wire  [4:0]  exe_regfile_write_addr_i,
    input wire         now_in_delayslot_i,
    input wire         exe_mem_to_reg_i,
                
    output reg  [31:0] pc_o,
    output reg  [31:0] rs_data_o,
    output reg  [31:0] rt_data_o,
    output reg  [31:0] instr_o,
    output reg  [7:0]  aluop_o,              
    output reg  [4:0]  regfile_write_addr_o,
    output reg         now_in_delayslot_o,  
    output reg         next_in_delayslot_o,     
    output wire [31:0] exception_type_o,
    output wire        id_stall_request_o,     
    output reg         regfile_write_enable_o,                
    output reg         ram_write_enable_o,
    output reg         hi_write_enable_o,
    output reg         lo_write_enable_o,
    output reg         cp0_write_enable_o,
    output reg         mem_to_reg_o,
    output reg  [31:0] pc_return_addr_o,   
    output reg  [31:0] hilo_data_o,
    output reg	[31:0] cp0_data_o,
    output reg  [15:0] imm16_o,
    output reg         branch_enable_o,
    output reg  [31:0] branch_addr_o
    );

reg [31:0] regfile[0:31];
reg instr_valid;
reg exception_syscall;
reg exception_eret;
reg exception_break;
reg rs_read_enable;
reg rt_read_enable;
reg rs_stall_request;
reg rt_stall_request;
reg hilo_read_addr_o;

wire op = instr_i[31:26];
wire rs = instr_i[25:21];
wire rt = instr_i[20:16];
wire rd = instr_i[15:11];
wire shamt = instr_i[10:6];
wire funct = instr_i[5:0];
wire offset = instr_i[15:0];


wire [31:0] pc_add4;
wire [31:0] pc_add8;
wire [31:0] signed_extend_sll2 ={{14{instr_i[15]}},instr_i[15:0],2'b00};


assign pc_add4 = pc_i + 32'h4;
assign pc_add8 = pc_i + 32'h8;

assign id_stall_request_o = rs_stall_request | rt_stall_request;
assign exception_type_o = {exception_syscall,exception_eret,exception_break,(~instr_valid),28'b0};
// load relevant
always @ (*)
begin
	rs_stall_request <= 1'b0;
	rt_stall_request <= 1'b0;
	if(rst == 1'b1)
		;
	else if(exe_mem_to_reg_i == 1'b1 && rs_read_enable == 1'b1 && exe_regfile_write_addr_i == rs)
		rs_stall_request <= 1'b1;
	else if(exe_mem_to_reg_i == 1'b1 && rt_read_enable == 1'b1 && exe_regfile_write_addr_i == rt)
		rt_stall_request <= 1'b1;
end

always @ (*)
begin
    if(rst == 1'b1)
    begin
        pc_o <= 32'h0;
        rs_data_o <= 32'h0;
        rt_data_o <= 32'h0;
		instr_o <= 32'h0;
        aluop_o <= 8'h0;   
        regfile_write_addr_o <= 5'h0;
        regfile_write_enable_o <= 1'b0;
        now_in_delayslot_o <= 1'b0;
		next_in_delayslot_o <= 1'b0;
		branch_enable_o <= 1'b0;
        branch_addr_o <= 32'h0;
		pc_return_addr_o <= 32'h0;
		regfile_write_enable_o <= 1'b0;
		ram_write_enable_o <= 1'b0;
		hi_write_enable_o <= 1'b0;
		lo_write_enable_o <= 1'b0;
        cp0_write_enable_o <= 1'b0;
		mem_to_reg_o <= 1'b0;
		hilo_data_o <= 32'h0;
		cp0_data_o <= 32'h0;
		imm16_o <= 16'h0;
    end else begin
        pc_o <= pc_i;
        rs_data_o <= regfile[rs];
        rt_data_o <= regfile[rt];
		instr_o <= instr_i;
		aluop_o <= 8'b00000000;
        regfile_write_addr_o <= rd;
		regfile_write_enable_o <= 1'b0; 
		now_in_delayslot_o <= now_in_delayslot_i;
        branch_enable_o <= 1'h0;
        branch_addr_o <= 32'h0;
		pc_return_addr_o <= 1'b0;
		ram_write_enable_o <= 1'b0;
        hi_write_enable_o <= 1'b0;
        lo_write_enable_o <= 1'b0;
        cp0_write_enable_o <= 1'b0;
		mem_to_reg_o <= 1'b0;		
		imm16_o <= instr_i[15:0];
        rs_read_enable <= 1'b0;          
        rt_read_enable <= 1'b0; 
		instr_valid <= 1'b0;
		case(op)
		6'b000000: begin
			if(shamt == 5'b00000) begin   
				case(funct)
				`ID_AND: begin
					regfile_write_enable_o <= 1'b1;
					aluop_o <= `ALUOP_AND;
					rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
					instr_valid <= 1'b1;
				end
				`ID_SLLV: begin
					regfile_write_enable_o <= 1'b1;
					aluop_o <= `ALUOP_SLLV;
					rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
					instr_valid <= 1'b1;
				end
				`ID_MFHI:begin
				    instr_valid <= 1'b1;
					aluop_o <= `ALUOP_MFHI;
					if(rs == 5'h0 && rt == 5'h0) begin
						regfile_write_enable_o <= 1'b1;
						hilo_read_addr_o <= 1'b1;
					end
				end
				`ID_MTHI:begin
				    aluop_o <= `ALUOP_MTHI;
					if(rt == 5'h0 && rd == 5'h0) begin
						hi_write_enable_o <= 1'b1;
						instr_valid <= 1'b1;
						rs_read_enable <= 1'b1;
					end
				end
				`ID_JR: begin
				    aluop_o <= `ALUOP_JR;
					rs_read_enable <= 1'b1;
					branch_addr_o <= rs_data_o;
					branch_enable_o <= 1'b1;
					next_in_delayslot_o <= 1'b1;
					instr_valid <= 1'b1;
				end
				default:;
				endcase 
			end
			if(funct == `ID_SYSCALL) begin
				aluop_o <= `ALUOP_SYSCALL;
				instr_valid <= 1'b1;
				exception_syscall <= 1'b1;
			end
			if(funct == `ID_BREAK) begin
				aluop_o <= `ALUOP_BREAK;
				instr_valid <= 1'b1;
				exception_break <= 1'b1;
			end
		end
		6'b000001: begin//bgez bltz bgezal bltzal
			case(rt)
			`ID_BGEZ: begin
				rs_read_enable <= 1'b1;
				instr_valid <= 1'b1;
				aluop_o <= `ALUOP_BGEZ;
				if(rs_data_o[31] == 1'b0) begin
					branch_addr_o <=  pc_add4 + signed_extend_sll2;
					branch_enable_o <= 1'b1;
					next_in_delayslot_o <= 1'b1;
				end
			end
			default:;
			endcase
		end
		`ID_J: begin
			branch_addr_o <= {pc_add4[31:28],instr_i[25:0],2'b00};
			branch_enable_o <= 1'b1;
			aluop_o <= `ALUOP_AND;
			instr_valid <= 1'b1;
			next_in_delayslot_o <= 1'b1;
		end
		`ID_JAL: begin
			aluop_o <= `ALUOP_JAL;
			pc_return_addr_o <= pc_add8;
			branch_addr_o <= {pc_add4[31:28],instr_i[25:0],2'b00};
			instr_valid <= 1'b1;
			next_in_delayslot_o <= 1'b1;
			regfile_write_enable_o <= 1'b1;
		end
		`ID_BEQ: begin
			aluop_o <= `ALUOP_BEQ;
			rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
			instr_valid <= 1'b1;
			if(rs_data_o == rt_data_o) begin
				branch_addr_o <= pc_add4 + signed_extend_sll2;
				branch_enable_o <= 1'b1;
				next_in_delayslot_o <= 1'b1;
			end			
		end
		`ID_LW: begin
			aluop_o <= `ALUOP_LW;
			rs_read_enable <= 1'b1;
			instr_valid <= 1'b1;
			regfile_write_addr_o <= rt;
			regfile_write_enable_o <= 1'b1;
			mem_to_reg_o <= 1'b1;
		end
		`ID_SW: begin
			aluop_o <= `ALUOP_SW;
			instr_valid <= 1'b1;
			ram_write_enable_o <= 1'b1;
		end
		`ID_ADDI: begin
			aluop_o <= `ALUOP_ADDI;
			instr_valid <= 1'b1;
			regfile_write_addr_o <= rt;
			regfile_write_enable_o <= 1'b1;
			rs_read_enable <= 1'b1;
		end
		`ID_SLT:begin
			aluop_o <= `ALUOP_SLT;
			instr_valid <= 1'b1;
			regfile_write_enable_o <= 1'b1;
			rs_read_enable <= 1'b1; rt_read_enable <= 1'b1;
		end
		endcase
		if(instr_i[31:21] == 11'b00000000000) begin
			if(funct == `ID_SLL) begin
				aluop_o <= `ALUOP_SLL;
				regfile_write_enable_o <= 1'b1;
				rt_read_enable <= 1'b1;
				instr_valid <= 1'b1;
			end
		end
		if(instr_i == `ID_ERET) begin
			aluop_o <= `ALUOP_ERET;
			exception_eret <= 1'b1;
			instr_valid <= 1'b1;
		end
		// mfc0 mtc0 sel??
    end
end
endmodule