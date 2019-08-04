// common
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

//cache
`define addr_tag       536:513
`define dirty_bit      513
`define addr0   	    512:481
`define addr1   		480:449
`define addr2   		448:417
`define addr3   		416:385
`define addr4   		384:353
`define addr5   		352:321
`define addr6   		320:289
`define addr7   		288:257
`define addr8   		256:225
`define addr9   		224:193
`define addr10  		 192:161
`define addr11  		 160:129
`define addr12  		 128:97
`define addr13  		 96:65
`define addr14  		 64:33
`define addr15  		 32:1
`define addr_byte3_0   512:505
`define addr_byte3_1   480:473
`define addr_byte3_2   448:441
`define addr_byte3_3   416:409
`define addr_byte3_4   384:377
`define addr_byte3_5   352:345
`define addr_byte3_6   320:313
`define addr_byte3_7   288:281
`define addr_byte3_8   256:249
`define addr_byte3_9   224:217
`define addr_byte3_10   192:185
`define addr_byte3_11   160:153
`define addr_byte3_12   128:121
`define addr_byte3_13   96:89
`define addr_byte3_14   64:57
`define addr_byte3_15   32:25
`define addr_byte2_0   504:497
`define addr_byte2_1   472:465
`define addr_byte2_2   440:433
`define addr_byte2_3   408:401
`define addr_byte2_4   376:369
`define addr_byte2_5   344:337
`define addr_byte2_6   312:305
`define addr_byte2_7   280:273
`define addr_byte2_8   248:241
`define addr_byte2_9   216:209
`define addr_byte2_10   184:177
`define addr_byte2_11   152:145
`define addr_byte2_12   120:113
`define addr_byte2_13   88:81
`define addr_byte2_14   56:49
`define addr_byte2_15   24:17
`define addr_byte1_0   496:489
`define addr_byte1_1   464:457
`define addr_byte1_2   432:425
`define addr_byte1_3   400:393
`define addr_byte1_4   368:361
`define addr_byte1_5   336:329
`define addr_byte1_6   304:297
`define addr_byte1_7   272:265
`define addr_byte1_8   240:233
`define addr_byte1_9   208:201
`define addr_byte1_10   176:169
`define addr_byte1_11   144:137
`define addr_byte1_12   112:105
`define addr_byte1_13   80:73
`define addr_byte1_14   48:41
`define addr_byte1_15   16:9
`define addr_byte0_0   488:481
`define addr_byte0_1   456:449
`define addr_byte0_2   424:417
`define addr_byte0_3   392:385
`define addr_byte0_4   360:353
`define addr_byte0_5   328:321
`define addr_byte0_6   296:289
`define addr_byte0_7   264:257
`define addr_byte0_8   232:225
`define addr_byte0_9   200:193
`define addr_byte0_10   168:161
`define addr_byte0_11   136:129
`define addr_byte0_12   104:97
`define addr_byte0_13   72:65
`define addr_byte0_14   40:33
`define addr_byte0_15   8:1

