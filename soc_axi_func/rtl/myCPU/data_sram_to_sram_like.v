`include "defines.v"
module data_sram_to_sram_like(
input             clk,
input             rst,         
input             flush,
//ctrl     
//input      [4:0]   stall_i,
//input              flush_i,
           
//sram  
input      [31:0] data_sram_i,
input      [31:0] addr_sram_i,
input      [3:0]  wen_sram_i,
input             ren_sram_i,
output reg [31:0] data_sram_o,           
output reg        data_stall,	       
//sram_like     
output reg        data_req,
output reg        data_wr,
output reg [1 :0] data_size,
output reg [31:0] data_addr,
output reg [31:0] data_wdata,
input      [31:0] data_rdata,
input             data_addr_ok,
input             data_data_ok 
);

reg [2:0] state;
reg [2:0] addr_off;
parameter [2:0] state_idle = 3'b000;
parameter [2:0] state_wait_addr = 3'b001;
parameter [2:0] state_wait_data = 3'b010;
parameter [2:0] state_done = 3'b011;

always @(*) begin
      case (wen_sram_i)
		  4'b1000,
		  4'b0100,
		  4'b0010,
		  4'b0001: begin 
				data_size <= 2'b00;
		  end
		  4'b0011,
		  4'b1100: begin 
				data_size <= 2'b01;
		  end
		  default: begin 
				data_size <= 2'b10;
		  end
      endcase
end

always @(*) begin
    case (wen_sram_i)
        4'b1000: addr_off <= 3;
        4'b0100, 4'b1100: addr_off <= 2;
        4'b0010: addr_off <= 1;
        default: addr_off <= 0;
    endcase 
end



always @(*) begin
    if(rst == `RST_ENABLE) begin
        data_stall = 1'b0;
        data_sram_o = 32'b0;
    end else begin
    case (state)
        state_idle: begin
            if(!flush && (ren_sram_i == 1'b1 || wen_sram_i != 4'b0000)) begin
                data_stall = 1'b1;
                data_sram_o = 32'b0;
            end else begin
                data_stall = 1'b0;
                data_sram_o = 32'b0;
            end
        end
        state_wait_addr: begin
            if(flush) begin
                data_stall = 1'b0;
                data_sram_o = 32'b0;
            end else begin
                data_stall = 1'b1;
                data_sram_o = 32'b0;
            end
        end
        state_wait_data: begin
            if(data_data_ok) begin
                data_stall = 1'b0;
                data_sram_o = data_rdata;
            end else begin
                data_stall = 1'b1;
                data_sram_o = 32'h0;
            end
        end
        default: begin
            data_stall = 1'b0;
            data_sram_o = 32'b0;
        end
    endcase
    end
end


always @(posedge clk) begin
    if(rst == `RST_ENABLE) begin
        data_req <= 1'b0;
        data_wr <= 1'b0;
        data_wdata <= 32'b0;
        state <= state_idle;
        data_addr <= 32'h0;
    end else begin
    case (state)
        state_idle:
            if(!flush && (ren_sram_i == 1'b1 || wen_sram_i != 4'b0000)) begin
                data_req <= 1'b1;
                if(wen_sram_i != 4'b0000) data_wr <= 1'b1;
                else data_wr <= 1'b0;
                if(addr_sram_i[31:28] >= 4'b1000 && addr_sram_i[31:28] <= 4'b1100)
                    data_addr <= {3'b000,addr_sram_i[28:0]} + addr_off ;
                else
                    data_addr <= addr_sram_i + addr_off;
                data_wdata <= data_sram_i;
                state <= state_wait_addr;
            end
        state_wait_addr:
            if(flush) begin
                data_req <= 1'b0;
                data_wr <= 1'b0;
                state <= state_idle;
            end
            else if(data_addr_ok) begin
                data_req <= 1'b0;
                data_wr <= 1'b0;
                state <= state_wait_data;
            end
        state_wait_data:
            if(data_data_ok) state <= state_idle;
            else state <= state_wait_data;
        //state_done:
        //    state <= state_idle;
    endcase
    end
end
endmodule
