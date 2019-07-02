// common
`define SRAM           1'b1

`define RST_ENABLE     1'b0
`define RST_DISABLE    1'b1
`define STOP           1'b1           // stop
`define NOSTOP         1'b0           // no stop
`define BRANCH_ENABLE  1'b1           // branch
`define BRANCH_DISABLE 1'b0           // no branch
`define ZEROWORD32     32'h00000000
`define ZEROWORD5      5'b00000

// aluop
`define ALUOP_BUS      7:0
`define ALUOP_WIDTH    8

// instruction
`define INST_ADDR_BUS  31:0
`define INST_BUS       31:0
`define INST_WIDTH     32

// GPR
`define GPR_BUS        31:0
`define GPR_ADDR_BUS   4:0
`define GPR_WIDTH      32

// cp0
`define CP0_BUS        31:0
`define CP0_ADDR_BUS   4:0
`define CP0_WIDTH      32

//cause reg
`define EXL             1
`define ERL             2
`define BD              31
`define IP7             15
`define IP6             14
`define IP5             13
`define IP4             12
`define IP3             11
`define IP2             10
`define IP1             9

// status reg
`define IM7             15
`define IM6             14
`define IM5             13
`define IM4             12
`define IM3             11
`define IM2             10
`define IM1             9


// exception
`define EXCEPTION_ON   1'b1           // exception
`define EXCEPTION_OFF  1'b0           // no exception
`define EXCEP_TYPE_BUS 31:0
`define EXCEP_CODE_BUS 4:0
`define EXCEP_TYPE_WIDTH 32

`define EXCEP_CODE_INT  5'h0          // interrupt
`define EXCEP_CODE_ADEL 5'h4          // pc fetch or lw addr error
`define EXCEP_CODE_ADES 5'h5          // sw addr 
`define EXCEP_CODE_SYS  5'h8          // syscall
`define EXCEP_CODE_BP   5'h9          // break point
`define EXCEP_CODE_RI   5'ha          // reserved instr
`define EXCEP_CODE_OV   5'hc          // overflow      
`define EXCEP_CODE_TR   5'hd          // trap
`define EXCEP_CODE_ERET 5'h1f         // eret treated as exception

// ram
`define RAM_ADDR_BUS   31:0
`define RAM_ADDR_WIDTH 32

// ID select
`define ID_AND     6'b100100
`define ID_OR      6'b100101
`define ID_XOR     6'b100110
`define ID_NOR     6'b100111
`define ID_ANDI    6'b001100
`define ID_ORI     6'b001101
`define ID_XORI    6'b001110
`define ID_LUI     6'b001111
`define ID_SLL     6'b000000
`define ID_SLLV    6'b000100
`define ID_SRL     6'b000010
`define ID_SRLV    6'b000110
`define ID_SRA     6'b000011
`define ID_SRAV    6'b000111
`define ID_SLT     6'b101010
`define ID_SLTU    6'b101011
`define ID_SLTI    6'b001010
`define ID_SLTIU   6'b001011   
`define ID_ADD     6'b100000
`define ID_ADDU    6'b100001
`define ID_SUB     6'b100010
`define ID_SUBU    6'b100011
`define ID_ADDI    6'b001000
`define ID_ADDIU   6'b001001
`define ID_MULT    6'b011000
`define ID_MULTU   6'b011001
`define ID_DIV     6'b011010
`define ID_DIVU    6'b011011
`define ID_J       6'b000010
`define ID_JAL     6'b000011
`define ID_JALR    6'b001001
`define ID_JR      6'b001000
`define ID_BEQ     6'b000100
`define ID_BGEZ    5'b00001
`define ID_BGEZAL  5'b10001
`define ID_BGTZ    6'b000111
`define ID_BLEZ    6'b000110
`define ID_BLTZ    5'b00000
`define ID_BLTZAL  5'b10000
`define ID_BNE     6'b000101
`define ID_LB      6'b100000
`define ID_LBU     6'b100100
`define ID_LH      6'b100001
`define ID_LHU     6'b100101
`define ID_LW      6'b100011
`define ID_SB      6'b101000
`define ID_SH      6'b101001
`define ID_SW      6'b101011
`define ID_SYSCALL 6'b001100
`define ID_BREAK   6'b001101
`define ID_MFHI    6'b010000
`define ID_MTHI    6'b010001
`define ID_MFLO    6'b010010
`define ID_MTLO    6'b010011
`define ID_ERET    32'b01000010000000000000000000011000
// EXE ALU select mapping
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


