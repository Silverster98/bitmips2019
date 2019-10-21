`include "defines.v"
module hilo(
input  wire                  clk,
input  wire                  rst,
input  wire                  hi_write_enable_i,
input  wire  [`GPR_BUS]      hi_write_data_i,
input  wire                  lo_write_enable_i,
input  wire  [`GPR_BUS]      lo_write_data_i,
input  wire                  hilo_read_addr_i,   //can be "0" or "1" only
output wire  [`GPR_BUS]      hilo_read_data_o
);

reg [`GPR_BUS] hi;
reg [`GPR_BUS] lo;

// addr = 1 indicates select high
assign hilo_read_data_o = (hilo_read_addr_i == 1'b1) ? (hi_write_enable_i ? hi_write_data_i : hi ): (lo_write_enable_i ? lo_write_data_i : lo);
always @ (posedge clk) begin
    if(rst == `RST_ENABLE) begin
        hi <= `ZEROWORD32;
        lo <= `ZEROWORD32;
    end else begin
        if(hi_write_enable_i == 1'b1)
            hi <= hi_write_data_i;
        if(lo_write_enable_i == 1'b1)
            lo <= lo_write_data_i;
    end
end
endmodule
