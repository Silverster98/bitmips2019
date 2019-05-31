`include "defines.v"
module pre_mem
(
input wire 					 clk,
input wire 					 rst,
input wire 					 exception,
input wire [`INST_ADDR_BUS]  pre_mem_store_pc,
input wire [`RAM_ADDR_BUS]   pre_mem_access_mem_addr,
input wire 				     pre_mem_now_in_delayslot,
input wire [`EXCEP_TYPE_BUS] pre_mem_exception_type,
input wire 					 pre_mem_regfile_write_enable,
input wire [`GPR_ADDR_BUS]   pre_mem_regfile_write_addr,
input wire [`GPR_BUS]		 pre_mem_regfile_write_data,
input wire 					 pre_mem_hi_write_enable,
input wire 					 pre_mem_lo_write_enable,
input wire [`GPR_BUS]		 pre_mem_hi_write_data,
input wire [`GPR_BUS]		 pre_mem_lo_write_data,
input wire 					 pre_mem_cp0_write_enable,
input wire [`CP0_ADDR_BUS]	 pre_mem_cp0_write_addr,
input wire [`CP0_BUS]		 pre_mem_cp0_write_data,

output reg [`INST_ADDR_BUS]	 mem_store_pc,
output reg [`RAM_ADDR_BUS]   mem_access_mem_addr,
output reg 				     mem_now_in_delayslot,
output reg [`EXCEP_TYPE_BUS] mem_exception_type,
output reg 					 mem_regfile_write_enable,
output reg [`GPR_ADDR_BUS]   mem_regfile_write_addr,
output reg [`GPR_BUS]		 mem_regfile_write_data,
output reg 					 mem_hi_write_enable,
output reg 					 mem_lo_write_enable,
output reg [`GPR_BUS]		 mem_hi_write_data,
output reg [`GPR_BUS]		 mem_lo_write_data,
output reg 					 mem_cp0_write_enable,
output reg [`CP0_ADDR_BUS]	 mem_cp0_write_addr,
output reg [`CP0_BUS]		 mem_cp0_write_data
);

always @ (posedge clk)
begin
	if(rst == `RST_ENABLE || exception == `EXCEPTION_ON) begin
		mem_store_pc			 <= `ZEROWORD32;	
		mem_access_mem_addr	     <= `ZEROWORD32; 	
		mem_now_in_delayslot	     <= 1'b0;
		mem_exception_type	     <= `ZEROWORD32;
		mem_regfile_write_enable <= 1'b0;
		mem_regfile_write_addr   <= `ZEROWORD5;
		mem_regfile_write_data   <= `ZEROWORD32;
		mem_hi_write_enable	     <= 1'b0;
		mem_lo_write_enable	     <= 1'b0;
		mem_hi_write_data		 <= `ZEROWORD32;
		mem_lo_write_data		 <= `ZEROWORD32;
		mem_cp0_write_enable	 <= `ZEROWORD32;
		mem_cp0_write_addr	     <= `ZEROWORD5;
		mem_cp0_write_data	     <= `ZEROWORD32;
	end else begin
		mem_store_pc             <= pre_mem_store_pc;
		mem_access_mem_addr      <= pre_mem_access_mem_addr;
		mem_now_in_delayslot       <= pre_mem_now_in_delayslot;
		mem_exception_type       <= pre_mem_exception_type;
		mem_regfile_write_enable <= pre_mem_regfile_write_enable;
		mem_regfile_write_addr   <= pre_mem_regfile_write_addr;
		mem_regfile_write_data   <= pre_mem_regfile_write_data;
		mem_hi_write_enable      <= pre_mem_hi_write_enable;
		mem_lo_write_enable      <= pre_mem_lo_write_enable;
		mem_hi_write_data        <= pre_mem_hi_write_data;
		mem_lo_write_data        <= pre_mem_lo_write_data;
		mem_cp0_write_enable     <= pre_mem_cp0_write_enable;
		mem_cp0_write_addr       <= pre_mem_cp0_write_addr;
		mem_cp0_write_data       <= pre_mem_cp0_write_data;
	end
end
endmodule

		