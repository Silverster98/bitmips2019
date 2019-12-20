`timescale 1ns / 1ps

`include "defines.vh"

module cp0 (
    input   wire        rst,
    input   wire        clk,
    
    input   wire[4:0]   cp0_read_addr,
    input   wire[2:0]   cp0_read_sel,
    output  wire[31:0]  cp0_read_data,
    input   wire[4:0]   cp0_write_addr,
    input   wire[2:0]   cp0_write_sel,
    input   wire[31:0]  cp0_write_data,
    input   wire        cp0_write_enable,
    
    input   wire[7:0]   aluop,
    
    input   wire[5:0]   int_i,
    input   wire[31:0]  pc,
    input   wire[31:0]  mem_bad_vaddr,
    input   wire[31:0]  exception_type,
    input   wire        in_delayslot,
    output  wire[31:0]  return_pc,
    output  wire        exception,
    
    input   wire[31:0]  inst_vaddr,
    output  wire[31:0]  inst_paddr,
    output  wire        inst_miss,
    output  wire        inst_invalid,
    output  wire        inst_cache,
    
    input   wire[31:0]  data_vaddr,
    input   wire        data_ren,
    input   wire        data_wen,
    output  wire[31:0]  data_paddr,
    output  wire        data_miss,
    output  wire        data_invalid,
    output  wire        data_modified,
    output  wire        data_cache
    );
    
    reg[31:0] cp0_index;    // 0
    reg[31:0] cp0_random;   // 1
    reg[31:0] cp0_entrylo0; // 2
    reg[31:0] cp0_entrylo1; // 3
    reg[31:0] cp0_pagemask; // 5
    reg[31:0] cp0_badvaddr; // 8
    reg[31:0] cp0_count;    // 9
    reg[31:0] cp0_entryhi;  // 10
    reg[31:0] cp0_compare;  // 11
    reg[31:0] cp0_status;   // 12
    reg[31:0] cp0_cause;    // 13
    reg[31:0] cp0_epc;      // 14
    reg[31:0] cp0_prid;     // 15
    reg[31:0] cp0_config0;  // 16, 0
    reg[31:0] cp0_config1;  // 16, 1
    
    reg[31:0] pc_r;
    reg in_delayslot_r;
    always @ (posedge clk) begin
        pc_r <= pc;
        in_delayslot_r <= in_delayslot;
    end
    
    wire[89:0] r_resp;
    wire w_valid;
    wire[4:0] w_index;
    wire[4:0] p_index;
    wire p_miss;
    
    // exception handle
    wire[5:0] interrupt;
    wire timer_int;
//    reg timer_int_r;
    assign timer_int = (cp0_compare != 32'b0 && cp0_count == cp0_compare) ? 1'b1 : 1'b0;
    assign interrupt = {timer_int | int_i[5], int_i[4:0]};
//    always @ (posedge clk) begin
//        timer_int_r <= timer_int;
//    end
    wire int_sig;
    assign int_sig = cp0_cause[15:8] & cp0_status[15:8] && !cp0_status[1] && cp0_status[0];
    wire[31:0] exception_type_final;
    assign exception_type_final = {int_sig, exception_type[30:0]};
    wire commit_exception, commit_bd, commit_eret;
    assign exception = commit_exception || commit_eret;
    assign commit_exception = |exception_type_final[31:2] && !cp0_status[1];
    assign commit_bd = (int_sig) ? in_delayslot_r : in_delayslot;
    assign commit_eret = (exception_type_final == 31'b1) ? 1'b1 : 1'b0;
    
    wire[31:0] commit_epc;
    assign commit_epc = (int_sig) ? ((in_delayslot_r == 1'b1) ? pc_r - 4  : pc_r + 4) : 
                        (in_delayslot == 1'b1) ? pc - 4 : pc;
    
    reg exception_tlb;
    reg[31:0] commit_bvaddr;
    reg[4:0] commit_code;
    reg[31:0] return_pc_r;
    assign return_pc = return_pc_r;
    always @ (*) begin
        if (exception_type_final[31] == 1'b1) begin
            commit_code <= `EXCEP_CODE_INT;
            return_pc_r <= 32'hbfc00380;
            exception_tlb <= 1'b0;
            commit_bvaddr <= 32'b0;
        end else if (exception_type_final[30] == 1'b1) begin
            commit_code <= `EXCEP_CODE_ADEL;
            return_pc_r <= 32'hbfc00380;
            exception_tlb <= 1'b0;
            commit_bvaddr <= pc;
        end else if (exception_type_final[29] == 1'b1) begin
            commit_code <= `EXCEP_CODE_TLBL;
            return_pc_r <= 32'hbfc00200;
            exception_tlb <= 1'b1;
            commit_bvaddr <= pc;
        end else if (exception_type_final[28] == 1'b1) begin
            commit_code <= `EXCEP_CODE_TLBL;
            return_pc_r <= 32'hbfc00380;
            exception_tlb <= 1'b1;
            commit_bvaddr <= pc;
        end else if (exception_type_final[27] == 1'b1) begin
            commit_code <= `EXCEP_CODE_RI;
            return_pc_r <= 32'hbfc00380;
            exception_tlb <= 1'b0;
            commit_bvaddr <= 32'b0;
        end else if (exception_type_final[26] == 1'b1) begin
            commit_code <= `EXCEP_CODE_OV;
            return_pc_r <= 32'hbfc00380;
            exception_tlb <= 1'b0;
            commit_bvaddr <= 32'b0;
        end else if (exception_type_final[25] == 1'b1) begin
            commit_code <= `EXCEP_CODE_TR;
            return_pc_r <= 32'hbfc00380;
            exception_tlb <= 1'b0;
            commit_bvaddr <= 32'b0;
        end else if (exception_type_final[24] == 1'b1) begin
            commit_code <= `EXCEP_CODE_SYS;
            return_pc_r <= 32'hbfc00380;
            exception_tlb <= 1'b0;
            commit_bvaddr <= 32'b0;
        end else if (exception_type_final[23] == 1'b1) begin
            commit_code <= `EXCEP_CODE_BP;
            return_pc_r <= 32'hbfc00380;
            exception_tlb <= 1'b0;
            commit_bvaddr <= 32'b0;
        end else if (exception_type_final[22] == 1'b1) begin
            if (exception_type_final[1] == 1'b0) begin
                commit_code <= `EXCEP_CODE_ADEL;
            end else begin
                commit_code <= `EXCEP_CODE_ADES;
            end
            return_pc_r <= 32'hbfc00380;
            exception_tlb <= 1'b0;
            commit_bvaddr <= mem_bad_vaddr;
        end else if (exception_type_final[21] == 1'b1) begin
            if (exception_type_final[1] == 1'b0) begin
                commit_code <= `EXCEP_CODE_TLBL;
            end else begin
                commit_code <= `EXCEP_CODE_TLBS;
            end
            return_pc_r <= 32'hbfc00200;
            exception_tlb <= 1'b1;
            commit_bvaddr <= mem_bad_vaddr;
        end else if (exception_type_final[20] == 1'b1) begin
            if (exception_type_final[1] == 1'b0) begin
                commit_code <= `EXCEP_CODE_TLBL;
            end else begin
                commit_code <= `EXCEP_CODE_TLBS;
            end
            return_pc_r <= 32'hbfc00380;
            exception_tlb <= 1'b1;
            commit_bvaddr <= mem_bad_vaddr;
        end else if (exception_type_final[19] == 1'b1) begin
            commit_code <= `EXCEP_CODE_MOD;
            return_pc_r <= 32'hbfc00380;
            exception_tlb <= 1'b1;
            commit_bvaddr <= mem_bad_vaddr;
        end else if (exception_type_final[0] == 1'b1) begin
            commit_code <= `EXCEP_CODE_ERET;
            return_pc_r <= cp0_epc;
            exception_tlb <= 1'b0;
            commit_bvaddr <= 32'b0;
        end else begin
            commit_code <= 5'h0;
            return_pc_r <= 32'h0;
            exception_tlb <= 1'b0;
            commit_bvaddr <= 32'b0;
        end
    end
    
    // read
    reg[31:0] cp0_read_data_r;
    wire[7:0] read_addr_sel;
    wire[7:0] write_addr_sel;
    assign read_addr_sel = {cp0_read_addr, cp0_read_sel};
    assign write_addr_sel = {cp0_write_addr, cp0_write_sel};
    assign cp0_read_data = cp0_read_data_r;
    
    always @ (*) begin
        case(read_addr_sel)
        {5'b00000, 3'b000}: begin
            if (cp0_write_enable && write_addr_sel == read_addr_sel) cp0_read_data_r = {cp0_index[31:5], cp0_write_data[4:0]};
            else if (aluop == `ALUOP_TLBP) cp0_read_data_r = {p_miss, cp0_index[30:5], p_index};
            else cp0_read_data_r = cp0_index;
        end
        {5'b00001, 3'b000}: begin
            cp0_read_data_r = cp0_random;
        end
        {5'b00010, 3'b000}: begin
            if (cp0_write_enable && write_addr_sel == read_addr_sel) cp0_read_data_r = {cp0_entrylo0[31:26], cp0_write_data[25:0]};
            else if (aluop == `ALUOP_TLBR) cp0_read_data_r = {cp0_entrylo0[31:26], r_resp[49:25], r_resp[`G]};
            else cp0_read_data_r = cp0_entrylo0;
        end
        {5'b00011, 3'b000}: begin
            if (cp0_write_enable && write_addr_sel == read_addr_sel) cp0_read_data_r = {cp0_entrylo1[31:26], cp0_write_data[25:0]};
            else if (aluop == `ALUOP_TLBR) cp0_read_data_r = {cp0_entrylo1[31:26], r_resp[24:0], r_resp[`G]};
            else cp0_read_data_r = cp0_entrylo1;
        end
        {5'b00101, 3'b000}: begin
            if (cp0_write_enable && write_addr_sel == read_addr_sel) cp0_read_data_r = {cp0_pagemask[31:25], cp0_write_data[24:13], cp0_pagemask[12:0]};
            else if (aluop == `ALUOP_TLBR) cp0_read_data_r = {cp0_pagemask[31:25], r_resp[`PAGEMASK], cp0_pagemask[12:0]};
            else cp0_read_data_r = cp0_pagemask;
        end
        {5'b01000, 3'b000}: begin
            cp0_read_data_r = cp0_badvaddr;
        end
        {5'b01001, 3'b000}: begin
            if (cp0_write_enable && write_addr_sel == read_addr_sel) cp0_read_data_r = cp0_write_data;
            else cp0_read_data_r = cp0_count;
        end
        {5'b01010, 3'b000}: begin
            if (cp0_write_enable && write_addr_sel == read_addr_sel) cp0_read_data_r = {cp0_write_data[31:13], cp0_entryhi[12:8], cp0_write_data[7:0]};
            else if (aluop == `ALUOP_TLBR) cp0_read_data_r = {r_resp[`VPN2], cp0_entryhi[12:8], r_resp[`ASID]};
            else cp0_read_data_r = cp0_entryhi;
        end
        {5'b01011, 3'b000}: begin
            if (cp0_write_enable && write_addr_sel == read_addr_sel) cp0_read_data_r = cp0_write_data;
            else cp0_read_data_r = cp0_compare;
        end
        {5'b01100, 3'b000}: begin
            if (cp0_write_enable && write_addr_sel == read_addr_sel) cp0_read_data_r = {cp0_status[31:16], cp0_write_data[15:8], cp0_status[7:2], cp0_write_data[1:0]};
            else cp0_read_data_r = cp0_status;
        end
        {5'b01101, 3'b000}: begin
            cp0_read_data_r = cp0_cause;
        end
        {5'b01110, 3'b000}: begin
            if (cp0_write_enable && write_addr_sel == read_addr_sel) cp0_read_data_r = cp0_write_data;
            else cp0_read_data_r = cp0_epc;
        end
        {5'b01111, 3'b000}: begin
            cp0_read_data_r = cp0_prid;
        end
        {5'b10000, 3'b000}: begin
            if (cp0_write_enable && write_addr_sel == read_addr_sel) cp0_read_data_r = {cp0_config0[31:3], cp0_write_data[2:0]};
            else cp0_read_data_r = cp0_config0;
        end
        {5'b00000, 3'b001}: begin
            cp0_read_data_r = cp0_config1;
        end
        default: begin
            cp0_read_data_r = 32'b0;
        end
        endcase
    end
    
    
    // write
    // index
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE) begin
            cp0_index <= 32'b0;   
        end else if (cp0_write_enable && cp0_write_addr == 5'd0 && cp0_write_sel == 3'b0) begin
            cp0_index[4:0] <= cp0_write_data[4:0];
        end else if (aluop == `ALUOP_TLBP) begin
            cp0_index[31] <= p_miss;
            cp0_index[4:0] <= p_index;
        end
    end
    // random
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE) begin
            cp0_random <= 32'b0;   
        end else begin
            cp0_random[4:0] <= cp0_random[4:0] + 1;
        end
    end
    // entrylo0
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE) begin
            cp0_entrylo0 <= 32'b0;
        end else if (cp0_write_enable && cp0_write_addr == 5'd2 && cp0_write_sel == 3'b0) begin
            cp0_entrylo0[25:0] <= cp0_write_data[25:0];
        end else if (aluop == `ALUOP_TLBR) begin
            cp0_entrylo0[25:1] <= r_resp[49:25];
            cp0_entrylo0[0] <= r_resp[`G];
        end
    end
    // entrylo1
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE) begin
            cp0_entrylo1 <= 32'b0;
        end else if (cp0_write_enable && cp0_write_addr == 5'd3 && cp0_write_sel == 3'b0) begin
            cp0_entrylo1[25:0] <= cp0_write_data[25:0];
        end else if (aluop == `ALUOP_TLBR) begin
            cp0_entrylo1[25:1] <= r_resp[24:0];
            cp0_entrylo1[0] <= r_resp[`G];
        end
    end
    // pagemask
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE) begin
            cp0_pagemask <= 32'b0;
        end else if (cp0_write_enable && cp0_write_addr == 5'd5 && cp0_write_sel == 3'b0) begin
            cp0_pagemask[24:13] <= cp0_write_data[24:13];
        end else if (aluop == `ALUOP_TLBR) begin
            cp0_pagemask[24:13] <= r_resp[`PAGEMASK];
        end
    end
    // badvaddr
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE) begin
            cp0_badvaddr <= 32'b0;
        end else if (commit_exception) begin
            cp0_badvaddr <= commit_bvaddr;
        end
    end
    // count
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE) begin
            cp0_count <= 32'b0;
        end else if (cp0_write_enable && cp0_write_addr == 5'd9 && cp0_write_sel == 3'b0) begin
            cp0_count <= cp0_write_data;
        end else begin
            cp0_count <= cp0_count + 1;
        end
    end
    // entryhi
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE) begin
            cp0_entryhi <= 32'b0;
        end else if (commit_exception && exception_tlb) begin
            cp0_entryhi[31:13] <= commit_bvaddr[31:13];
        end else if (cp0_write_enable && cp0_write_addr == 5'd10 && cp0_write_sel == 3'b0) begin
            cp0_entryhi[31:13] <= cp0_write_data[31:13];
            cp0_entryhi[7:0] <= cp0_write_data[7:0];
        end else if (aluop == `ALUOP_TLBR) begin
            cp0_entryhi[31:13] = r_resp[`VPN2];
            cp0_entryhi[7:0] = r_resp[`ASID];
        end
    end
    // compare
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE) begin
            cp0_compare <= 32'b0;
        end else if (cp0_write_enable && cp0_write_addr == 5'd11 && cp0_write_sel == 3'b0) begin
            cp0_compare <= cp0_write_data;
        end
    end
    // status
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE) begin
            cp0_status <= 32'b00000000010000000000000000000000;
        end if (exception) begin
            cp0_status[1] <= !commit_eret;
        end else if (cp0_write_enable && cp0_write_addr == 5'd12 && cp0_write_sel == 3'b0) begin
            cp0_status[15:8] <= cp0_write_data[15:8];
            cp0_status[1:0] <= cp0_write_data[1:0];
        end
    end
    // cause
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE) begin
            cp0_cause <= 32'b0;
        end else begin
            cp0_cause[30] <= timer_int; // ?
            cp0_cause[15:10] <= interrupt; // ?
            if (commit_exception) begin
                cp0_cause[31] <= commit_bd;
                cp0_cause[6:2] <= commit_code;
            end else if (cp0_write_enable && cp0_write_addr == 5'd13 && cp0_write_sel == 3'b0) begin
                cp0_cause[9:8] <= cp0_write_data[9:8];
            end
        end
    end
    // epc
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE) begin
            cp0_epc <= 32'b0;
        end else if (commit_exception) begin
            cp0_epc <= commit_epc;
        end else if (cp0_write_enable && cp0_write_addr == 5'd14 && cp0_write_sel == 3'b0) begin
            cp0_epc <= cp0_write_data;
        end
    end
    // prid
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE) begin
            cp0_prid <= 32'b0;
        end
    end
    // config0
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE) begin
            cp0_config0 <= {1'b1, // M
                            15'b000000000000000, // 
                            1'b0, // BE
                            2'b00, // AT
                            3'b000, // AR
                            3'b001, // MT
                            4'b0000, //
                            3'b010 // K0
                            };
        end else if (cp0_write_enable && cp0_write_addr == 5'd16 && cp0_write_sel == 3'b0) begin
            cp0_config0[2:0] <= cp0_write_data[2:0];
        end
    end
    // config1
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE) begin
            cp0_config1 <= {1'b0, // M
                            6'b011111, // MMUSize - 1
                            3'b001, // IS
                            3'b100, // IL
                            3'b001, // IA
                            3'b001, // DS
                            3'b100, // DL
                            3'b001, // DA
                            7'b0000000 // C2 MD PC WR CA EP FP
                            };
        end
    end


    assign w_valid = (!commit_exception && (aluop == `ALUOP_TLBWI || aluop == `ALUOP_TLBWR));
    assign w_index = (aluop == `ALUOP_TLBWR) ? cp0_random[4:0] : cp0_index[4:0];
    
//    tlb tlb0(
//        .clk(clk),
//        .rst(rst),
        
//        .r_index(cp0_index[4:0]),
//        .r_resp(r_resp),
        
//        .w_valid(w_valid),
//        .w_index(w_index),
//        .w_data({cp0_entryhi[31:13], cp0_entryhi[7:0], cp0_pagemask[24:13], cp0_entrylo0[0] & cp0_entrylo1[0], cp0_entrylo0[25:1], cp0_entrylo1[25:1]}),
        
//        .p_vpn2(cp0_entryhi[31:13]),
//        .p_asid(cp0_entryhi[7:0]),
//        .p_index(p_index),
//        .p_miss(p_miss),
        
//        .qi_asid(cp0_entryhi[7:0]),
//        .qi_vaddr(inst_vaddr),
//        .qi_paddr(inst_paddr),
//        .qi_miss(inst_miss),
//        .qi_invalid(inst_invalid),
//        .qi_cache(inst_cache),
        
//        .qd_asid(cp0_entryhi[7:0]),
//        .qd_vaddr(data_vaddr),
//        .qd_ren(data_ren),
//        .qd_wen(data_wen),
//        .qd_paddr(data_paddr),
//        .qd_miss(data_miss),//
//        .qd_invalid(data_invalid),//
//        .qd_modified(data_modified),//
//        .qd_cache(data_cache)
//    );

    // don't use tlb
    assign r_resp = 90'b0;
    assign p_index = 5'b0;
    assign p_miss = 1'b0;
    
    assign inst_paddr = {3'b000, inst_vaddr[28:0]};
    assign inst_miss = 1'b0;
    assign inst_invalid = 1'b0;
    assign inst_cache = inst_vaddr[31:29] == 3'b100 ? 1'b1 : 1'b0;
    
    assign data_paddr = {3'b000, data_vaddr[28:0]};
    assign data_miss = 1'b0;
    assign data_invalid = 1'b0;
    assign data_modified = 1'b0;
    assign data_cache = data_vaddr[31:29] == 3'b100 ? 1'b1 : 1'b0;
    
endmodule