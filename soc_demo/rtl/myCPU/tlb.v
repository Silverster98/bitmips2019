`timescale 1ns / 1ps
`include "defines.v"

// tlb entry num = 16
module tlb(
    input   wire            clk,
    input   wire            rst,
    
    input   wire[4:0]       r_index,
    output  wire[89:0]      r_resp,
    
    input   wire            w_valid,
    input   wire[4:0]       w_index,
    input   wire[89:0]      w_data,
    
    input   wire[18:0]      p_vpn2,
    input   wire[7:0]       p_asid,
    output  wire[4:0]       p_index,
    output  wire            p_miss,
    
    input   wire[7:0]       qi_asid,
    input   wire[31:0]      qi_vaddr,
    output  reg[31:0]       qi_paddr,
    output  reg             qi_miss,
    output  reg             qi_invalid,
    output  reg             qi_cache,
    
    input   wire[7:0]       qd_asid,
    input   wire[31:0]      qd_vaddr,
    input   wire            qd_ren,
    input   wire            qd_wen,
    output  reg[31:0]       qd_paddr,
    output  reg             qd_miss,
    output  reg             qd_invalid,
    output  reg             qd_modified,
    output  reg             qd_cache
    );
reg[89:0] tlb_entry[31:0];

// read
reg[89:0] get_r_resp;
assign r_resp = get_r_resp;

always @ (*)
begin
    case (r_index)
    5'd0: get_r_resp = tlb_entry[0];
    5'd1: get_r_resp = tlb_entry[1];
    5'd2: get_r_resp = tlb_entry[2];
    5'd3: get_r_resp = tlb_entry[3];
    5'd4: get_r_resp = tlb_entry[4];
    5'd5: get_r_resp = tlb_entry[5];
    5'd6: get_r_resp = tlb_entry[6];
    5'd7: get_r_resp = tlb_entry[7];
    5'd8: get_r_resp = tlb_entry[8];
    5'd9: get_r_resp = tlb_entry[9];
    5'd10: get_r_resp = tlb_entry[10];
    5'd11: get_r_resp = tlb_entry[11];
    5'd12: get_r_resp = tlb_entry[12];
    5'd13: get_r_resp = tlb_entry[13];
    5'd14: get_r_resp = tlb_entry[14];
    5'd15: get_r_resp = tlb_entry[15];
    5'd16: get_r_resp = tlb_entry[16];
    5'd17: get_r_resp = tlb_entry[17];
    5'd18: get_r_resp = tlb_entry[18];
    5'd19: get_r_resp = tlb_entry[19];
    5'd20: get_r_resp = tlb_entry[20];
    5'd21: get_r_resp = tlb_entry[21];
    5'd22: get_r_resp = tlb_entry[22];
    5'd23: get_r_resp = tlb_entry[23];
    5'd24: get_r_resp = tlb_entry[24];
    5'd25: get_r_resp = tlb_entry[25];
    5'd26: get_r_resp = tlb_entry[26];
    5'd27: get_r_resp = tlb_entry[27];
    5'd28: get_r_resp = tlb_entry[28];
    5'd29: get_r_resp = tlb_entry[29];
    5'd30: get_r_resp = tlb_entry[30];
    5'd31: get_r_resp = tlb_entry[31];
    default: get_r_resp = 90'b0;
    endcase
end

// write
always @ (posedge clk) begin
    if (rst == `RST_ENABLE) begin
        tlb_entry[0] <= 90'b0;
        tlb_entry[1] <= 90'b0;
        tlb_entry[2] <= 90'b0;
        tlb_entry[3] <= 90'b0;
        tlb_entry[4] <= 90'b0;
        tlb_entry[5] <= 90'b0;
        tlb_entry[6] <= 90'b0;
        tlb_entry[7] <= 90'b0;
        tlb_entry[8] <= 90'b0;
        tlb_entry[9] <= 90'b0;
        tlb_entry[10] <= 90'b0;
        tlb_entry[11] <= 90'b0;
        tlb_entry[12] <= 90'b0;
        tlb_entry[13] <= 90'b0;
        tlb_entry[14] <= 90'b0;
        tlb_entry[15] <= 90'b0;
        tlb_entry[16] <= 90'b0;
        tlb_entry[17] <= 90'b0;
        tlb_entry[18] <= 90'b0;
        tlb_entry[19] <= 90'b0;
        tlb_entry[20] <= 90'b0;
        tlb_entry[21] <= 90'b0;
        tlb_entry[22] <= 90'b0;
        tlb_entry[23] <= 90'b0;
        tlb_entry[24] <= 90'b0;
        tlb_entry[25] <= 90'b0;
        tlb_entry[26] <= 90'b0;
        tlb_entry[27] <= 90'b0;
        tlb_entry[28] <= 90'b0;
        tlb_entry[29] <= 90'b0;
        tlb_entry[30] <= 90'b0;
        tlb_entry[31] <= 90'b0;
    end else begin
        if (w_valid == 1'b1) begin
            tlb_entry[w_index] = w_data;
        end
    end
end

// probe
reg[5:0] p_index_temp;
assign p_index = p_index_temp[4:0];
assign p_miss = p_index_temp[5] == 1'b1 ? 1'b1 : 1'b0;
always @ (*)
begin
    p_index_temp = (tlb_entry[0][`VPN2] == p_vpn2 && (tlb_entry[0][`G] == 1'b1 || tlb_entry[0][`ASID] == p_asid)) ? 6'd0 :
                   (tlb_entry[1][`VPN2] == p_vpn2 && (tlb_entry[1][`G] == 1'b1 || tlb_entry[1][`ASID] == p_asid)) ? 6'd1 :
                   (tlb_entry[2][`VPN2] == p_vpn2 && (tlb_entry[2][`G] == 1'b1 || tlb_entry[2][`ASID] == p_asid)) ? 6'd2 :
                   (tlb_entry[3][`VPN2] == p_vpn2 && (tlb_entry[3][`G] == 1'b1 || tlb_entry[3][`ASID] == p_asid)) ? 6'd3 :
                   (tlb_entry[4][`VPN2] == p_vpn2 && (tlb_entry[4][`G] == 1'b1 || tlb_entry[4][`ASID] == p_asid)) ? 6'd4 :
                   (tlb_entry[5][`VPN2] == p_vpn2 && (tlb_entry[5][`G] == 1'b1 || tlb_entry[5][`ASID] == p_asid)) ? 6'd5 :
                   (tlb_entry[6][`VPN2] == p_vpn2 && (tlb_entry[6][`G] == 1'b1 || tlb_entry[6][`ASID] == p_asid)) ? 6'd6 :
                   (tlb_entry[7][`VPN2] == p_vpn2 && (tlb_entry[7][`G] == 1'b1 || tlb_entry[7][`ASID] == p_asid)) ? 6'd7 :
                   (tlb_entry[8][`VPN2] == p_vpn2 && (tlb_entry[8][`G] == 1'b1 || tlb_entry[8][`ASID] == p_asid)) ? 6'd8 :
                   (tlb_entry[9][`VPN2] == p_vpn2 && (tlb_entry[9][`G] == 1'b1 || tlb_entry[9][`ASID] == p_asid)) ? 6'd9 :
                   (tlb_entry[10][`VPN2] == p_vpn2 && (tlb_entry[10][`G] == 1'b1 || tlb_entry[10][`ASID] == p_asid)) ? 6'd10 :
                   (tlb_entry[11][`VPN2] == p_vpn2 && (tlb_entry[11][`G] == 1'b1 || tlb_entry[11][`ASID] == p_asid)) ? 6'd11 :
                   (tlb_entry[12][`VPN2] == p_vpn2 && (tlb_entry[12][`G] == 1'b1 || tlb_entry[12][`ASID] == p_asid)) ? 6'd12 :
                   (tlb_entry[13][`VPN2] == p_vpn2 && (tlb_entry[13][`G] == 1'b1 || tlb_entry[13][`ASID] == p_asid)) ? 6'd13 :
                   (tlb_entry[14][`VPN2] == p_vpn2 && (tlb_entry[14][`G] == 1'b1 || tlb_entry[14][`ASID] == p_asid)) ? 6'd14 :
                   (tlb_entry[15][`VPN2] == p_vpn2 && (tlb_entry[15][`G] == 1'b1 || tlb_entry[15][`ASID] == p_asid)) ? 6'd15 :
                   (tlb_entry[16][`VPN2] == p_vpn2 && (tlb_entry[16][`G] == 1'b1 || tlb_entry[16][`ASID] == p_asid)) ? 6'd16 :
                   (tlb_entry[17][`VPN2] == p_vpn2 && (tlb_entry[17][`G] == 1'b1 || tlb_entry[17][`ASID] == p_asid)) ? 6'd17 :
                   (tlb_entry[18][`VPN2] == p_vpn2 && (tlb_entry[18][`G] == 1'b1 || tlb_entry[18][`ASID] == p_asid)) ? 6'd18 :
                   (tlb_entry[19][`VPN2] == p_vpn2 && (tlb_entry[19][`G] == 1'b1 || tlb_entry[19][`ASID] == p_asid)) ? 6'd19 :
                   (tlb_entry[20][`VPN2] == p_vpn2 && (tlb_entry[20][`G] == 1'b1 || tlb_entry[20][`ASID] == p_asid)) ? 6'd20 :
                   (tlb_entry[21][`VPN2] == p_vpn2 && (tlb_entry[21][`G] == 1'b1 || tlb_entry[21][`ASID] == p_asid)) ? 6'd21 :
                   (tlb_entry[22][`VPN2] == p_vpn2 && (tlb_entry[22][`G] == 1'b1 || tlb_entry[22][`ASID] == p_asid)) ? 6'd22 :
                   (tlb_entry[23][`VPN2] == p_vpn2 && (tlb_entry[23][`G] == 1'b1 || tlb_entry[23][`ASID] == p_asid)) ? 6'd23 :
                   (tlb_entry[24][`VPN2] == p_vpn2 && (tlb_entry[24][`G] == 1'b1 || tlb_entry[24][`ASID] == p_asid)) ? 6'd24 :
                   (tlb_entry[25][`VPN2] == p_vpn2 && (tlb_entry[25][`G] == 1'b1 || tlb_entry[25][`ASID] == p_asid)) ? 6'd25 :
                   (tlb_entry[26][`VPN2] == p_vpn2 && (tlb_entry[26][`G] == 1'b1 || tlb_entry[26][`ASID] == p_asid)) ? 6'd26 :
                   (tlb_entry[27][`VPN2] == p_vpn2 && (tlb_entry[27][`G] == 1'b1 || tlb_entry[27][`ASID] == p_asid)) ? 6'd27 :
                   (tlb_entry[28][`VPN2] == p_vpn2 && (tlb_entry[28][`G] == 1'b1 || tlb_entry[28][`ASID] == p_asid)) ? 6'd28 :
                   (tlb_entry[29][`VPN2] == p_vpn2 && (tlb_entry[29][`G] == 1'b1 || tlb_entry[29][`ASID] == p_asid)) ? 6'd29 :
                   (tlb_entry[30][`VPN2] == p_vpn2 && (tlb_entry[30][`G] == 1'b1 || tlb_entry[30][`ASID] == p_asid)) ? 6'd30 :
                   (tlb_entry[31][`VPN2] == p_vpn2 && (tlb_entry[31][`G] == 1'b1 || tlb_entry[31][`ASID] == p_asid)) ? 6'd31 :
                   6'd32;
end

// inst addr mmu
reg[5:0] itlb_hit_index;
always @ (*) begin
    if (rst == `RST_ENABLE) begin
        qi_paddr = 32'b0;
        qi_miss  = 1'b0;
        qi_invalid = 1'b0;
        qi_cache = 1'b0;
        itlb_hit_index = 6'b0;
    end else begin
        if (qi_vaddr[31:29] == 3'b100) begin
            qi_paddr = {3'b000, qi_vaddr[28:0]};
            qi_miss = 1'b0;
            qi_invalid = 1'b0;
            qi_cache = 1'b1;
            itlb_hit_index = 6'b0;
        end else if (qi_vaddr[31:29] == 3'b101) begin
            qi_paddr = {3'b000, qi_vaddr[28:0]};
            qi_miss = 1'b0;
            qi_invalid = 1'b0;
            qi_cache = 1'b0;
            itlb_hit_index = 6'b0;
        end else begin
            itlb_hit_index = (tlb_entry[0][`VPN2] == qi_vaddr[31:13] && (tlb_entry[0][`G] == 1'b1 || tlb_entry[0][`ASID] == qi_asid)) ? 6'd0 :
                             (tlb_entry[1][`VPN2] == qi_vaddr[31:13] && (tlb_entry[1][`G] == 1'b1 || tlb_entry[1][`ASID] == qi_asid)) ? 6'd1 :
                             (tlb_entry[2][`VPN2] == qi_vaddr[31:13] && (tlb_entry[2][`G] == 1'b1 || tlb_entry[2][`ASID] == qi_asid)) ? 6'd2 :
                             (tlb_entry[3][`VPN2] == qi_vaddr[31:13] && (tlb_entry[3][`G] == 1'b1 || tlb_entry[3][`ASID] == qi_asid)) ? 6'd3 :
                             (tlb_entry[4][`VPN2] == qi_vaddr[31:13] && (tlb_entry[4][`G] == 1'b1 || tlb_entry[4][`ASID] == qi_asid)) ? 6'd4 :
                             (tlb_entry[5][`VPN2] == qi_vaddr[31:13] && (tlb_entry[5][`G] == 1'b1 || tlb_entry[5][`ASID] == qi_asid)) ? 6'd5 :
                             (tlb_entry[6][`VPN2] == qi_vaddr[31:13] && (tlb_entry[6][`G] == 1'b1 || tlb_entry[6][`ASID] == qi_asid)) ? 6'd6 :
                             (tlb_entry[7][`VPN2] == qi_vaddr[31:13] && (tlb_entry[7][`G] == 1'b1 || tlb_entry[7][`ASID] == qi_asid)) ? 6'd7 :
                             (tlb_entry[8][`VPN2] == qi_vaddr[31:13] && (tlb_entry[8][`G] == 1'b1 || tlb_entry[8][`ASID] == qi_asid)) ? 6'd8 :
                             (tlb_entry[9][`VPN2] == qi_vaddr[31:13] && (tlb_entry[9][`G] == 1'b1 || tlb_entry[9][`ASID] == qi_asid)) ? 6'd9 :
                             (tlb_entry[10][`VPN2] == qi_vaddr[31:13] && (tlb_entry[10][`G] == 1'b1 || tlb_entry[10][`ASID] == qi_asid)) ? 6'd10 :
                             (tlb_entry[11][`VPN2] == qi_vaddr[31:13] && (tlb_entry[11][`G] == 1'b1 || tlb_entry[11][`ASID] == qi_asid)) ? 6'd11 :
                             (tlb_entry[12][`VPN2] == qi_vaddr[31:13] && (tlb_entry[12][`G] == 1'b1 || tlb_entry[12][`ASID] == qi_asid)) ? 6'd12 :
                             (tlb_entry[13][`VPN2] == qi_vaddr[31:13] && (tlb_entry[13][`G] == 1'b1 || tlb_entry[13][`ASID] == qi_asid)) ? 6'd13 :
                             (tlb_entry[14][`VPN2] == qi_vaddr[31:13] && (tlb_entry[14][`G] == 1'b1 || tlb_entry[14][`ASID] == qi_asid)) ? 6'd14 :
                             (tlb_entry[15][`VPN2] == qi_vaddr[31:13] && (tlb_entry[15][`G] == 1'b1 || tlb_entry[15][`ASID] == qi_asid)) ? 6'd15 :
                             (tlb_entry[16][`VPN2] == qi_vaddr[31:13] && (tlb_entry[16][`G] == 1'b1 || tlb_entry[16][`ASID] == qi_asid)) ? 6'd16 :
                             (tlb_entry[17][`VPN2] == qi_vaddr[31:13] && (tlb_entry[17][`G] == 1'b1 || tlb_entry[17][`ASID] == qi_asid)) ? 6'd17 :
                             (tlb_entry[18][`VPN2] == qi_vaddr[31:13] && (tlb_entry[18][`G] == 1'b1 || tlb_entry[18][`ASID] == qi_asid)) ? 6'd18 :
                             (tlb_entry[19][`VPN2] == qi_vaddr[31:13] && (tlb_entry[19][`G] == 1'b1 || tlb_entry[19][`ASID] == qi_asid)) ? 6'd19 :
                             (tlb_entry[20][`VPN2] == qi_vaddr[31:13] && (tlb_entry[20][`G] == 1'b1 || tlb_entry[20][`ASID] == qi_asid)) ? 6'd20 :
                             (tlb_entry[21][`VPN2] == qi_vaddr[31:13] && (tlb_entry[21][`G] == 1'b1 || tlb_entry[21][`ASID] == qi_asid)) ? 6'd21 :
                             (tlb_entry[22][`VPN2] == qi_vaddr[31:13] && (tlb_entry[22][`G] == 1'b1 || tlb_entry[22][`ASID] == qi_asid)) ? 6'd22 :
                             (tlb_entry[23][`VPN2] == qi_vaddr[31:13] && (tlb_entry[23][`G] == 1'b1 || tlb_entry[23][`ASID] == qi_asid)) ? 6'd23 :
                             (tlb_entry[24][`VPN2] == qi_vaddr[31:13] && (tlb_entry[24][`G] == 1'b1 || tlb_entry[24][`ASID] == qi_asid)) ? 6'd24 :
                             (tlb_entry[25][`VPN2] == qi_vaddr[31:13] && (tlb_entry[25][`G] == 1'b1 || tlb_entry[25][`ASID] == qi_asid)) ? 6'd25 :
                             (tlb_entry[26][`VPN2] == qi_vaddr[31:13] && (tlb_entry[26][`G] == 1'b1 || tlb_entry[26][`ASID] == qi_asid)) ? 6'd26 :
                             (tlb_entry[27][`VPN2] == qi_vaddr[31:13] && (tlb_entry[27][`G] == 1'b1 || tlb_entry[27][`ASID] == qi_asid)) ? 6'd27 :
                             (tlb_entry[28][`VPN2] == qi_vaddr[31:13] && (tlb_entry[28][`G] == 1'b1 || tlb_entry[28][`ASID] == qi_asid)) ? 6'd28 :
                             (tlb_entry[29][`VPN2] == qi_vaddr[31:13] && (tlb_entry[29][`G] == 1'b1 || tlb_entry[29][`ASID] == qi_asid)) ? 6'd29 :
                             (tlb_entry[30][`VPN2] == qi_vaddr[31:13] && (tlb_entry[30][`G] == 1'b1 || tlb_entry[30][`ASID] == qi_asid)) ? 6'd30 :
                             (tlb_entry[31][`VPN2] == qi_vaddr[31:13] && (tlb_entry[31][`G] == 1'b1 || tlb_entry[31][`ASID] == qi_asid)) ? 6'd31 :
                             6'd32;
            qi_miss = itlb_hit_index[5] == 1'b1 ? 1'b1 : 1'b0;
            if (qi_vaddr[12] == 1'b0) begin
                qi_paddr = {tlb_entry[itlb_hit_index[4:0]][`PFN0], qi_vaddr[11:0]};
                qi_invalid = tlb_entry[itlb_hit_index[4:0]][`V0] == 1'b0 ? 1'b1 : 1'b0;
                qi_cache = tlb_entry[itlb_hit_index[4:0]][`C0] == 3'b011 ? 1'b1 : 1'b0;
            end else begin
                qi_paddr = {tlb_entry[itlb_hit_index[4:0]][`PFN1], qi_vaddr[11:0]};
                qi_invalid = tlb_entry[itlb_hit_index[4:0]][`V1] == 1'b0 ? 1'b1 : 1'b0;
                qi_cache = tlb_entry[itlb_hit_index[4:0]][`C1] == 3'b011 ? 1'b1 : 1'b0;
            end
        end
    end
end

// data addr mmu
reg[5:0] dtlb_hit_index;
always @ (*) begin
    if (rst == `RST_ENABLE) begin
        qd_paddr = 32'b0;
        qd_miss  = 1'b0;
        qd_invalid = 1'b0;
        qd_modified = 1'b0;
        qd_cache = 1'b0;
        dtlb_hit_index = 6'b0;
    end else begin
        if (qd_vaddr[31:29] == 3'b100) begin
            qd_paddr = {3'b000, qd_vaddr[28:0]};
            qd_miss = 1'b0;
            qd_invalid = 1'b0;
            qd_modified = 1'b0;
            qd_cache = 1'b1;
            dtlb_hit_index = 6'b0;
        end else if (qd_vaddr[31:29] == 3'b101) begin
            qd_paddr = {3'b000, qd_vaddr[28:0]};
            qd_miss = 1'b0;
            qd_invalid = 1'b0;
            qd_modified = 1'b0;
            qd_cache = 1'b0;
            dtlb_hit_index = 6'b0;
        end else begin
            dtlb_hit_index = (tlb_entry[0][`VPN2] == qd_vaddr[31:13] && (tlb_entry[0][`G] == 1'b1 || tlb_entry[0][`ASID] == qd_asid)) ? 6'd0 :
                             (tlb_entry[1][`VPN2] == qd_vaddr[31:13] && (tlb_entry[1][`G] == 1'b1 || tlb_entry[1][`ASID] == qd_asid)) ? 6'd1 :
                             (tlb_entry[2][`VPN2] == qd_vaddr[31:13] && (tlb_entry[2][`G] == 1'b1 || tlb_entry[2][`ASID] == qd_asid)) ? 6'd2 :
                             (tlb_entry[3][`VPN2] == qd_vaddr[31:13] && (tlb_entry[3][`G] == 1'b1 || tlb_entry[3][`ASID] == qd_asid)) ? 6'd3 :
                             (tlb_entry[4][`VPN2] == qd_vaddr[31:13] && (tlb_entry[4][`G] == 1'b1 || tlb_entry[4][`ASID] == qd_asid)) ? 6'd4 :
                             (tlb_entry[5][`VPN2] == qd_vaddr[31:13] && (tlb_entry[5][`G] == 1'b1 || tlb_entry[5][`ASID] == qd_asid)) ? 6'd5 :
                             (tlb_entry[6][`VPN2] == qd_vaddr[31:13] && (tlb_entry[6][`G] == 1'b1 || tlb_entry[6][`ASID] == qd_asid)) ? 6'd6 :
                             (tlb_entry[7][`VPN2] == qd_vaddr[31:13] && (tlb_entry[7][`G] == 1'b1 || tlb_entry[7][`ASID] == qd_asid)) ? 6'd7 :
                             (tlb_entry[8][`VPN2] == qd_vaddr[31:13] && (tlb_entry[8][`G] == 1'b1 || tlb_entry[8][`ASID] == qd_asid)) ? 6'd8 :
                             (tlb_entry[9][`VPN2] == qd_vaddr[31:13] && (tlb_entry[9][`G] == 1'b1 || tlb_entry[9][`ASID] == qd_asid)) ? 6'd9 :
                             (tlb_entry[10][`VPN2] == qd_vaddr[31:13] && (tlb_entry[10][`G] == 1'b1 || tlb_entry[10][`ASID] == qd_asid)) ? 6'd10 :
                             (tlb_entry[11][`VPN2] == qd_vaddr[31:13] && (tlb_entry[11][`G] == 1'b1 || tlb_entry[11][`ASID] == qd_asid)) ? 6'd11 :
                             (tlb_entry[12][`VPN2] == qd_vaddr[31:13] && (tlb_entry[12][`G] == 1'b1 || tlb_entry[12][`ASID] == qd_asid)) ? 6'd12 :
                             (tlb_entry[13][`VPN2] == qd_vaddr[31:13] && (tlb_entry[13][`G] == 1'b1 || tlb_entry[13][`ASID] == qd_asid)) ? 6'd13 :
                             (tlb_entry[14][`VPN2] == qd_vaddr[31:13] && (tlb_entry[14][`G] == 1'b1 || tlb_entry[14][`ASID] == qd_asid)) ? 6'd14 :
                             (tlb_entry[15][`VPN2] == qd_vaddr[31:13] && (tlb_entry[15][`G] == 1'b1 || tlb_entry[15][`ASID] == qd_asid)) ? 6'd15 :
                             (tlb_entry[16][`VPN2] == qd_vaddr[31:13] && (tlb_entry[16][`G] == 1'b1 || tlb_entry[16][`ASID] == qd_asid)) ? 6'd16 :
                             (tlb_entry[17][`VPN2] == qd_vaddr[31:13] && (tlb_entry[17][`G] == 1'b1 || tlb_entry[17][`ASID] == qd_asid)) ? 6'd17 :
                             (tlb_entry[18][`VPN2] == qd_vaddr[31:13] && (tlb_entry[18][`G] == 1'b1 || tlb_entry[18][`ASID] == qd_asid)) ? 6'd18 :
                             (tlb_entry[19][`VPN2] == qd_vaddr[31:13] && (tlb_entry[19][`G] == 1'b1 || tlb_entry[19][`ASID] == qd_asid)) ? 6'd19 :
                             (tlb_entry[20][`VPN2] == qd_vaddr[31:13] && (tlb_entry[20][`G] == 1'b1 || tlb_entry[20][`ASID] == qd_asid)) ? 6'd20 :
                             (tlb_entry[21][`VPN2] == qd_vaddr[31:13] && (tlb_entry[21][`G] == 1'b1 || tlb_entry[21][`ASID] == qd_asid)) ? 6'd21 :
                             (tlb_entry[22][`VPN2] == qd_vaddr[31:13] && (tlb_entry[22][`G] == 1'b1 || tlb_entry[22][`ASID] == qd_asid)) ? 6'd22 :
                             (tlb_entry[23][`VPN2] == qd_vaddr[31:13] && (tlb_entry[23][`G] == 1'b1 || tlb_entry[23][`ASID] == qd_asid)) ? 6'd23 :
                             (tlb_entry[24][`VPN2] == qd_vaddr[31:13] && (tlb_entry[24][`G] == 1'b1 || tlb_entry[24][`ASID] == qd_asid)) ? 6'd24 :
                             (tlb_entry[25][`VPN2] == qd_vaddr[31:13] && (tlb_entry[25][`G] == 1'b1 || tlb_entry[25][`ASID] == qd_asid)) ? 6'd25 :
                             (tlb_entry[26][`VPN2] == qd_vaddr[31:13] && (tlb_entry[26][`G] == 1'b1 || tlb_entry[26][`ASID] == qd_asid)) ? 6'd26 :
                             (tlb_entry[27][`VPN2] == qd_vaddr[31:13] && (tlb_entry[27][`G] == 1'b1 || tlb_entry[27][`ASID] == qd_asid)) ? 6'd27 :
                             (tlb_entry[28][`VPN2] == qd_vaddr[31:13] && (tlb_entry[28][`G] == 1'b1 || tlb_entry[28][`ASID] == qd_asid)) ? 6'd28 :
                             (tlb_entry[29][`VPN2] == qd_vaddr[31:13] && (tlb_entry[29][`G] == 1'b1 || tlb_entry[29][`ASID] == qd_asid)) ? 6'd29 :
                             (tlb_entry[30][`VPN2] == qd_vaddr[31:13] && (tlb_entry[30][`G] == 1'b1 || tlb_entry[30][`ASID] == qd_asid)) ? 6'd30 :
                             (tlb_entry[31][`VPN2] == qd_vaddr[31:13] && (tlb_entry[31][`G] == 1'b1 || tlb_entry[31][`ASID] == qd_asid)) ? 6'd31 :
                             6'd32;
            if (qd_ren || qd_wen) begin
                qd_miss = dtlb_hit_index[5] == 1'b1 ? 1'b1 : 1'b0;
                if (qd_vaddr[12] == 1'b0) begin
                    qd_paddr = {tlb_entry[dtlb_hit_index[4:0]][`PFN0], qd_vaddr[11:0]};
                    qd_invalid = tlb_entry[dtlb_hit_index[4:0]][`V0] == 1'b0 ? 1'b1 : 1'b0;
                    qd_modified = (tlb_entry[dtlb_hit_index[4:0]][`D0] == 1'b0 && qd_wen == 1'b1) ? 1'b1 : 1'b0;
                    qd_cache = tlb_entry[dtlb_hit_index[4:0]][`C0] == 3'b011 ? 1'b1 : 1'b0;
                end else begin
                    qd_paddr = {tlb_entry[dtlb_hit_index[4:0]][`PFN1], qd_vaddr[11:0]};
                    qd_invalid = tlb_entry[dtlb_hit_index[4:0]][`V1] == 1'b0 ? 1'b1 : 1'b0;
                    qd_modified = (tlb_entry[dtlb_hit_index[4:0]][`D1] == 1'b0 && qd_wen == 1'b1) ? 1'b1 : 1'b0;
                    qd_cache = tlb_entry[dtlb_hit_index[4:0]][`C1] == 3'b011 ? 1'b1 : 1'b0;
                end
            end else begin
                qd_paddr = 32'b0;
                qd_miss  = 1'b0;
                qd_invalid = 1'b0;
                qd_modified = 1'b0;
                qd_cache = 1'b0;
                dtlb_hit_index = 6'b0;
            end
        end
    end
end

endmodule
