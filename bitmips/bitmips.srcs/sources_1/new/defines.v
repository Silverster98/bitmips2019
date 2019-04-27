// 通用
`define RST_ENABLE     1'b1
`define RST_DISABLE    1'b0
`define STOP           1'b1           // 流水线阻塞
`define NOSTOP         1'b0           // 流水线不阻塞
`define BRANCH_ENABLE  1'b1           // 发生分支
`define BRANCH_DISABLE 1'b0           // 不发生分支
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
`define EXCEPTION_OFF  1'b0           // 无异常发生
`define EXCEP_TYPE_BUS 31:0
`define EXCEP_TYPE_WIDTH 32