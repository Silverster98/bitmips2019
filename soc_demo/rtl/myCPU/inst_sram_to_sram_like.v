`include "defines.v"

module inst_sram_to_sram_like(
    input clk,
    input rst,
    // sram
    input           flush,
    input  [31:0]   inst_sram_addr,
    output [31:0]   inst_sram_rdata,
    output          inst_stall,
    //instr sram_like
    output          inst_req,
    output          inst_wr,
    output [1:0]    inst_size,
    output [31:0]   inst_addr,
    output [31:0]   inst_wdata,
    input  [31:0]   inst_rdata,
    input           inst_addr_ok,
    input           inst_data_ok
);

reg [2:0] state_current;
parameter [2:0] state_idle = 3'b000;
parameter [2:0] state_req_0 = 3'b001;
parameter [2:0] state_req_1 = 3'b010;
parameter [2:0] state_wait_data_0 = 3'b011;
parameter [2:0] state_wait_data_1 = 3'b100;
parameter [2:0] state_wait_invalid_data = 3'b101;



always @ (posedge clk) begin
    if (rst == `RST_ENABLE) begin
        state_current <= state_idle;
    end else begin
        if (state_current == state_idle) begin
            state_current <= state_req_0;
        end else if (state_current == state_req_0) begin
            if (flush) state_current <= state_wait_invalid_data;
            else if (inst_addr_ok) state_current <= state_wait_data_0;
        end else if (state_current == state_wait_data_0) begin
            if (flush) begin
                if (inst_data_ok) state_current <= state_req_1;
                else state_current <= state_wait_invalid_data;
            end else if (inst_data_ok) state_current <= state_req_0;
        end else if (state_current == state_wait_invalid_data) begin
            if (inst_data_ok) state_current <= state_req_1;
        end else if (state_current == state_req_1) begin
            if (inst_addr_ok) state_current <= state_wait_data_1;
        end else if (state_current == state_wait_data_1) begin
            if (inst_data_ok) state_current <= state_req_0;
        end
    end
end

assign inst_sram_rdata = ((state_current == state_wait_data_0 || state_current == state_wait_data_1) && inst_data_ok == 1'b1) ? inst_rdata : 32'b0;
assign inst_stall = (((state_current == state_wait_data_0 && flush != 1'b1) || (state_current == state_wait_data_1)) && inst_data_ok == 1'b1) ? 1'b0 : 1'b1;

assign inst_req = (state_current == state_req_0 || state_current == state_req_1) ? 1'b1 : 1'b0;
assign inst_addr = inst_sram_addr;


// don't care
assign inst_wr = 1'b0;
assign inst_size = 2'b10;
assign inst_wdata = 32'h0;

endmodule
