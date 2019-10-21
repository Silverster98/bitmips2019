`include "defines.v"
module pc_pre(
    input wire clk,
    input wire rst,
    input wire[31:0] pre_pc,
    input wire[31:0] pre_exception_type,
    input wire stall,
    input wire flush,
    
    output reg[31:0] if_pc,
    output reg[31:0] if_exception_type
    );
    
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE || flush == 1'b1) begin
            if_pc <= 32'h00000000;
            if_exception_type <= 32'h00000000;
        end else begin
            if (stall == `NOSTOP) begin
                if_pc <= pre_pc;
                if_exception_type <= pre_exception_type;
            end
        end
    end
endmodule
