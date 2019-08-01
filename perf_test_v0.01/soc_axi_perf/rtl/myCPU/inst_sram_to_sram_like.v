
module inst_sram_to_sram_like(

	input                         clock,
	input                         reset,
	
	//ctrl
	input     [4:0]               stall_i,
	input                         flush_i,
	
	//CPU
	//input                         cpu_ce_i,
	input     [31:0]              cpu_addr_i,
	//input                         cpu_cache,
	
	output reg[31:0]              cpu_data_o,
	output reg                    stallreq,

    //sram_like
    output reg                    inst_req,
    output                        inst_wr,
    output    [1:0]               inst_size,	   
    output reg[31:0]              inst_addr,
    output    [31:0]              inst_wdata,
	output reg                    inst_cache,
	
    input     [31:0]              inst_rdata,
    input                         inst_addr_ok,
    input                         inst_data_ok    
);

localparam AHB_IDLE = 3'b000;
localparam AHB_BUSY = 3'b001;
localparam AHB_WAIT_FOR_STALL = 3'b011;
localparam AHB_WAIT_FOR_RETURN = 3'b100;

reg[2:0]  ahb_state;
reg[31:0] rd_buf;
reg       is_flush;

assign inst_wr = 0;
assign inst_size = 2'b10;
assign inst_wdata = 0;

always @ (posedge clock) begin
	if (reset == `RST_ENABLE) begin
		ahb_state <= AHB_IDLE;
		inst_req <= 0;
		inst_addr <= 0;
		inst_cache <= 0;
		rd_buf <= 0;
		is_flush <= 0;
	end else begin
		case (ahb_state)
			AHB_IDLE:		begin
				if ((flush_i == 0) && is_flush == 0) begin
					ahb_state <= AHB_BUSY;
					inst_req <= 1;
					inst_addr <= cpu_addr_i;
					inst_cache <= (cpu_addr_i[31:28] == 4'b1010 || cpu_addr_i[31:28] == 4'b1011) ? 1'b0:1'b1;
					rd_buf <= 0;
				end							
			end
			AHB_BUSY: begin
				if (inst_data_ok == 1'b1) begin 				
					if(stall_i != 5'b00000 && !flush_i) begin
						ahb_state <= AHB_WAIT_FOR_STALL;
					end		
					else begin
						ahb_state <= AHB_IDLE;
					end
					if (!flush_i) begin
						rd_buf <= inst_rdata;
					end	
				end 

				else if(flush_i == 1) begin
				    	ahb_state <= AHB_WAIT_FOR_RETURN;
					inst_addr <= 0;
					inst_cache <= 0;
					rd_buf <= 0;
					is_flush <= 1;
					if (inst_addr_ok == 1'b1) begin
						inst_req <= 0;	
					end
				end

				else if (inst_addr_ok == 1'b1) begin	
					inst_req <= 0;		
					inst_addr <= 0;	
					inst_cache <= 0;
				end
			end
			AHB_WAIT_FOR_STALL:		begin
				if(stall_i == 5'b00000 || flush_i) begin
					ahb_state <= AHB_IDLE;
				end
			end
			AHB_WAIT_FOR_RETURN: begin
				if (inst_addr_ok == 1'b1) begin
					inst_req <= 0;		
					inst_addr <= 0;	
					//inst_cache <= 0;
				end
				else if (inst_data_ok == 1'b1) begin
					ahb_state <= AHB_IDLE;
					rd_buf <= 0;
					is_flush <= 0;
				end
			end
			default: begin
			end 
		endcase
	end    //if
end      //always
			

always @ (*) begin
	if(reset == `RST_ENABLE) begin
		stallreq <= 1;
		cpu_data_o <= 0;
	end else begin
		case (ahb_state)
			AHB_IDLE:		begin
				if(flush_i == 0) begin
					stallreq <= 1;
					cpu_data_o <= 0;				
				end
				else begin
					stallreq <= 1;
					cpu_data_o <= 0;
				end
			end
			AHB_BUSY:		begin
				if(inst_data_ok == 1'b1 && !flush_i) begin
					stallreq <= 0;
					cpu_data_o <= inst_rdata; 						
				end else begin
					stallreq <= 1;	
					cpu_data_o <= 0;				
				end
			end
			AHB_WAIT_FOR_STALL:		begin
				stallreq <= 0;
				cpu_data_o <= rd_buf;
			end
			AHB_WAIT_FOR_RETURN: begin
				stallreq <= 1;
				cpu_data_o <= 0;
			end
			default: begin
                stallreq <= 0;
                cpu_data_o <= 0;
			end 
		endcase
	end    //if
end      //always

endmodule
