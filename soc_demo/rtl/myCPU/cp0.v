`include "defines.v"
module cp0
(
input wire                   clk,
input wire                   rst,
input wire [`CP0_ADDR_BUS]   cp0_read_addr_i,
input wire                   cp0_write_enable_i,
input wire [`CP0_ADDR_BUS]   cp0_write_addr_i,
input wire [`CP0_BUS]        cp0_write_data_i,
input wire [`EXCEP_TYPE_BUS] exception_type_i,
input wire [`INST_BUS]       pc_i,    
input wire [`INST_BUS]       exception_addr_i,
input wire [5:0]             int_i,
input wire                   now_in_delayslot_i,
input wire [2:0]             cp0_write_sel,
input wire [2:0]             cp0_read_sel,
output wire [`CP0_BUS]        cp0_read_data_o,
output reg [`CP0_BUS]        cp0_return_pc_o,    
output reg                   timer_int_o,    
output reg                   flush_o,

input wire[7:0]              aluop_i,

input wire[31:0]             inst_vaddr,
output wire[31:0]            inst_paddr,
output wire                  inst_miss,
output wire                  inst_invalid,
output wire                  inst_cache,

input wire[31:0]             data_vaddr,
input wire                   data_ren,
input wire                   data_wen,
output wire[31:0]            data_paddr,
output wire                  data_miss,
output wire                  data_invalid,
output wire                  data_modified,
output wire                  data_cache
);

reg [`CP0_BUS] cp0_index; // 0
reg [`CP0_BUS] cp0_random; // 1
reg [`CP0_BUS] cp0_entrylo0; // 2
reg [`CP0_BUS] cp0_entrylo1; // 3
reg [`CP0_BUS] cp0_pagemask; // 5
reg [`CP0_BUS] cp0_entryhi; // 10
reg [`CP0_BUS] cp0_badvaddr;
reg [`CP0_BUS] cp0_count;
reg [`CP0_BUS] cp0_compare;
reg [`CP0_BUS] cp0_status;
reg [`CP0_BUS] cp0_cause;
reg [`CP0_BUS] cp0_epc;
reg [`CP0_BUS] cp0_config_0; // 16
reg [`CP0_BUS] cp0_config_1; // 16

reg is_int;
reg timer_int;
reg flush;
reg [`CP0_BUS] cp0_return_pc;
reg exception_flag;

wire[89:0] r_resp;
wire w_valid;
wire[4:0] w_index;
wire[4:0] p_index;
wire p_miss;

task is_exception_asserted(output is_exception_asserted);
begin
    is_exception_asserted = (flush == 1'b1) ? 1 : 0;
end
endtask

task de_asserted_exception;
begin
    flush = 0;
end
endtask


reg[31:0] cp0_read;
assign cp0_read_data_o = cp0_read;
always @ (*) begin
    if(cp0_write_enable_i && cp0_read_addr_i == cp0_write_addr_i) begin
        if(cp0_write_addr_i == 5'd0)
            cp0_read = {cp0_write_data_i[31], cp0_index[30:5], cp0_write_data_i[4:0]};
        else if (cp0_write_addr_i == 5'd2)
            cp0_read = {cp0_entrylo0[31:26], cp0_write_data_i[25:0]};
        else if (cp0_write_addr_i == 5'd3)
            cp0_read = {cp0_entrylo1[31:26], cp0_write_data_i[25:0]};
        else if (cp0_write_addr_i == 5'd5)
            cp0_read = {cp0_pagemask[31:25], cp0_write_data_i[24:13], cp0_pagemask[12:0]};
        else if (cp0_write_addr_i == 5'd10)
            cp0_read = {cp0_write_data_i[31:13], cp0_entryhi[12:8], cp0_write_data_i[7:0]};
        else
        if(cp0_write_addr_i == 5'd13) // cp0_cause
            cp0_read = {cp0_cause[31:10],cp0_write_data_i[9:8],cp0_cause[7:0]};
        else if(cp0_write_addr_i == 5'd12) //cp0_status
            cp0_read = {cp0_status[31:16],cp0_write_data_i[15:8],cp0_status[7:2],cp0_write_data_i[1:0]};
        else if (cp0_write_addr_i == 5'd16 && cp0_write_sel == 3'b0 && cp0_read_sel == 3'b0) // cp0_config0
            cp0_read = {cp0_config_0[31:3], cp0_write_data_i[2:0]};
        else 
            cp0_read = cp0_write_data_i;
    end
    else begin
    case(cp0_read_addr_i)
        5'd0: //index
            cp0_read = cp0_index;
        5'd1: // random
            cp0_read = cp0_random;
        5'd2: //entrylo0
            cp0_read = cp0_entrylo0;
        5'd3: //entrylo1
            cp0_read = cp0_entrylo1;
        5'd5: //pagemask
            cp0_read = cp0_pagemask;
        5'd10: //entryhi
            cp0_read = cp0_entryhi;
        5'd8: //badVaddr
            cp0_read = cp0_badvaddr;
        5'd9: //count:
            cp0_read = cp0_count;
        5'd11: //compare
            cp0_read = cp0_compare;
        5'd12: //status:
            cp0_read = cp0_status;
        5'd13: //cause:
            cp0_read = cp0_cause;
        5'd14: //epc:
            cp0_read = cp0_epc;
        5'd16: //config
        begin
            case(cp0_read_sel)
            3'd0: cp0_read = cp0_config_0;
            3'd1: cp0_read = cp0_config_1;
            default: cp0_read = 32'b0;
            endcase
        end
         default:
            cp0_read = 32'h0;
    endcase
    end
end

task cp0_write(input [`CP0_ADDR_BUS] write_addr, input [`CP0_BUS]  write_data, input [2:0] cp0_write_sel);
begin
    case(write_addr)
        5'd0: //index
        begin
//            cp0_index[31] = write_data[31];
            cp0_index[4:0] = write_data[4:0];
        end
        5'd2: //entrylo0
            cp0_entrylo0[25:0] = write_data[25:0];
        5'd3: //entrylo1
            cp0_entrylo1[25:0] = write_data[25:0];
        5'd5: //pagemask
            cp0_pagemask[24:13] = write_data[24:13];
        5'd10: //entryhi
        begin
            cp0_entryhi[31:13] = write_data[31:13];
            cp0_entryhi[7:0] = write_data[7:0];
        end
        5'd9: //count
            cp0_count = write_data;
        5'd11: //compare
            cp0_compare = write_data;
        5'd12://status
        begin
            cp0_status[15:8] = write_data[15:8];
            cp0_status[1:0] = write_data[1:0];
        end
        5'd13:
        begin
            cp0_cause[9:8] = write_data[9:8];
        end
        5'd14:
            cp0_epc = write_data;
        5'd16:
        begin
            if (cp0_write_sel == 3'b0) cp0_config_0[2:0] = write_data[2:0];
        end
        default: begin
        end
    endcase
end
endtask

task assert_exception(input [`EXCEP_CODE_BUS] exception_code, input [`INST_BUS] int_offset, input [`INST_BUS] pc);
begin
    if(cp0_status[`EXL] ==0) begin
        if(now_in_delayslot_i == 1'b1) begin
            cp0_epc = pc - 4;
            cp0_cause[`BD] = 1;
        end else begin
            cp0_epc = pc;
            cp0_cause[`BD] = 0;
        end
        flush = 1'b1;
        cp0_cause[6:2] = exception_code;
    end
    else flush = 1'b0;
    cp0_status[`EXL] = 1;
    cp0_return_pc = int_offset;
    
  
//    cp0_cause[6:2] = exception_code;
end
endtask


task assert_general_exception(input [`EXCEP_CODE_BUS] exception_code);
begin
    assert_exception(exception_code,32'hbfc0_0380,pc_i);
end
endtask

task assert_general_memory_exception(input [`EXCEP_CODE_BUS] exception_code, input [`INST_BUS] exception_addr);
begin
    assert_exception(exception_code,32'hbfc0_0380,pc_i);
    cp0_badvaddr = exception_addr;
end
endtask

task assert_exception_return(input [`EXCEP_CODE_BUS] exception_code);
begin
    cp0_status[`EXL] = 0;
    cp0_return_pc = cp0_epc;
    flush = 1'b1;
end
endtask

task update_timer;
begin
    cp0_count = cp0_count + 1;
    if(cp0_compare != `ZEROWORD32 && cp0_compare == cp0_count) begin
        timer_int = 1;
        assert_exception(`EXCEP_CODE_INT,32'h0000_0380,pc_i);
    end
    else 
        timer_int = 0;
end
endtask

task update_random();
begin
    cp0_random[4:0] = cp0_random[4:0] + 1'b1;
    cp0_random[31:5] = 27'b0;
end
endtask

task assert_exception_tlb(input [`EXCEP_CODE_BUS] exception_code, input [`INST_BUS] int_offset, input [31:0] bad_access_addr);
begin
    assert_exception(exception_code, int_offset,pc_i);
    cp0_badvaddr = bad_access_addr;
    cp0_entryhi[31:13] = bad_access_addr[31:13];
end
endtask

task handle_exception(input [`EXCEP_TYPE_BUS] exception_type);
begin
    if(exception_type[31] == 1'b1) begin  
        assert_general_memory_exception(`EXCEP_CODE_ADEL,pc_i);
    end else if(exception_type[23] == 1'b1) begin
        assert_exception_tlb(`EXCEP_CODE_TLBL, 32'hbfc0_0200, pc_i);
    end else if(exception_type[22] == 1'b1) begin
        assert_exception_tlb(`EXCEP_CODE_TLBL, 32'hbfc0_0380, pc_i);
    end else if(exception_type[30] == 1'b1) begin
        assert_general_exception(`EXCEP_CODE_RI); 
    end else if(exception_type[29] == 1'b1) begin
        assert_general_exception(`EXCEP_CODE_OV); 
    end else if(exception_type[28] == 1'b1) begin
        assert_general_exception(`EXCEP_CODE_BP);
    end else if(exception_type[27] == 1'b1) begin
        assert_general_exception(`EXCEP_CODE_SYS);
    end else if(exception_type[24] == 1'b1) begin
		assert_general_exception(`EXCEP_CODE_TR);
    end else if(exception_type[26] == 1'b1) begin
        assert_general_memory_exception(`EXCEP_CODE_ADEL,exception_addr_i);
    end else if(exception_type[25] == 1'b1) begin
        assert_general_memory_exception(`EXCEP_CODE_ADES,exception_addr_i);
	end else if(exception_type[21] == 1'b1) begin
        if(exception_type[18] == 1'b0) assert_exception_tlb(`EXCEP_CODE_TLBL, 32'hbfc0_0200, exception_addr_i);
        else assert_exception_tlb(`EXCEP_CODE_TLBS, 32'hbfc0_0200, exception_addr_i);
    end else if(exception_type[20] == 1'b1) begin
        if(exception_type[18] == 1'b0) assert_exception_tlb(`EXCEP_CODE_TLBL, 32'hbfc0_0380, exception_addr_i);
        else assert_exception_tlb(`EXCEP_CODE_TLBS, 32'hbfc0_0380, exception_addr_i);
    end else if(exception_type[19] == 1'b1) begin
        assert_exception_tlb(`EXCEP_CODE_MOD, 32'hbfc0_0380, exception_addr_i);
    end else if(exception_type[0] == 1'b1) begin
        assert_exception_return(`EXCEP_CODE_ERET);
    end
end
endtask

task handle_interrupt;
begin
    if( cp0_cause[15:10] & cp0_status[15:10]) begin
        assert_exception(`EXCEP_CODE_INT,32'hbfc0_0380,pc_i);
    end
    if( cp0_cause[9:8] & cp0_status[9:8]) begin
        assert_exception(`EXCEP_CODE_INT,32'hbfc0_0380,pc_i + 4);
    end
end
endtask

task get_interrupt;
begin
    cp0_cause[15:10] = int_i;
end
endtask

always @(posedge clk)
begin
    if(rst == `RST_ENABLE) begin
        flush <= 1'b0;
        timer_int <= 1'b0;
        exception_flag <= 1'b0;
        cp0_index <= `ZEROWORD32;
        cp0_random <= `ZEROWORD32;
        cp0_entrylo0 <= `ZEROWORD32;
        cp0_entrylo1 <= `ZEROWORD32;
        cp0_pagemask <= `ZEROWORD32;
        cp0_entryhi <= `ZEROWORD32;
        cp0_return_pc <= `ZEROWORD32;
        cp0_badvaddr <= `ZEROWORD32;
        cp0_count <= `ZEROWORD32;
        cp0_compare <= `ZEROWORD32;
        // [31:  28]
        // CU3...CU0
        // CU0 = 1 -> enable cp0 
        cp0_status <= 32'b00000000010000000000000000000000;
        cp0_cause <= `ZEROWORD32;
        cp0_epc <= `ZEROWORD32;
        cp0_config_0 <= 32'b1_000000000000000_000000_001_0000_010;
        cp0_config_1 <= 32'b0_011111_001_100_001_001_100_001_0000000;
    end else begin
        update_random();
        is_exception_asserted(exception_flag);
        if(exception_flag)
            de_asserted_exception();      
        if(cp0_write_enable_i)
            cp0_write(cp0_write_addr_i,cp0_write_data_i,cp0_write_sel);
        update_timer();
        get_interrupt();
        handle_interrupt();
        handle_exception(exception_type_i);
        
        cp0_return_pc_o <= cp0_return_pc;
        timer_int_o <= timer_int;
        flush_o <=  flush;
        do_tlb_instruction(aluop_i, r_resp, p_index, p_miss);
    end
end

task do_tlb_instruction(input [7:0] aluop, input [89:0] r_resp, input [4:0] p_index, input p_miss);
    case(aluop)
        `ALUOP_TLBP: begin
            if (p_miss) begin
                cp0_index[31] = 1'b1;
            end else begin
                cp0_index[31] = 1'b0;
            end
            cp0_index[4:0] = p_index;
        end
        `ALUOP_TLBR: begin
            cp0_entryhi[31:13] = r_resp[`VPN2];
            cp0_entryhi[7:0] = r_resp[`ASID];
            cp0_pagemask[24:13] = r_resp[`PAGEMASK];
            cp0_entrylo0[25:1] = r_resp[49:25];
            cp0_entrylo0[0] = r_resp[`G];
            cp0_entrylo1[25:1] = r_resp[24:0];
            cp0_entrylo1[0] = r_resp[`G];
        end
        `ALUOP_TLBWI: begin
        end
        `ALUOP_TLBWR: begin
        end
        default: begin
        end
    endcase
endtask

assign w_valid = (aluop_i == `ALUOP_TLBWI || aluop_i == `ALUOP_TLBWR) ? 1'b1 : 1'b0;
assign w_index = get_w_index(aluop_i, cp0_index, cp0_random);
function [4:0] get_w_index(input [7:0] aluop,input [31:0] cp0_index, input [31:0] cp0_random);
begin
    case(aluop)
        `ALUOP_TLBWI: get_w_index = cp0_index[4:0];
        `ALUOP_TLBWR: get_w_index = cp0_random[4:0];
        default: get_w_index = 5'b0;
    endcase
end
endfunction

//assign inst_paddr = {3'b000, inst_vaddr[28:0]};
//assign inst_miss = 1'b0;
//assign inst_invalid = 1'b0;
//assign inst_cache = inst_vaddr[31:29] == 3'b100 ? 1'b1 : 1'b0;
//assign data_paddr = {3'b000, data_vaddr[28:0]};
//assign data_miss = 1'b0;
//assign data_invalid = 1'b0;
//assign data_modified = 1'b0;
//assign data_cache = data_vaddr[31:29] == 3'b100 ? 1'b1 : 1'b0;
                                            
tlb tlb0(
    .clk(clk),
    .rst(rst),
    
    .r_index(cp0_index[4:0]),
    .r_resp(r_resp),
    
    .w_valid(w_valid),
    .w_index(w_index),
    .w_data({cp0_entryhi[31:13], cp0_entryhi[7:0], cp0_pagemask[24:13], cp0_entrylo0[0] & cp0_entrylo1[0], cp0_entrylo0[25:1], cp0_entrylo1[25:1]}),
    
    .p_vpn2(cp0_entryhi[31:13]),
    .p_asid(cp0_entryhi[7:0]),
    .p_index(p_index),
    .p_miss(p_miss),
    
    .qi_asid(cp0_entryhi[7:0]),
    .qi_vaddr(inst_vaddr),
    .qi_paddr(inst_paddr),
    .qi_miss(inst_miss),
    .qi_invalid(inst_invalid),
    .qi_cache(inst_cache),
    
    .qd_asid(cp0_entryhi[7:0]),
    .qd_vaddr(data_vaddr),
    .qd_ren(data_ren),
    .qd_wen(data_wen),
    .qd_paddr(data_paddr),
    .qd_miss(data_miss),
    .qd_invalid(data_invalid),
    .qd_modified(data_modified),
    .qd_cache(data_cache)
);
endmodule