`include "defines.v"
module pc(
input wire                    rst,
input wire                    clk,
input wire[3:0]               stall,
input wire                    exception,
input wire  [`INST_ADDR_BUS]  exception_pc_i,
input wire                    branch_enable_i,
input wire  [`INST_ADDR_BUS]  branch_addr_i,

output wire [`EXCEP_TYPE_BUS] exception_type_o,
output reg  [`INST_ADDR_BUS]  pc_o
    );
    wire inst_stall, id_stall, exe_stall, data_stall;
    assign inst_stall = stall[0];
    assign id_stall = stall[1];
    assign exe_stall = stall[2];
    assign data_stall = stall[3];

always @ (posedge clk) begin
    if (rst == `RST_ENABLE) begin
        pc_o <= 32'hbfc0_0000;
    end else begin
        if (exception == `EXCEPTION_ON) begin
            pc_o <= exception_pc_i;
        end else begin 
            if (branch_enable_i == `BRANCH_ENABLE) begin
                if (stall == 4'b0000) pc_o <= branch_addr_i;
            end else begin
                if (stall == 4'b0000) pc_o <= pc_o + 4;
            end
        end
    end
end


function [31:0] get_exception_type(input [31:0] ibus_addr/*input ibus_read, input tlb_miss, input tlb_ready,  input tlb_v, input tlb_kern, input iskernel*/);
    begin
        if (ibus_addr[1:0] != 2'b00) begin
            get_exception_type = {1'b1,31'b0};
        end
        else begin
            get_exception_type = `ZEROWORD32;
        end
    end
endfunction

assign exception_type_o = get_exception_type(pc_o);
endmodule
