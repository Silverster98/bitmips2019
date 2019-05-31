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

reg [2:0] state_current;
reg [2:0] state_next;
reg [31:0] data_addr_convert;
parameter [2:0] state_idle = 3'b000;
parameter [2:0] state_req = 3'b001;
parameter [2:0] state_wait_addr = 3'b010;
parameter [2:0] state_wait_data = 3'b011;
parameter [2:0] state_done = 3'b100;

always @(posedge clk) begin
   if(rst == `RST_DISABLE) state_current <= state_next;
   else state_current <= state_idle;
end

always @(*) begin
    case(state_current)
        state_idle: begin
            data_req = 1'b0;
            data_wr = 1'b0;
            data_size = 2'b00;
            data_addr = 32'h0;
            data_wdata = 32'h0;
            data_sram_o = 32'h0;
            data_stall = 1'b0;
            state_next = state_req;
        end
        state_req: begin
            if(ren_sram_i == 1'b1) begin
                data_stall = 1'b1;
                data_size = 2'b10;
                data_req = 1'b1;
                state_next = state_wait_addr;
                data_addr = (addr_sram_i[31:30] == 2'b11) ? addr_sram_i : {3'b000, addr_sram_i[28:0]};;
            end else if(wen_sram_i != 4'b0000) begin
                if(wen_sram_i == 4'b1111) begin
                    data_stall = 1'b1;
                    data_size = 2'b10;
                    data_req = 1'b1;
                    data_wr = 1'b1;
                    state_next = state_wait_addr;
                    data_wdata = data_sram_i;
                    data_addr = (addr_sram_i[31:30] == 2'b11) ? addr_sram_i : {3'b000, addr_sram_i[28:0]};
                end
                else if(wen_sram_i == 4'b1100 || wen_sram_i == 4'b0011 ) begin
                    data_stall = 1'b1;
                    data_size = 2'b01;
                    data_req = 1'b1;
                    data_wr = 1'b1;
                    state_next = state_wait_addr;
                    /*data_wdata = (wen_sram_i == 4'b1100) ? data_sram_i>>8 : data_sram_i;
                    */
                    data_wdata = data_sram_i;
                    if(wen_sram_i == 4'b1100) data_addr_convert = addr_sram_i + 2;
                    else data_addr_convert = addr_sram_i;
                    data_addr = (data_addr_convert[31:30] == 2'b11) ? data_addr_convert : {3'b000, data_addr_convert[28:0]};
                end
                else if(wen_sram_i == 4'b0001 ||wen_sram_i == 4'b0010 ||wen_sram_i == 4'b0100 ||
                wen_sram_i == 4'b1000 ) begin
                    data_stall = 1'b1;
                    data_size = 2'b00;
                    data_req = 1'b1;
                    data_wr = 1'b1;
                    state_next = state_wait_addr;
                    data_wdata = data_sram_i;
                    /*data_wdata = wen_sram_i == 4'b1000 ? (data_sram_i >> 12) : 
                                 wen_sram_i == 4'b0100 ? (data_sram_i >> 8) :   
                                 wen_sram_i == 4'b0010 ? (data_sram_i >> 4) : data_sram_i;
                    */
                    if(wen_sram_i == 4'b1000) data_addr_convert = addr_sram_i + 3;
                    else if(wen_sram_i == 4'b0100) data_addr_convert = addr_sram_i + 2;
                    else if(wen_sram_i == 4'b0010) data_addr_convert = addr_sram_i + 1;
                    else data_addr_convert = addr_sram_i;
                    data_addr = (data_addr_convert[31:30] == 2'b11) ? data_addr_convert : {3'b000, data_addr_convert[28:0]};
                end
            end 
        end
        state_wait_addr: begin
            if (flush) begin
                data_req = 1'b0;
                data_wr = 1'b0;
                data_stall = 1'b0;
                state_next = state_req;
            end
            else if(data_addr_ok) state_next = state_wait_data;
        end
        state_wait_data: begin
            if(data_data_ok) begin
                data_sram_o = data_rdata;
                state_next = state_done;
                data_stall = 1'b0;
            end
        end
        state_done: begin
            data_req = 1'b0;
            data_wr = 1'b0;
            state_next = state_req;
        end
        default: begin
            state_next = state_idle;
        end
    endcase
end
endmodule
