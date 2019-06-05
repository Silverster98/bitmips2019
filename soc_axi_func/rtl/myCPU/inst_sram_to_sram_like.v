`include "defines.v"
module inst_sram_to_sram_like(
input clk,
input rst,
// sram
input             flush,
input      [31:0] inst_sram_addr,
(*mark_debug = "true"*) output reg [31:0] inst_sram_rdata,
(*mark_debug = "true"*) output reg        inst_stall,
//instr sram_like
(*mark_debug = "true"*) output reg        inst_req,
output            inst_wr,
output     [1:0]  inst_size,
(*mark_debug = "true"*) output reg [31:0] inst_addr,
output     [31:0] inst_wdata,
(*mark_debug = "true"*) input      [31:0] inst_rdata,
(*mark_debug = "true"*) input             inst_addr_ok,
(*mark_debug = "true"*) input             inst_data_ok

);

assign inst_wr = 1'b0;
assign inst_size = 2'b10;
assign inst_wdata = 32'h0;

reg [2:0] state_current;
reg [2:0] state_next;
parameter [2:0] state_idle = 3'b000;
parameter [2:0] state_req = 3'b001;
parameter [2:0] state_wait_addr = 3'b010;
parameter [2:0] state_wait_data_twice = 3'b011;
parameter [2:0] state_wait_data = 3'b100;
parameter [2:0] state_done = 3'b101;
parameter [2:0] state_wait_addr_twice = 3'b110;
always @ (posedge clk)
begin
	if (rst == `RST_DISABLE) state_current <= state_next;
	else state_current <= state_idle;
end

//reg [31:0] rd_buf;

always @ (*)
begin
	case(state_current)
		state_idle: begin
			inst_req = 1'b0;
			inst_stall = 1'b1;
			inst_addr = 32'h0;
			inst_sram_rdata = 32'h0;
			state_next = state_req;
		end
	   	state_req: begin
        	inst_req = 1'b1;
			inst_stall = 1'b1;
			inst_addr = inst_sram_addr;
			inst_sram_rdata = 32'h0;
			state_next = state_wait_addr;
		end
		state_wait_addr: begin
		    if(flush == 1'b1)
		    begin
                inst_req = 1'b0;
                inst_stall = 1'b1;
                inst_addr = inst_sram_addr;
                inst_sram_rdata = 32'h0;
                state_next = state_wait_addr_twice;
			end else begin
			if(inst_addr_ok) begin
                inst_req = 1'b1;
                inst_stall = 1'b1;
                inst_addr = inst_sram_addr;
                inst_sram_rdata = 32'h0;
                state_next = state_wait_data;
            end else begin
                inst_req = 1'b1;
                inst_stall = 1'b1;
                inst_addr = inst_sram_addr;
                inst_sram_rdata = 32'h0;
                state_next = state_wait_addr;
            end
            end
		end
		
		state_wait_addr_twice: begin
		    inst_addr = inst_sram_addr;
		    inst_req = 1'b1;
		    inst_stall = 1'b1;
		    inst_sram_rdata = 32'h0;
		    if(inst_addr_ok)
		        state_next = state_wait_data;
		    else
		        state_next = state_wait_addr_twice;
		end
		
		state_wait_data: begin
		    inst_req = 1'b1;
		    inst_addr = inst_sram_addr;
		    if(inst_data_ok) begin
		        inst_stall = 1'b0;
		        inst_sram_rdata = inst_rdata;
		        state_next = state_req;
		    end else begin
		        inst_stall = 1'b1;
		        inst_sram_rdata = 32'h0;
		        state_next = state_wait_data;
		    end
		end
		default: begin
			inst_req = 1'b0;
			inst_stall = 1'b1;
			inst_addr = 32'h0;
			inst_stall = 1'b1;
			inst_sram_rdata = 32'h0;
			state_next = state_req;
		end		
	endcase
	
end

endmodule
