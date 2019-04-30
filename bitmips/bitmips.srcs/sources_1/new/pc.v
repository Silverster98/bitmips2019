`include "defines.v"

module pc(
    input wire rst,
    input wire clk,
    input wire stall,
    input wire exception,
    input wire[`INST_ADDR_BUS] exception_pc_i,
    input wire branch_enable_i,
    input wire[`INST_ADDR_BUS] branch_addr_i,
    
    output reg[`INST_ADDR_BUS] pc_o
//    output reg cs_o
    );
    
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE) begin
            pc_o <= `ZEROWORD32;
        end else begin
            if (exception == `EXCEPTION_ON) begin
                pc_o <= exception_pc_i;
            end else if (stall == `NOSTOP) begin
                if (branch_enable_i == `BRANCH_ENABLE) begin
                    pc_o <= branch_addr_i;
                end else begin
                    pc_o <= pc_o + 4;
                end
            end
        end
    end
endmodule
