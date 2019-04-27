// 通用
`define RST_ENABLE     1'b1
`define RST_DISABLE    1'b0
`define STOP           1'b1           // 流水线阻�?
`define NOSTOP         1'b0           // 流水线不阻塞
`define BRANCH_ENABLE  1'b1           // 发生分支
`define BRANCH_DISABLE 1'b0           // 不发生分�?
`define ZEROWORD32     32'h00000000
`define ZEROWORD5      5'b00000

// aluop
`define ALUOP_BUS      5:0
`define ALUOP_WIDTH    6

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

// exception
`define EXCEPTION_ON   1'b1           // 发生异常
`define EXCEPTION_OFF  1'b0           // 无异常发�?
`define EXCEP_TYPE_BUS 31:0
`define EXCEP_TYPE_WIDTH 32

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
`define ALUOP_AND     8'b00000000
`define ALUOP_SLLV    8'b00000001
`define ALUOP_MFHI    8'b00000010
`define ALUOP_MTHI    8'b00000011
`define ALUOP_JR      8'b00000100
`define ALUOP_SYSCALL 8'b00000101
`define ALUOP_BREAK   8'b00000110
`define ALUOP_BGEZ    8'b00000111
`define ALUOP_J       8'b00001000
`define ALUOP_JAL     8'b00001001  
`define ALUOP_BEQ     8'b00001010
`define ALUOP_LW      8'b00001011
`define ALUOP_SW      8'b00001100
`define ALUOP_ADDI    8'b00001101
`define ALUOP_SLT     8'b00001110
`define ALUOP_SLL     8'b00001111
`define ALUOP_ERET    8'b00010000