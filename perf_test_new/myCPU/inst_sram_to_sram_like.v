`define RST_ENABLE 1'b0

module inst_sram_to_sram_like(
    input clk,
    input rst,
    // sram
    input           flush,
    input  [31:0]   inst_sram_addr,
    output [31:0]   inst_sram_rdata,
    output          inst_stall,
    input  [3:0]    stall,
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
reg flush_r;
always @ (posedge clk) begin
    if (rst == `RST_ENABLE) flush_r <= 1'b0;
    else if (flush) flush_r <= 1'b1;
    else if (stall == 4'b0000) flush_r <= 1'b0;
end
wire[31:0] inst_rdata_temp;
assign inst_rdata_temp = (flush || flush_r) ? 32'b0 : inst_rdata;


reg[31:0] inst_addr_r1, inst_addr_r2;
always @ (*) begin
    if (rst == `RST_ENABLE) begin
        inst_addr_r1 <= 32'b0;
    end else begin
        inst_addr_r1 <= inst_sram_addr;
    end
end
always @ (posedge clk) begin
    if (rst == `RST_ENABLE)
        inst_addr_r2 <= 32'b0;
    if (stall == 4'b0000)
        inst_addr_r2 <= inst_addr_r1;
end

reg[31:0] inst_rdata_r;
always @ (posedge clk) begin
    if (rst == `RST_ENABLE) inst_rdata_r <= 32'b0;
    else if (inst_data_ok) inst_rdata_r <= inst_rdata_temp;
end 

reg stall_reg;
always @ (posedge clk) begin
    if (rst == `RST_ENABLE) stall_reg <= 1'b1;
    else if (inst_req) stall_reg <= 1'b1;
    else if (inst_data_ok) stall_reg <= 1'b0;
end

assign inst_stall = (inst_addr_r1 != 32'b0 && inst_addr_r2 == 32'b0) || inst_data_ok ? 1'b0 : stall_reg;



assign inst_sram_rdata = inst_data_ok ? inst_rdata_temp : inst_rdata_r;

assign inst_req = (inst_addr_r1 != 32'b0 && !flush && !(|stall)) ? 1'b1 : 1'b0;
assign inst_addr = inst_addr_r1;

// don't care
assign inst_wr = 1'b0;
assign inst_size = 2'b10;
assign inst_wdata = 32'h0;

endmodule
