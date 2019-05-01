`include "CP0.svh"
`include "CP0Types.svh"
//`include "TLBTypes.svh"

`define SIM 1

module cp0#(
	parameter CONFIG_VBASE = 32'hbfc00000,
	parameter CONFIG_CPU_INDEX = 0,
	parameter CONFIG_INTERRUPT_COMPAT_ONLY = 0,
	parameter CONFIG_HASEIC = 1,
	parameter CONFIG_TLB_ENTRIES = 64,
	parameter CONFIG_TLB_GROUP_SIZE = 4,
	parameter CONFIG_TLB_I_CACHE_SIZE = 4,
	parameter CONFIG_TLB_D_CACHE_SIZE = 8
)(
	input clock,
	input reset,

	output reg        is_kernel,

	/* Command */
	input             cmd_valid,
	input       [3:0] cmd_op,
	input       [4:0] cmd_no,
	input       [2:0] cmd_sel,
	input      [31:0] cmd_data,
	output reg [31:0] o_cmd_resp,     // error message?
	output reg        o_cmd_error,    // useful?
	output reg        o_cmd_stall,

	/* Pipeline */
	output reg        o_pl_reset, /* invalidate all instructions and jump to rv */
	output reg        o_pl_flush, /* finish instructions before the current one and jump to rv */
	output reg [31:0] o_pl_rv,         //0xbfc00000
	input      [31:0] pl_addr, /* address of current instruction */
	input             pl_delayslot,

	/* Exception request */
	input  [5:0] exr_type,
	input        exr_valid,
	input [31:0] exr_a0,           // address 

	/* Interrupt request */
	input [5:0] int_req, /* hw sources, RIPL in EIC mode */
	input       int_nmi,
	input       int_reset, /* soft reset */

	/* EIC interrupt output */
	output reg       o_intr_timer,
	output     [1:0] o_intr_soft

	/* TLB 
	input         tlbi_valid,
	input  [31:0] tlbi_vaddr,
	output        tlbi_ready,
	output        tlbi_miss,
	output [31:0] tlbi_paddr,
	output        tlbi_ri,
	output        tlbi_xi,
	output        tlbi_d,
	output        tlbi_c,
	output        tlbi_v,
	output        tlbi_kern,

	input         tlbd_valid,
	input  [31:0] tlbd_vaddr,
	output        tlbd_ready,
	output        tlbd_miss,
	output [31:0] tlbd_paddr,
	output        tlbd_ri,
	output        tlbd_xi,
	output        tlbd_d,
	output        tlbd_c,
	output        tlbd_v,
	output        tlbd_kern*/
);

`define SENSITIVITY posedge clock or posedge reset

/********** Output **********/
bit [31:0] cmd_resp;
bit cmd_error;
bit cmd_stall;
bit pl_reset;
bit pl_flush;
bit [31:0] pl_rv;
bit intr_timer;
bit [1:0] intr_soft;

/********** Internal Registers **********/
/* TLB */

bit reg_probe;
TLBEntryIndex reg_index;
TLBEntryIndex reg_wired;
TLBEntryIndex reg_random;
/*** Random ***/
bit [15:0] random_lfsr; /* 16-bit Fibonacci LFSR PRNG */

function void LFSRPRNGReset;
	random_lfsr = 16'hace1;
endfunction

function void LFSRPRNGUpdate;
	automatic bit n;
	reg_random = random_lfsr[5:0];
	if (reg_random < reg_wired || reg_random > CONFIG_TLB_ENTRIES - 1) begin
		reg_random = CONFIG_TLB_ENTRIES - 1;
	end
	n = random_lfsr[10] ^ random_lfsr[12] ^ random_lfsr[13] ^
		random_lfsr[15];
	random_lfsr = n | random_lfsr << 1;
endfunction

function void RandomUpdate;
	LFSRPRNGUpdate();
endfunction

function Word ReadRandom;
	automatic Word ret = reg_random;
	RandomUpdate();
	return ret;
endfunction
PageFrameIndex reg_lo0_pfn;
Cacheability reg_lo0_cacheattr;
bit reg_lo0_ri;
bit reg_lo0_xi;
bit reg_lo0_dirty;
bit reg_lo0_valid;
bit reg_lo0_global;
PageFrameIndex reg_lo1_pfn;
Cacheability reg_lo1_cacheattr;
bit reg_lo1_ri;
bit reg_lo1_xi;
bit reg_lo1_dirty;
bit reg_lo1_valid;
bit reg_lo1_global;
PageSize reg_pagesize;

function void CP0ResetTLBRegisters;
	LFSRPRNGReset();
	reg_lo0_ri = 0;
	reg_lo0_xi = 0;
	reg_lo1_ri = 0;
	reg_lo1_xi = 0;
	reg_random = 47;
	reg_wired = 0;
endfunction

/* Status */
ASIDType reg_asid;
bit [3:0] reg_status_cu;
bit reg_status_fr;
bit reg_status_bev;
bit reg_status_ts;
bit reg_status_sr;
bit reg_status_nmi;
bit [7:0] reg_status_im;
bit reg_status_um;
bit reg_status_erl;
bit reg_status_exl;
bit reg_status_ie;

function void CP0ResetStatusRegisters;
	reg_status_fr = 0;
	reg_status_bev = 1;
	reg_status_ts = 0;
	reg_status_sr = 0;
	reg_status_nmi = 0;
	reg_status_um = 0;
	reg_status_erl = 1;
endfunction

/* Exception */
PageFrameIndexHalf reg_badvpn2;
Address reg_badvaddr;
PageFrameIndexHalf reg_vpn2;
bit [2:0] reg_ipti = 7;
bit [4:0] reg_vs;
bit reg_cause_bd;
bit reg_cause_ti;
bit [1:0] reg_cause_ce;
bit reg_cause_dc;
bit reg_cause_iv;
bit reg_cause_wp;
bit reg_cause_fdci;
bit [7:0] reg_cause_ip;
bit [4:0] reg_cause_exccode;
Address reg_epc;
Address reg_errorepc;
PageFrameIndex reg_ebase;

function void CP0ResetExceptionRegisters;
	if (CONFIG_INTERRUPT_COMPAT_ONLY)
		reg_cause_iv = 0;
	reg_cause_dc = 0;
	reg_ebase = 20'h80000;
endfunction

/* Config */
Cacheability reg_kseg0attr;

function void CP0ResetConfigRegisters;
	reg_kseg0attr = Cachable;
endfunction

/* Counter */
Word reg_count;
Word reg_compare;

/* GPR */
bit [8:0] reg_ptebase;
Word reg_kscratch [7:0];

function void CP0ResetRegisters;
	CP0ResetTLBRegisters();
	CP0ResetStatusRegisters();
	CP0ResetExceptionRegisters();
endfunction

/********** Exceptions **********/
function bit isExceptionAsserted;
	return pl_reset == 1 || pl_flush == 1;
endfunction

function void AssertPipelineFlush(Address rv);
	pl_rv = rv;
	pl_flush = 1;
endfunction

/* HardReset */
function void AssertReset;
	`ifdef SIM
		$display("CP0: asserting Reset exception");
	`endif
	CP0ResetRegisters();
	pl_reset = 1;
	AssertPipelineFlush(CONFIG_VBASE);
	pl_flush = 0;
endfunction

/* SoftReset */
function void AssertSoftReset;
	`ifdef SIM
		$display("CP0: asserting SoftReset exception");
	`endif
	reg_status_bev = 1;
	reg_status_ts = 0;
	reg_status_sr = 1;
	reg_status_nmi = 0;
	reg_status_erl = 1;
	reg_errorepc = pl_delayslot ? pl_addr - 4 : pl_addr;
	AssertPipelineFlush(CONFIG_VBASE);
endfunction

/* NMI */
function void AssertNMI;
	`ifdef SIM
		$display("CP0: asserting NMI exception");
	`endif
	reg_status_bev = 1;
	reg_status_ts = 0;
	reg_status_sr = 0;
	reg_status_nmi = 1;
	reg_status_erl = 1;
	reg_errorepc = pl_delayslot ? pl_addr - 4 : pl_addr;
	AssertPipelineFlush(CONFIG_VBASE);
endfunction

function void AssertException(input bit [1:0] ce, input bit [4:0] exccode, input Address voffset);
	automatic Address restartaddr;
	automatic Address vbase;
	automatic Address expectedaddr;

	restartaddr = pl_delayslot ? pl_addr - 4 : pl_addr;
	if (reg_status_exl == 0) begin
		reg_epc = restartaddr;
		reg_cause_bd = pl_delayslot;
	end
	reg_cause_ce = ce;
	reg_cause_exccode = exccode;
	reg_status_exl = 1;

	if (reg_status_bev == 1) begin
		vbase = CONFIG_VBASE + 32'h200;
	end
	else begin
		vbase = reg_ebase << 12;
	end
	expectedaddr = vbase + voffset;
	AssertPipelineFlush({ reg_ebase[19:18], expectedaddr[29:0] });
endfunction

/* Int */
function void AssertInterruptException(input Address offset);
	`ifdef SIM
		$display("CP0: asserting interrupt exception at offset 0x%x", offset);
	`endif
	AssertException(0, 0, offset);
endfunction

/* IBE, DBE, Sys, Bp, RI, Ov, Tr, MCheck */
function void AssertGenericException(input bit [4:0] exccode);
	`ifdef SIM
		$display("CP0: asserting general exception (exccode=0x%02x)", exccode);
	`endif
	AssertException(0, exccode, 32'h180);
endfunction

/* Mod, AdEL, AdES, TLBRI, TLBXI, TLBIL, TLBIS */
function void AssertGeneralMemoryException(input bit [4:0] exccode, input Address faddr);
	`ifdef SIM
		$display("CP0: asserting general memory access exception (exccode=0x%02x, faddr=0x%08x)", exccode, faddr);
	`endif
	AssertException(0, exccode, 32'h180);
	reg_badvaddr = faddr;
	reg_badvpn2 = faddr[31:13];
	reg_vpn2 = faddr[31:13];
endfunction

/* TLBML, TLBMS */
function void AssertTLBRefillException(input bit [4:0] exccode, input Address faddr);
	`ifdef SIM
		$display("CP0: asserting TLB refill exception (exccode=0x%02x, faddr=0x%08x)", exccode, faddr);
	`endif
	if (reg_status_exl == 1) begin
		AssertException(0, exccode, 32'h180);
	end
	else begin
		AssertException(0, exccode, 0);
	end
	reg_badvaddr = faddr;
	reg_badvpn2 = faddr[31:13];
	reg_vpn2 = faddr[31:13];
endfunction

function void DeassertException;
	pl_reset = 0;
	pl_flush = 0;
endfunction

function void AssertExceptionReturn;
	Address raddr;
	if (reg_status_erl == 1) begin
		raddr = reg_errorepc;
		reg_status_erl = 0;
	end
	else begin
		raddr = reg_epc;
		reg_status_exl = 0;
	end
	AssertPipelineFlush(raddr);
endfunction

/********** Interrupts **********/
function bit couldHandleInterrupt;
	return reg_status_ie == 1 && reg_status_exl == 0 && reg_status_erl == 0;
endfunction

function bit isCompatibilityMode;
	return reg_cause_iv == 0 || reg_status_bev == 1;
endfunction

function bit isVectoredMode;
	return CONFIG_HASEIC == 0 && reg_vs != 0 && reg_cause_iv == 1 &&
		reg_status_bev == 0;
endfunction

function bit isEICMode;
	return CONFIG_HASEIC == 1 && reg_vs != 0 && reg_cause_iv == 1 &&
		reg_status_bev == 0;
endfunction

function void UpdateCauseIP;
	reg_cause_ip = { int_req, reg_cause_ip[1:0] };
	if (!isEICMode())
		reg_cause_ip[reg_ipti] = reg_cause_ip[reg_ipti] || intr_timer;
endfunction

function void HandleInterruptCompatibilityMode;
	automatic bit [7:0] ir;
	UpdateCauseIP();
	ir = reg_cause_ip & reg_status_im;
	if (couldHandleInterrupt() && ir != 0) begin
		if (reg_cause_iv == 0)
			AssertInterruptException(32'h180);
		else
			AssertInterruptException(32'h200);
	end
endfunction

function void HandleInterruptVectoredMode;
	automatic bit [7:0] ir;
	UpdateCauseIP();
	ir = reg_cause_ip & reg_status_im;
	if (couldHandleInterrupt() && ir != 0) begin
		automatic Address entry;
		automatic Address curentry = 32'h200;
		automatic Address spacing = reg_vs << 5;
		integer i;
		for (i = 0; i < 8; i = i + 1) begin
			if (ir[i] == 1)
				entry = curentry;
			curentry = curentry + spacing;
		end
		AssertInterruptException(entry);
	end
endfunction

function void HandleInterruptEICMode;
	automatic bit [5:0] ipl;
	automatic integer shiftn;
	UpdateCauseIP();
	ipl = reg_status_im[7:2];
	case (reg_vs)
		5'h00: shiftn = 'h000;
		5'h01: shiftn = 'h020;
		5'h02: shiftn = 'h040;
		5'h04: shiftn = 'h080;
		5'h08: shiftn = 'h100;
		5'h10: shiftn = 'h200;
		default: shiftn = 1;
	endcase
	if (shiftn == 1) begin
		AssertGenericException(`CP0_EX_MACHCHK);
	end
	else if (couldHandleInterrupt() && int_req > ipl) begin
		AssertInterruptException(32'h200 + int_req << shiftn);
	end
endfunction

function void HandleInterrupt;
	if (isEICMode())
		HandleInterruptEICMode();
	else if (isVectoredMode())
		HandleInterruptVectoredMode();
	else
		HandleInterruptCompatibilityMode();
endfunction

/********** Timer **********/
function void UpdateTimer;
	automatic bit writing = cmd_valid == 1 && cmd_op == `CP0_CMD_WRITEREG;
	automatic bit writingcount = writing && cmd_no == 9 && cmd_sel == 0;
	automatic bit writingcomp = writing && cmd_no == 11 && cmd_sel == 0;
	if (writingcomp) begin
		intr_timer = 0;
	end
	else begin
		if (reg_count == reg_compare)
			intr_timer = 1;
	end
	if (!writingcount)
		reg_count = reg_count + 1;
endfunction

/********** Exception Handler **********/
function void HandleException;
	automatic bit mchk = 0;
	if (exr_valid) begin
		case (exr_type)
			`CP0_EX_IF_BUSERR,
				`CP0_EX_BUSERR,
				`CP0_EX_SYSCALL,
				`CP0_EX_BREAK,
				`CP0_EX_RESERVED,
				`CP0_EX_OVERFLOW,
				`CP0_EX_TRAP: begin
				AssertGenericException(exr_type[4:0]);
			end
			`CP0_EX_MEM_WRITE,
				`CP0_EX_IF_ADDRERR,
				`CP0_EX_MEM_AEL,
				`CP0_EX_MEM_AES,
				`CP0_EX_MEM_RI,
				`CP0_EX_IF_TLBXI,
				`CP0_EX_IF_TLBINV,
				`CP0_EX_MEM_TLBIL,
				`CP0_EX_MEM_TLBIS: begin
				AssertGeneralMemoryException(exr_type[4:0], exr_a0);
			end
			`CP0_EX_IF_TLBMISS,
				`CP0_EX_MEM_TLBML,
				`CP0_EX_MEM_TLBMS: begin
				AssertTLBRefillException(exr_type[4:0], exr_a0);
			end
			`CP0_EX_ERET: begin
				AssertExceptionReturn();
			end
			default: begin
				AssertGenericException(`CP0_EX_MACHCHK);
				mchk = 1;
			end
		endcase
	end
	if (mchk == 0)
		HandleInterrupt();
endfunction

/********** TLB **********/
bit [$clog2(CONFIG_TLB_ENTRIES) - 1:0] tlb_r_index;
bit tlb_r_ready;
TLBEntry tlb_r_resp;
bit tlb_w_valid;
bit [$clog2(CONFIG_TLB_ENTRIES) - 1:0] tlb_w_index;
TLBEntry tlb_w_data;
bit tlb_w_ready;
bit [18:0] tlb_p_ivpn2;
bit [7:0] tlb_p_iasid;
bit tlb_p_valid;
bit tlb_p_ready;
bit [$clog2(CONFIG_TLB_ENTRIES) - 1:0] tlb_p_index;
TLBEntry tlb_p_resp;
bit tlb_p_miss;
/*
MIPS32r2_TLB #(
	.NUM_ENTRIES(CONFIG_TLB_ENTRIES),
	.GROUP_SIZE(CONFIG_TLB_GROUP_SIZE),
	.I_CACHE_SIZE(CONFIG_TLB_I_CACHE_SIZE),
	.D_CACHE_SIZE(CONFIG_TLB_D_CACHE_SIZE)
) tlb (
	.clock(clock),
	.reset(reset),
	.config_k0(reg_kseg0attr == Cachable),
	.r_index(tlb_r_index),
	.r_ready(tlb_r_ready),
	.r_resp(tlb_r_resp),
	.w_valid(tlb_w_valid),
	.w_index(tlb_w_index),
	.w_data(tlb_w_data),
	.w_ready(tlb_w_ready),
	.p_ivpn2(tlb_p_ivpn2),
	.p_iasid(tlb_p_iasid),
	.p_valid(tlb_p_valid),
	.p_ready(tlb_p_ready),
	.p_index(tlb_p_index),
	.p_resp(tlb_p_resp),
	.p_miss(tlb_p_miss),
	.qi_valid(tlbi_valid),
	.qi_asid(reg_asid),
	.qi_vaddr(tlbi_vaddr),
	.qi_ready(tlbi_ready),
	.qi_miss(tlbi_miss),
	.qi_paddr(tlbi_paddr),
	.qi_ri(tlbi_ri),
	.qi_xi(tlbi_xi),
	.qi_d(tlbi_d),
	.qi_c(tlbi_c),
	.qi_v(tlbi_v),
	.qi_kern(tlbi_kern),
	.qd_valid(tlbd_valid),
	.qd_asid(reg_asid),
	.qd_vaddr(tlbd_vaddr),
	.qd_ready(tlbd_ready),
	.qd_miss(tlbd_miss),
	.qd_paddr(tlbd_paddr),
	.qd_ri(tlbd_ri),
	.qd_xi(tlbd_xi),
	.qd_d(tlbd_d),
	.qd_c(tlbd_c),
	.qd_v(tlbd_v),
	.qd_kern(tlbd_kern)
);
*/
/********** Utilities **********/
function bit isInKernelMode;
	return reg_status_um == 0 || reg_status_exl == 1 || reg_status_erl == 1;
endfunction

/********** Commands **********/
function void CMDFail(input Word resp);
	cmd_resp = resp;
	cmd_error = 1;
endfunction

function void CMDSucceed(input Word resp);
	cmd_resp = resp;
	cmd_error = 0;
endfunction

function Word ReadRegister(input bit [4:0] no, input bit [2:0] sel);
	casez ({ no, 1'b0, sel })
		/* Index */
		9'h000: return reg_probe << 31 | reg_index;
		/* Random */
		9'h010: return ReadRandom();
		/* EntryLo0 */
		9'h020: return { reg_lo0_pfn,
			Cacheability2Bits(reg_lo0_cacheattr), reg_lo0_dirty,
			reg_lo0_valid, reg_lo0_global }
			| reg_lo0_ri << 31 | reg_lo0_xi << 30;
		/* EntryLo1 */
		9'h030: return { reg_lo1_pfn,
			Cacheability2Bits(reg_lo1_cacheattr), reg_lo1_dirty,
			reg_lo1_valid, reg_lo1_global }
			| reg_lo1_ri << 31 | reg_lo1_xi << 30;
		/* Context */
		9'h040: return { reg_ptebase, reg_badvpn2, 4'b0000 };
		/* PageMask */
		9'h050: return PageSize2Bits(reg_pagesize);
		/* Wired */
		9'h060: return reg_wired;
		/* HWREna */
		9'h070: /* TODO */;
		/* BadVAddr */
		9'h080: return reg_badvaddr;
		/* Count */
		9'h090: return reg_count;
		/* EntryHi */
		9'h0a0: return { reg_vpn2, 5'b00000, reg_asid };
		/* Compare */
		9'h0b0: return reg_compare;
		/* Status */
		9'h0c0: return { reg_status_cu, 1'b0, reg_status_fr, 3'b000,
			reg_status_bev, reg_status_ts, reg_status_sr,
			reg_status_nmi, 3'b000, reg_status_im, 3'b000,
			reg_status_um, 1'b0, reg_status_erl, reg_status_exl,
			reg_status_ie };
		/* IntCtl */
		9'h0c1: return { reg_ipti, 19'b0, reg_vs, 5'b0 };
		/* SRSCtl */
		9'h0c2: return 0;
		/* Cause */
		9'h0d0: return { reg_cause_bd, reg_cause_ti, reg_cause_ce,
			reg_cause_dc, 3'b000, reg_cause_iv, reg_cause_wp,
			reg_cause_fdci, 5'b00000, reg_cause_ip[7:2], intr_soft, 1'b0,
			reg_cause_exccode, 2'b00 };
		/* EPC */
		9'h0e0: return reg_epc;
		/* PRId */
		9'h0f0: return 0;
		/* Ebase */
		9'h0f1: return { reg_ebase, 2'b00, 10'(CONFIG_CPU_INDEX) };
		/* Config */
		9'h100: return 32'b1_000_000_000000000_0_00_000_001_000_0_000 | Cacheability2Bits(reg_kseg0attr);
		/* Config1 */
		9'h101: return { 1'b1_, 6'(CONFIG_TLB_ENTRIES), 25'b011_011_011_011_011_011_0_0_0_0_0_0_0 };
		/* Config2 */
		9'h102: return 32'h80000000;
		/* Config3 */
		9'h103: return { 25'b1_0_0_0_0_0_0_0_0_00_00_0_0_0_0_0_0_0_0_0_0, CONFIG_HASEIC, 6'b1_0_0_0_0_0 };
		/* Config4 */
		9'h104: return 32'b1_00_0_0000_11111111_0000000000000000;
		/* Config5 */
		9'h105: return 0;
		/* ErrorEPC */
		9'h1e0: return reg_errorepc;
		/* Kscratchn */
		9'b111110???: return reg_kscratch[sel];
	endcase
endfunction

function void WriteRegister(input bit [4:0] no, input bit [2:0] sel, input Word data);
	case ({ no, 1'b0, sel })
		/* Index */
		9'h000: begin
			reg_index = data[30:0];
		end
		/* EntryLo0 */
		9'h020: begin
			reg_lo0_ri = data[31];
			reg_lo0_xi = data[30];
			reg_lo0_pfn = data[29:6];
			reg_lo0_cacheattr = Bits2Cacheability(data[5:3]);
			reg_lo0_dirty = data[2];
			reg_lo0_valid = data[1];
			reg_lo0_global = data[0];
		end
		/* EntryLo1 */
		9'h030: begin
			reg_lo1_ri = data[31];
			reg_lo1_xi = data[30];
			reg_lo1_pfn = data[29:6];
			reg_lo1_cacheattr = Bits2Cacheability(data[5:3]);
			reg_lo1_dirty = data[2];
			reg_lo1_valid = data[1];
			reg_lo1_global = data[0];
		end
		/* Context */
		9'h040: begin
			reg_ptebase = data[31:23];
		end
		/* PageMask */
		9'h050: begin
			reg_pagesize = Bits2PageSize(data);
		end
		/* Wired */
		9'h060: begin
			reg_wired = data;
		end
		/* HWREna */
		9'h070: /* TODO */;
		/* Count */
		9'h090: begin
			reg_count = data;
		end
		/* EntryHi */
		9'h0a0: begin
			reg_vpn2 = data[31:13];
			reg_asid = data[7:0];
		end
		/* Compare */
		9'h0b0: begin
			reg_compare = data;
		end
		/* Status */
		9'h0c0: begin
			reg_status_cu = data[31:28];
			reg_status_fr = data[26];
			reg_status_bev = data[22];
			reg_status_ts = data[21];
			reg_status_sr = data[20];
			reg_status_nmi = data[19];
			reg_status_im = data[15:8];
			reg_status_um = data[4];
			reg_status_erl = data[2];
			reg_status_exl = data[1];
			reg_status_ie = data[0];
		end
		/* IntCtl */
		9'h0c1: begin
			reg_vs = data[9:5];
		end
		/* Cause */
		9'h0d0: begin
			reg_cause_dc = data[27];
			if (!CONFIG_INTERRUPT_COMPAT_ONLY)
				reg_cause_iv = data[23];
			reg_cause_wp = data[22];
			intr_soft = data[9:8];
		end
		/* EPC */
		9'h0e0: begin
			reg_epc = data;
		end
		/* Ebase */
		9'h0f1: begin
			reg_ebase = { 2'b10, data[29:12] };
		end
		/* Config */
		9'h100: begin
			reg_kseg0attr = Bits2Cacheability(data[2:0]);
		end
		/* ErrorEPC */
		9'h1e0: begin
			reg_errorepc = data;
		end
		/* Kscratchn */
		9'h1f?: begin
			reg_kscratch[sel] = data;
		end
	endcase
endfunction

function void CMDDisableInterrupt;
	if (!isInKernelMode()) begin
		CMDFail(`CP0_EX_CPUNUSABLE);
	end
	else begin
		automatic Word ret = ReadRegister(12, 0);
		reg_status_ie = 0;
		CMDSucceed(ret);
	end
endfunction

function void CMDEnableInterrupt;
	if (!isInKernelMode()) begin
		CMDFail(`CP0_EX_CPUNUSABLE);
	end
	else begin
		automatic Word ret = ReadRegister(12, 0);
		reg_status_ie = 1;
		CMDSucceed(ret);
	end
endfunction

function void CMDCheckPriv;
	CMDSucceed(!isInKernelMode());
endfunction

function void CMDTLBProbe;
	if (!isInKernelMode()) begin
		CMDFail(`CP0_EX_CPUNUSABLE);
	end
	else begin
		if (!tlb_p_valid) begin
			tlb_p_valid = 1;
			tlb_p_ivpn2 = reg_vpn2;
			tlb_p_iasid = reg_asid;
			//CMDStall(); async
		end
		else begin
			if (tlb_p_ready) begin
				tlb_p_valid = 0;
				if (tlb_p_miss) begin
					reg_probe = 1;
				end
				else begin
					reg_probe = 0;
					reg_index = tlb_p_index;
				end
				CMDSucceed(0);
			end
			else begin
				//CMDStall();
			end
		end
	end
endfunction

function void CMDTLBRead;
	if (!isInKernelMode()) begin
		CMDFail(`CP0_EX_CPUNUSABLE);
	end
	else begin
		if (tlb_r_index != reg_index) begin
			tlb_r_index = reg_index;
			//CMDStall();
		end
		else begin
			if (tlb_r_ready) begin
				reg_lo0_pfn = tlb_r_resp.pfn0;
				reg_lo0_cacheattr = tlb_r_resp.c0 == 1 ? Cachable : Uncached;
				reg_lo0_ri = tlb_r_resp.ri0;
				reg_lo0_xi = tlb_r_resp.xi0;
				reg_lo0_dirty = tlb_r_resp.d0;
				reg_lo0_valid = tlb_r_resp.v0;
				reg_lo0_global = tlb_r_resp.g;
				reg_lo1_pfn = tlb_r_resp.pfn1;
				reg_lo1_cacheattr = tlb_r_resp.c1 == 1 ? Cachable : Uncached;
				reg_lo1_ri = tlb_r_resp.ri1;
				reg_lo1_xi = tlb_r_resp.xi1;
				reg_lo1_dirty = tlb_r_resp.d1;
				reg_lo1_valid = tlb_r_resp.v1;
				reg_lo1_global = tlb_r_resp.g;
				reg_pagesize = tlb_r_resp.ps;
				reg_vpn2 = tlb_r_resp.vpn2;
				reg_asid = tlb_r_resp.asid;
				CMDSucceed(0);
			end
			else begin
				//CMDStall();
			end
		end
	end
endfunction

function void TLBWrite(input int index);
	if (!isInKernelMode()) begin
		CMDFail(`CP0_EX_CPUNUSABLE);
	end
	else begin
		if (!tlb_w_valid) begin
			tlb_w_valid = 1;
			tlb_w_index = reg_index;
			tlb_w_data.pfn0 = reg_lo0_pfn;
			tlb_w_data.c0 = reg_lo0_cacheattr == Cachable;
			tlb_w_data.ri0 = reg_lo0_ri;
			tlb_w_data.xi0 = reg_lo0_xi;
			tlb_w_data.d0 = reg_lo0_dirty;
			tlb_w_data.v0 = reg_lo0_valid;
			tlb_w_data.pfn1 = reg_lo1_pfn;
			tlb_w_data.c1 = reg_lo1_cacheattr == Cachable;
			tlb_w_data.ri1 = reg_lo1_ri;
			tlb_w_data.xi1 = reg_lo1_xi;
			tlb_w_data.d1 = reg_lo1_dirty;
			tlb_w_data.v1 = reg_lo1_valid;
			tlb_w_data.g = reg_lo0_global && reg_lo1_global;
			tlb_w_data.ps = reg_pagesize;
			tlb_w_data.vpn2 = reg_vpn2;
			tlb_w_data.asid = reg_asid;
			//CMDStall();
		end
		else begin
			if (tlb_w_ready) begin
				tlb_w_valid = 0;
				CMDSucceed(0);
			end
			else begin
				//CMDStall();
			end
		end
	end
endfunction

assign o_cmd_stall = cmd_stall;

always_comb begin
	cmd_stall = 0;
	if (cmd_valid && cmd_op == `CP0_CMD_TLBPROBE && isInKernelMode()) begin
		if (!tlb_p_valid)
			cmd_stall = 1;
		else if (!tlb_p_ready)
			cmd_stall = 1;
	end
	if (cmd_valid && cmd_op == `CP0_CMD_TLBREAD && isInKernelMode()) begin
		if (tlb_r_index != reg_index)
			cmd_stall = 1;
		else if (!tlb_r_ready)
			cmd_stall = 1;
	end
	if (cmd_valid && (cmd_op == `CP0_CMD_TLBWI || cmd_op == `CP0_CMD_TLBWR) && isInKernelMode()) begin
		if (!tlb_w_valid)
			cmd_stall = 1;
		else if (!tlb_w_ready)
			cmd_stall = 1;
	end
end

function void CMDTLBWriteIndexed;
	TLBWrite(reg_index);
endfunction

function void CMDTLBWriteRandom;
	TLBWrite(ReadRandom());
endfunction

function void CMDCacheInvalidate;
	/* TODO */
	CMDSucceed(0);
endfunction

function void CMDCacheSync;
	/* TODO */
	CMDSucceed(0);
endfunction

function void CMDReadReg;
	if (!isInKernelMode()) begin
		CMDFail(`CP0_EX_CPUNUSABLE);
	end
	else
		CMDSucceed(ReadRegister(cmd_no, cmd_sel));
endfunction

function void CMDWriteReg;
	if (!isInKernelMode()) begin
		CMDFail(`CP0_EX_CPUNUSABLE);
	end
	else begin
		WriteRegister(cmd_no, cmd_sel, cmd_data);
		CMDSucceed(0);
	end
endfunction

always_comb is_kernel = isInKernelMode();

bit hardResetPending;

always @(`SENSITIVITY)
begin
	/* Control logic */
	if (reset) begin
		hardResetPending = 1;
		o_pl_reset <= 1;
	end
	else begin
		if (isExceptionAsserted())
			DeassertException();
		UpdateTimer();
		if (hardResetPending) begin
			AssertReset();
			hardResetPending = 0;
		end
		else if (int_reset) begin
			AssertSoftReset();
		end
		else if (int_nmi) begin
			AssertNMI();
		end
		else begin
			HandleException();
            reg_cause_ip[1:0] <= intr_soft;
			if (!isExceptionAsserted() && cmd_valid == 1) begin
				case (cmd_op)
					`CP0_CMD_READREG: CMDReadReg();
					`CP0_CMD_WRITEREG: CMDWriteReg();
					`CP0_CMD_DI: CMDDisableInterrupt();
					`CP0_CMD_EI: CMDEnableInterrupt();
					`CP0_CMD_TLBPROBE: CMDTLBProbe();
					`CP0_CMD_TLBREAD: CMDTLBRead();
					`CP0_CMD_TLBWI: CMDTLBWriteIndexed();
					`CP0_CMD_TLBWR: CMDTLBWriteRandom();
					`CP0_CMD_CINVL: CMDCacheInvalidate();
					`CP0_CMD_CSYNC: CMDCacheSync();
					`CP0_CMD_CHKPRIV: CMDCheckPriv();
				endcase
			end
		end
		/* Update output */
		o_cmd_resp <= cmd_resp;
		o_cmd_error <= cmd_error;
		o_pl_reset <= pl_reset;
		o_pl_flush <= pl_flush;
		o_pl_rv <= pl_rv;
		o_intr_timer <= intr_timer;
	end
end
assign o_intr_soft = reg_cause_ip[1:0];
endmodule