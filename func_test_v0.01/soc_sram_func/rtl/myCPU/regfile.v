`include "defines.v"
module regfile(
input wire                  clk,
input wire                  rst,
input wire                  regfile_write_enable,
input wire [`GPR_ADDR_BUS]  regfile_write_addr,
input wire [`GPR_BUS]       regfile_write_data,
input wire [`GPR_ADDR_BUS]  rs_read_addr,
input wire [`GPR_ADDR_BUS]  rt_read_addr,
output reg [`GPR_BUS]       rs_data_o,
output reg [`GPR_BUS]       rt_data_o
);

reg [`GPR_BUS] regfile [31:0];

always @ (posedge clk) begin
    if(rst == `RST_DISABLE)
        if(regfile_write_enable == 1'b1 && regfile_write_addr != 5'h0) 
            regfile[regfile_write_addr] = regfile_write_data;
end
    
always @ (*) begin
    if(rst == `RST_ENABLE)
        rs_data_o <= 32'h0;
    else if(rs_read_addr == 5'h0)
        rs_data_o <= 32'h0;
    else if(rs_read_addr == regfile_write_addr && regfile_write_enable == 1'b1)
        rs_data_o <= regfile_write_data;
    else
        rs_data_o <= regfile[rs_read_addr];
end 
always @ (*) begin
    if(rst == `RST_ENABLE)
        rt_data_o <= 32'h0;
    else if(rt_read_addr == 5'h0)
        rt_data_o <= 32'h0;
    else if(rt_read_addr == regfile_write_addr && regfile_write_enable == 1'b1)
        rt_data_o <= regfile_write_data;
    else
        rt_data_o <= regfile[rt_read_addr];
end
   
endmodule
