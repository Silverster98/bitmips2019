// reset
`define RST_ENABLE  1'b0
`define RST_DISABLE 1'b1


// tlb
`define VPN2        89:71
`define ASID        70:63
`define PAGEMASK    62:51
`define G           50
`define PFN0        49:30
`define C0          29:27
`define D0          26
`define V0          25
`define PFN1        24:5
`define C1          4:2
`define D1          1
`define V1          0

// decode
// special, type R
`define ID_SPECIAL 6'b000000
`define ID_AND     6'b100100
`define ID_ADD     6'b100000
`define ID_ADDU    6'b100001
`define ID_NOR     6'b100111
`define ID_OR      6'b100101
`define ID_XOR     6'b100110
`define ID_SLL     6'b000000
`define ID_SLLV    6'b000100
`define ID_SRL     6'b000010
`define ID_SRLV    6'b000110
`define ID_SRA     6'b000011
`define ID_SRAV    6'b000111
`define ID_SLT     6'b101010
`define ID_SLTU    6'b101011
`define ID_SUB     6'b100010
`define ID_SUBU    6'b100011
`define ID_MULT    6'b011000
`define ID_MULTU   6'b011001
`define ID_DIV     6'b011010
`define ID_DIVU    6'b011011
`define ID_JALR    6'b001001
`define ID_JR      6'b001000
`define ID_SYSCALL 6'b001100
`define ID_BREAK   6'b001101
`define ID_MFHI    6'b010000
`define ID_MTHI    6'b010001
`define ID_MFLO    6'b010010
`define ID_MTLO    6'b010011
`define ID_TEQ     6'b110100
`define ID_TGE     6'b110000
`define ID_TGEU    6'b110001
`define ID_TLT     6'b110010
`define ID_TLTU    6'b110011
`define ID_TNE     6'b110110
`define ID_MOVN    6'b001011
`define ID_MOVZ    6'b001010
`define ID_NOP     32'b00000000_00000000_00000000_00000000
// type I
`define ID_ADDI    6'b001000
`define ID_ADDIU   6'b001001
`define ID_ANDI    6'b001100
`define ID_ORI     6'b001101
`define ID_XORI    6'b001110
`define ID_LUI     6'b001111
`define ID_SLTI    6'b001010
`define ID_SLTIU   6'b001011
`define ID_BEQ     6'b000100
`define ID_BNE     6'b000101
`define ID_BGTZ    6'b000111
`define ID_BLEZ    6'b000110
`define ID_LB      6'b100000
`define ID_LBU     6'b100100
`define ID_LH      6'b100001
`define ID_LHU     6'b100101
`define ID_LW      6'b100011
`define ID_SB      6'b101000
`define ID_SH      6'b101001
`define ID_SW      6'b101011
`define ID_LWL     6'b100010
`define ID_LWR     6'b100110
`define ID_SWL     6'b101010
`define ID_SWR     6'b101110
`define ID_LL      6'b110000
`define ID_SC      6'b111000
// special2
`define ID_SPECIAL2 6'b011100
`define ID_CLO     6'b100001
`define ID_CLZ     6'b100000
// type J
`define ID_J       6'b000010
`define ID_JAL     6'b000011
// REGIMM, according to rt value
`define ID_REGIMM  6'b000001
`define ID_BGEZ    5'b00001
`define ID_BGEZAL  5'b10001
`define ID_BLTZ    5'b00000
`define ID_BLTZAL  5'b10000
`define ID_TEQI    5'b01100
`define ID_TGEI    5'b01000
`define ID_TGEIU   5'b01001
`define ID_TLTI    5'b01010
`define ID_TLTIU   5'b01011
`define ID_TNEI    5'b01110
// COP0
`define ID_COP0    6'b010000
`define ID_MFC0    5'b00000
`define ID_MTC0    5'b00100
`define ID_ERET    32'b01000010_00000000_00000000_00011000
`define ID_TLBP    32'b01000010_00000000_00000000_00001000
`define ID_TLBR    32'b01000010_00000000_00000000_00000001
`define ID_TLBWI   32'b01000010_00000000_00000000_00000010
`define ID_TLBWR   32'b01000010_00000000_00000000_00000110

// alu op
`define ALUOP_ADD     8'b00000000
`define ALUOP_ADDI    8'b00000001
`define ALUOP_ADDU    8'b00000010
`define ALUOP_ADDIU   8'b00000011
`define ALUOP_SUB     8'b00000100
`define ALUOP_SUBU    8'b00000101
`define ALUOP_SLT     8'b00000110
`define ALUOP_SLTI    8'b00000111
`define ALUOP_SLTU    8'b00001000
`define ALUOP_SLTIU   8'b00001001  
`define ALUOP_DIV     8'b00001010
`define ALUOP_DIVU    8'b00001011
`define ALUOP_MULT    8'b00001100
`define ALUOP_MULTU   8'b00001101
`define ALUOP_AND     8'b00001110
`define ALUOP_ANDI    8'b00001111
`define ALUOP_LUI     8'b00010000
`define ALUOP_NOR     8'b00010001
`define ALUOP_OR      8'b00010010
`define ALUOP_ORI     8'b00010011
`define ALUOP_XOR     8'b00010100
`define ALUOP_XORI    8'b00010101
`define ALUOP_SLLV    8'b00010110
`define ALUOP_SLL     8'b00010111
`define ALUOP_SRAV    8'b00011000
`define ALUOP_SRA     8'b00011001
`define ALUOP_SRLV    8'b00011010
`define ALUOP_SRL     8'b00011011
`define ALUOP_BEQ     8'b00011100
`define ALUOP_BNE     8'b00011101
`define ALUOP_BGEZ    8'b00011110
`define ALUOP_BGTZ    8'b00011111
`define ALUOP_BLEZ    8'b00100000
`define ALUOP_BGEZAL  8'b00100001
`define ALUOP_BLTZAL  8'b00100010
`define ALUOP_J       8'b00100011
`define ALUOP_JAL     8'b00100100
`define ALUOP_JR      8'b00100101
`define ALUOP_JALR    8'b00100110
`define ALUOP_MFHI    8'b00100111
`define ALUOP_MFLO    8'b00101000
`define ALUOP_MTHI    8'b00101001
`define ALUOP_MTLO    8'b00101010
`define ALUOP_BREAK   8'b00101011
`define ALUOP_SYSCALL 8'b00101100
`define ALUOP_LB      8'b00101101
`define ALUOP_LBU     8'b00101110
`define ALUOP_LH      8'b00101111
`define ALUOP_LHU     8'b00110000
`define ALUOP_LW      8'b00110001
`define ALUOP_SB      8'b00110010
`define ALUOP_SH      8'b00110011
`define ALUOP_SW      8'b00110100
`define ALUOP_ERET    8'b00110101
`define ALUOP_MFC0    8'b00110110
`define ALUOP_MTC0    8'b00110111
`define ALUOP_BLTZ    8'b00111000
`define ALUOP_MOVN    8'b00111001
`define ALUOP_MOVZ    8'b00111010
`define ALUOP_CLO     8'b00111011
`define ALUOP_CLZ     8'b00111100
`define ALUOP_TEQ     8'b00111101
`define ALUOP_TGE     8'b00111110
`define ALUOP_TGEU    8'b00111111
`define ALUOP_TLT     8'b01000000
`define ALUOP_TLTU    8'b01000001
`define ALUOP_TNE     8'b01000010
`define ALUOP_TEQI    8'b01000011
`define ALUOP_TGEI    8'b01000100
`define ALUOP_TGEIU   8'b01000101
`define ALUOP_TLTI    8'b01000110
`define ALUOP_TLTIU   8'b01000111
`define ALUOP_TNEI    8'b01001000
`define ALUOP_LWL     8'b01001001
`define ALUOP_LWR     8'b01001010
`define ALUOP_SWL     8'b01001011
`define ALUOP_SWR     8'b01001100
`define ALUOP_LL      8'b01001101
`define ALUOP_SC      8'b01001110
`define ALUOP_TLBP    8'b01001111
`define ALUOP_TLBR    8'b01010000
`define ALUOP_TLBWI   8'b01010001
`define ALUOP_TLBWR   8'b01010010
`define ALUOP_NOP     8'b11111110
`define ALUOP_RI      8'b11111111


// exception
`define EXCEP_CODE_INT  5'h0          // interrupt
`define EXCEP_CODE_ADEL 5'h4          // pc fetch or lw addr error
`define EXCEP_CODE_ADES 5'h5          // sw addr 
`define EXCEP_CODE_SYS  5'h8          // syscall
`define EXCEP_CODE_BP   5'h9          // break point
`define EXCEP_CODE_RI   5'ha          // reserved instr
`define EXCEP_CODE_OV   5'hc          // overflow      
`define EXCEP_CODE_TR   5'hd          // trap
`define EXCEP_CODE_ERET 5'h1f         // eret treated as exception
`define EXCEP_CODE_TLBL 5'h2          // tlbl, refill bfc00200, invalid bfc00380
`define EXCEP_CODE_TLBS 5'h3          // tlbs, refill bfc00200, invalid bfc00380
`define EXCEP_CODE_MOD  5'b1          // modified
