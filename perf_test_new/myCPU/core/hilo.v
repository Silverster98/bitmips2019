`include "defines.vh"

module hilo(
    input  wire         clk,
    input  wire         rst,
    input  wire         hi_write_enable_i,
    input  wire[31:0]   hi_write_data_i,
    input  wire         lo_write_enable_i,
    input  wire[31:0]   lo_write_data_i,
    input  wire         hilo_read_addr_i,   //can be "0" or "1" only
    output wire[31:0]   hilo_read_data_o
);

reg [31:0] hi;
reg [31:0] lo;

// addr = 1 indicates select high
assign hilo_read_data_o = (hilo_read_addr_i == 1'b1) ? (hi_write_enable_i ? hi_write_data_i : hi ): (lo_write_enable_i ? lo_write_data_i : lo);
always @ (posedge clk) begin
    if(rst == `RST_ENABLE) begin
        hi <= 32'b0;
        lo <= 32'b0;
    end else begin
        if(hi_write_enable_i == 1'b1)
            hi <= hi_write_data_i;
        if(lo_write_enable_i == 1'b1)
            lo <= lo_write_data_i;
    end
end
endmodule
