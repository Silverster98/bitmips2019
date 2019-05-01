`ifndef MIPS32R2_CP0TYPES_SVH
`define MIPS32R2_CP0TYPES_SVH

typedef bit [31:0] Word;
typedef Word Address;
typedef bit [7:0] ASIDType;
typedef int TLBEntryIndex;
typedef bit [19:0] PageFrameIndex;
typedef bit [18:0] PageFrameIndexHalf;

typedef enum {
	Cachable,
	Uncached
} Cacheability;

function bit [2:0] Cacheability2Bits(Cacheability c);
	if (c == Cachable)
		return 3;
	return 2;
endfunction

function Cacheability Bits2Cacheability(input bit [3:0] c);
	if (c == 3)
		return Cachable;
	return Uncached;
endfunction

typedef enum {
	PS4K,
	PS16K,
	PS64K
} PageSize;

function bit [31:0] PageSize2Bits(input PageSize s);
	case (s)
		PS16K: return 32'b00000000_00000000_01111000_00000000;
		PS64K: return 32'b00000000_00000001_11111000_00000000;
		PS4K:  return 32'b00000000_00000000_00011000_00000000;
		default: return 32'b00000000_00000000_00011000_00000000;
	endcase
endfunction

function PageSize Bits2PageSize(input bit [31:0] s);
	case (s)
		32'b00000000_00000000_01111000_00000000: return PS16K;
		32'b00000000_00000001_11111000_00000000: return PS64K;
		32'b00000000_00000000_00011000_00000000: return PS4K;
		default: return PS4K;
	endcase
endfunction

`endif
