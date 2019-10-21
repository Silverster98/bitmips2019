`include "defines.v"

module data_sram_to_sram_like(
    input           clk,
    input           rst,         
    
    //sram
    input           flush,  
    input  [31:0]   data_sram_wdata,
    input  [31:0]   data_sram_addr,
    input  [3:0]    data_sram_wen,
    input           data_sram_en,
    output [31:0]   data_sram_rdata,          
    output          data_stall,	       
    //sram_like     
    output          data_req,
    output          data_wr,
    output [1:0]    data_size,
    output [31:0]   data_addr,
    output [31:0]   data_wdata,
    input  [31:0]   data_rdata,
    input           data_addr_ok,
    input           data_data_ok 
);

reg [2:0] state_current;
parameter [2:0] state_idle = 3'b000;
parameter [2:0] state_wait_addr = 3'b001;
parameter [2:0] state_wait_data = 3'b010;
parameter [2:0] state_wait_invalid_data = 3'b011;
parameter [2:0] state_req = 3'b011;


always @ (posedge clk) begin
    if (rst == `RST_ENABLE) begin
        state_current <= state_idle;
    end else begin
        if (state_current == state_idle && data_sram_en) begin
            state_current <= state_req;
        end else if (state_current == state_req) begin
            if (flush) state_current <= state_idle;
            else if (data_addr_ok) state_current <= state_wait_data;
        end else if (state_current == state_wait_data) begin
            if (data_data_ok) state_current <= state_idle;
        end
    end
end


assign data_sram_rdata = (state_current == state_wait_data && data_data_ok == 1'b1) ? data_rdata : 32'b0;
assign data_stall = ((state_current == state_wait_data && data_data_ok == 1'b1) || (state_current == state_idle && data_sram_en == 1'b0) || (state_current == state_req && flush == 1'b1)) ? 1'b0 : 1'b1;
  
assign data_req = (state_current == state_req && flush == 1'b0) ? 1'b1 : 1'b0;
assign data_wr = data_sram_wen == 4'b0000 ? 1'b0 : 1'b1;
assign data_size = get_data_size(data_sram_wen);
assign data_addr = {data_sram_addr[31:2], get_data_addr_off(data_sram_wen)};
assign data_wdata = data_sram_wdata;

function [1:0] get_data_size(input [3:0] data_sram_wen);
    begin
        case(data_sram_wen)
        4'b0001, 4'b0010, 4'b0100, 4'b1000: get_data_size = 2'b00;
        4'b0011, 4'b1100: get_data_size = 2'b01;
        default: get_data_size = 2'b10;
        endcase
    end
endfunction

function [1:0] get_data_addr_off(input [3:0] data_sram_wen);
    begin
        case(data_sram_wen)
        4'b1000: get_data_addr_off = 2'b11;
        4'b1100, 4'b0100: get_data_addr_off = 2'b10;
        4'b0010: get_data_addr_off = 2'b01;
        default: get_data_addr_off = 2'b00;
        endcase
    end
endfunction

endmodule
