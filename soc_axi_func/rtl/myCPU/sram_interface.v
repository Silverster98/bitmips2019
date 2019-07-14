`include "defines.v"

module sram_interface(
    input wire clk,
    input wire rst,
    input wire flush,

    // from and to cpu
    input wire[31:0] inst_sram_addr,
    output wire[31:0] inst_sram_rdata,
    output reg inst_stall,

    input wire[31:0] data_sram_addr,
    input wire data_sram_ren,
    output wire[31:0] data_sram_rdata,
    input wire[3:0] data_sram_wen,
    input wire[31:0] data_sram_wdata,
    output reg data_stall,

    // from and to cache
    output wire[31:0] inst_addr,
    output reg inst_ren,
    input wire inst_valid,
    input wire[31:0] inst_rd,
    
    output wire[31:0] data_addr,
    output reg[3:0] data_wen,
    output reg data_ren,
    output reg[31:0] data_wd,
    input wire data_valid,
    input wire[31:0] data_rd,
    
    output wire is_cache
);

assign is_cache = judge_is_cache(inst_ren, inst_sram_addr, data_ren, data_wen, data_sram_addr);

function judge_is_cache(input inst_ren, input [31:0] inst_sram_addr, input data_ren, input [3:0] data_wen, 
                        input [31:0] data_sram_addr);
begin
    if (data_ren == 1 || data_wen != 4'b0000) begin
        judge_is_cache = (data_sram_addr[31:29] == 3'b101) ? 1'b0 : 1'b1;
    end else if (inst_ren == 1'b1) begin
        judge_is_cache = (inst_sram_addr[31:29] == 3'b101) ? 1'b0 : 1'b1;
    end else begin
        judge_is_cache = 1'b1;
    end
end
endfunction

reg[31:0] inst_buf, data_buf;

assign inst_addr = inst_sram_addr[31:30] == 2'b10 ? {3'b000, inst_sram_addr[28:0]} : inst_sram_addr;
assign data_addr = data_sram_addr[31:30] == 2'b10 ? {3'b000, data_sram_addr[28:0]} : data_sram_addr;

reg[1:0] handle_data; // 00 is common, 01 is wait for data, 10 is data ok
reg[1:0] handle_data_t;
always @(posedge clk) begin
    handle_data = handle_data_t;
end

parameter[1:0] state_idle = 2'b00;
parameter[1:0] state_req = 2'b01;
parameter[1:0] state_wait = 2'b10;
parameter[1:0] state_wait0 = 2'b11;
reg[1:0] current_state, next_state;
always @ (posedge clk) begin
    if (rst == `RST_ENABLE) begin
        current_state = state_idle;
    end else begin
        current_state = next_state;
    end
end

always @ (*) begin
    case(current_state)
        state_idle: begin
//            next_state = state_req;
            inst_ren = 1'b0;
            data_ren = 1'b0;
            data_wen = 4'b0;
            inst_stall = 1'b1;
            data_stall = 1'b1;
            data_wd = 32'b0;
            handle_data_t = 2'b00;
            next_state = state_wait0;
        end
        state_wait0: begin
            inst_ren = 1'b0;
            data_ren = 1'b0;
            data_wen = 4'b0;
            inst_stall = 1'b1;
            data_stall = 1'b1;
            data_wd = 32'b0;
            handle_data_t = handle_data_t;
            next_state = state_req;
        end
        state_req: begin
            if (flush != 1'b1) begin
                if (data_sram_ren == 1'b1 && handle_data == 2'b00) begin
                    inst_ren = 1'b0;
                    data_ren = 1'b1;
                    data_wen = 4'b0;
                    data_wd = 32'b0;
                    handle_data_t = 2'b01;
                end else if (data_sram_wen != 4'b0 && handle_data == 2'b00) begin
                    inst_ren = 1'b0;
                    data_ren = 1'b0;
                    data_wen = data_sram_wen;
                    data_wd = data_sram_wdata;
                    handle_data_t = 2'b01;
                end else begin
                    inst_ren = 1'b1;
                    data_ren = 1'b0;
                    data_wen = 4'b0;
                    data_wd = 32'b0;
                    handle_data_t = 2'b00;
                end
                
                inst_stall = 1'b1;
                data_stall = 1'b1;
                next_state = state_wait;
            end else begin
                inst_ren = 1'b0;
                data_ren = 1'b0;
                data_wen = 4'b0;
                inst_stall = 1'b1;
                data_stall = 1'b1;
                data_wd = 32'b0;
                handle_data_t = 2'b00;
                next_state = state_wait0;
            end
        end
        state_wait: begin
            if (inst_valid && (handle_data == 2'b00 || handle_data == 2'b10)) begin
                inst_buf = inst_rd;
                inst_stall = 1'b0;
                data_stall = 1'b0;
                handle_data_t = 2'b00;
                next_state = state_wait0;
            end
            
            if (data_valid && handle_data == 2'b01) begin
                data_buf = data_rd;
                handle_data_t = 2'b10;
                next_state = state_req;
            end
        end
    endcase
end

assign inst_sram_rdata = inst_buf;
assign data_sram_rdata = data_buf;

endmodule
