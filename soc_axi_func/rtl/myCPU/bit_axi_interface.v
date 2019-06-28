`include "defines.v"

module bit_axi_interface(
    input wire inst_or_data, // for cache, 1 is data, 0 is inst

    input wire clk,
    input wire rst,
    input wire flush,

    input wire[31:0] inst_sram_addr,
    output wire[31:0] inst_sram_rdata,
    output reg inst_stall,

    input wire[31:0] data_sram_addr,
    input wire data_sram_ren,
    output wire[31:0] data_sram_rdata,
    input wire[3:0] data_sram_wen,
    input wire[31:0] data_sram_wdata,
    output reg data_stall,

    //axi
    //ar
    output wire[3:0] arid,
    output wire[31:0] araddr,
    output wire[7:0] arlen,
    output wire[2:0] arsize,
    output wire[1:0] arburst,
    output wire[1:0] arlock,
    output wire[3:0] arcache,
    output wire[2:0] arprot,
    output wire arvalid,
    input wire arready,

    //r
    input wire[3:0] rid,
    input wire[31:0] rdata,
    input wire[1:0] rresp,
    input wire rlast,
    input wire rvalid,
    output wire rready,

    //aw
    output wire[3:0] awid,
    output wire[31:0] awaddr,
    output wire[7:0] awlen,
    output wire[2:0] awsize,
    output wire[1:0] awburst,
    output wire[1:0] awlock,
    output wire[3:0] awcache,
    output wire[2:0] awprot,
    output wire awvalid,
    input wire awready,

    //w
    output wire[3:0] wid,
    output wire[31:0] wdata,
    output wire[3:0] wstrb,
    output wire wlast,
    output wire wvalid,
    input wire wready,

    //b
    input wire[3:0] bid,
    input wire[1:0] bresp,
    input wire bvalid,
    output wire bready
);

reg dor_inst_data; // 0 is inst req,1 is data req
reg dor_req;
reg[31:0] dor_addr;
reg[2:0] dor_size;
reg[31:0] dor_data;
reg data_back;
always @ (posedge clk) begin
    if (rst == `RST_ENABLE) begin
        dor_inst_data <= 1'b0;
        dor_addr <= 32'b0;
        dor_size <= 2'b00;
        dor_data = 32'b0;
    end else if (data_sram_ren) begin
        dor_inst_data <= 1'b1;
        dor_addr <= data_sram_addr;
        dor_size <= 3'b010;
        if (data_back == 1'b1) dor_data = rdata;
        else dor_data = 32'b0;
    end else begin
        dor_inst_data <= 1'b0;
        dor_addr <= inst_sram_addr;
        dor_size <= 3'b010;
        if (data_back == 1'b1) dor_data = rdata;
        else dor_data = 32'b0;
    end
end

parameter[2:0] state_idle = 3'b000;
parameter[2:0] state_req = 3'b001;
parameter[2:0] state_wait_arready = 3'b010;
parameter[2:0] state_wait_rdata = 3'b011;
reg[2:0] current_state;
reg[2:0] next_state;
always @ (posedge clk) begin
    if (rst == `RST_ENABLE) current_state = state_idle;
    else current_state = next_state;
end

always @ (*) begin
    case (current_state)
        state_idle : begin
            dor_req = 1'b0;
            inst_stall = 1'b1;
            data_stall = 1'b1;
            data_back = 1'b0;
            next_state = state_req;
        end
        state_req : begin
            dor_req = 1'b1;
            inst_stall = dor_inst_data == 1'b0 ? 1'b1 : 1'b0;
            data_stall = dor_inst_data == 1'b0 ? 1'b0 : 1'b1;
            data_back = 1'b0;
            next_state = state_wait_arready;
        end
        state_wait_arready : begin
            inst_stall = dor_inst_data == 1'b0 ? 1'b1 : 1'b0;
            data_stall = dor_inst_data == 1'b0 ? 1'b0 : 1'b1;
            data_back = 1'b0;
            if (arready) begin
                dor_req = 1'b0;
                next_state = state_wait_rdata;
            end else begin
                dor_req = 1'b1;
                next_state = current_state;
            end
        end
        state_wait_rdata : begin
            if (rvalid) begin
                inst_stall = 1'b0;
                data_stall = 1'b0;
                data_back = 1'b1;
            end else begin
                inst_stall = dor_inst_data == 1'b0 ? 1'b1 : 1'b0;
                data_stall = dor_inst_data == 1'b0 ? 1'b0 : 1'b1;
                data_back = 1'b0;
            end
        end
        default : begin 
        end
    endcase
end

assign inst_sram_rdata = dor_data;

//ar
assign arid = 4'b0;
assign araddr = dor_addr;
assign arlen = 8'b0;
assign arsize = dor_size;
assign arburst = 2'b0;
assign arlock = 2'b0;
assign arcache = 4'b0;
assign arprot = 3'b0;
assign arvalid = dor_req;

//r
assign rready = 1'b1;

//aw
assign awid = 4'b0;
assign awaddr = 32'b0;
assign awlen = 8'b0;
assign awsize = 3'b0;
assign awburst = 2'b0;
assign awlock = 2'b0;
assign awcache = 4'b0;
assign awprot = 3'b0;
assign awvalid = 1'b0;

//w
assign wid = 4'b0;
assign wdata = 32'b0;
assign wstrb = 4'b0;
assign wlast = 1'd1;
assign wvalid = 1'b0;

//b
assign bready = 1'b1;

endmodule
