`include "defines.v"

module if_id(
    input wire rst,
    input wire clk,
    input wire[`INST_ADDR_BUS] if_pc,
    input wire[`INST_BUS] if_instr,
    input wire exception,
    input wire stall,
    
    output reg[`INST_ADDR_BUS] id_pc,
    output reg[`INST_BUS] id_instr
    );
    
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE || exception == `EXCEPTION_ON) begin
            id_pc <= `ZEROWORD32;
            id_instr <= `ZEROWORD32;
        end else begin
            if (stall == `STOP) begin
                id_pc <= if_pc;
                id_instr <= if_instr;
            end
        end
    end
endmodule
