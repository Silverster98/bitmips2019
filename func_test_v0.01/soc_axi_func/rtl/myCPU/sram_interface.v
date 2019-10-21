`include "defines.v"

module sram_interface(
    input wire          clk,
    input wire          rst,
    input wire          flush,

    // from and to cpu
    input  wire [31:0]  inst_cpu_addr,
    output reg  [31:0]  inst_cpu_rdata,
    output reg          inst_cpu_stall,
                             
    input  wire [31:0]  data_cpu_addr,
    input  wire         data_cpu_ren,
    input  wire [3:0]   data_cpu_wen,
    input  wire [31:0]  data_cpu_wdata,
    output reg  [31:0]  data_cpu_rdata,
    output reg          data_cpu_stall,

    // from and to cache
    input  wire         inst_cache_ok,
    input  wire [31:0]  inst_cache_rdata,
    output wire [31:0]  inst_cache_addr,
    output reg          inst_cache_ren,
    
    input  wire         data_cache_read_ok,
	input  wire			data_cache_write_ok,
    input  wire [31:0]  data_cache_rdata,
    output wire [31:0]  data_cache_addr,
    output reg  [3:0]   data_cache_wen,
    output reg          data_cache_ren,
    output reg  [31:0]  data_cache_wdata,
    
    output reg          inst_cache_ena,
    output reg          data_cache_ena,
    output reg          is_inst_read,
    output reg          is_data_read,
    
    output wire         is_flush
);

/* mmu */
assign inst_cache_addr = inst_cpu_addr[31:30] == 2'b10 ? {3'b000, inst_cpu_addr[28:0]} : inst_cpu_addr;
assign data_cache_addr = data_cpu_addr[31:30] == 2'b10 ? {3'b000, data_cpu_addr[28:0]} : data_cpu_addr;

parameter[2:0] state_idle = 3'b00;
parameter[2:0] state_prereq = 3'b001;
parameter[2:0] state_req = 3'b010;
parameter[2:0] state_wait_inst_read = 3'b011;
parameter[2:0] state_wait_data_read = 3'b100;
parameter[2:0] state_wait_data_write = 3'b101;
reg[2:0] state;

reg [31:0] dcache_rdata_buf;
reg [31:0] icache_rdata_buf;

reg data_write_ok_buf;
reg inst_ok_buf;

assign is_flush = flush;

always @(*) begin
    if(rst == `RST_ENABLE) begin
        inst_cpu_stall = 1'b0;
        inst_cpu_rdata = 32'b0;
        data_cpu_stall = 1'b0;
        data_cpu_rdata = 32'b0;
    end else begin
    case(state)
        state_idle: begin
            inst_cpu_stall = 1'b1;
            inst_cpu_rdata = 32'b0;
            data_cpu_stall = 1'b1;
            data_cpu_rdata = 32'b0;
        end
        state_req: begin
            inst_cpu_stall = 1'b1;
            inst_cpu_rdata = 32'b0;
            data_cpu_stall = 1'b1;
            data_cpu_rdata = 32'b0;
        end
        state_wait_inst_read: begin
            if (flush) begin
                inst_cpu_stall = 1'b0;
                inst_cpu_rdata = 32'b0;
                data_cpu_stall = 1'b0;
                data_cpu_rdata = 32'b0;
            end else 
            if(inst_cache_ok) begin
                inst_cpu_stall = 1'b0;
                inst_cpu_rdata = inst_cache_rdata;
                data_cpu_stall = 1'b0;
                data_cpu_rdata = dcache_rdata_buf;
            end else begin
                inst_cpu_stall = 1'b1;
                inst_cpu_rdata = 32'b0;
                data_cpu_stall = 1'b1;
                data_cpu_rdata = 32'b0;
            end
        end
        state_wait_data_read: begin
            if (flush) begin
                inst_cpu_stall = 1'b0;
                inst_cpu_rdata = 32'b0;
                data_cpu_stall = 1'b0;
                data_cpu_rdata = 32'b0;
            end else begin
                inst_cpu_stall = 1'b1;
                inst_cpu_rdata = 32'b0;
                data_cpu_stall = 1'b1;
                data_cpu_rdata = 32'b0;
            end
        end
        state_wait_data_write: begin
            if (flush) begin
                inst_cpu_stall = 1'b0;
                inst_cpu_rdata = 32'b0;
                data_cpu_stall = 1'b0;
                data_cpu_rdata = 32'b0;
            end else begin
                inst_cpu_stall = 1'b1;
                inst_cpu_rdata = 32'b0;
                data_cpu_stall = 1'b1;
                data_cpu_rdata = 32'b0;
            end
        end
        default: begin
           inst_cpu_stall = 1'b0;
           inst_cpu_rdata = 32'b0;
           data_cpu_stall = 1'b0;
           data_cpu_rdata = 32'b0;
        end
    endcase
    end
end

always @ (posedge clk) begin
    if(rst == `RST_ENABLE) begin
        state <= state_idle;
        data_write_ok_buf <= 1'b0;
        inst_ok_buf <= 1'b0;
        dcache_rdata_buf <= 32'b0;
        icache_rdata_buf <= 32'b0;
        is_inst_read <= 1'b0;
        is_data_read <= 1'b0;
        inst_cache_ena <= 1'b0;
        data_cache_ena <= 1'b0;
    end else begin
    case(state)
        state_idle: begin
            state <= state_req;
            data_cache_wen <= 4'b0000;
            inst_cache_ren <= 1'b0;
            data_cache_ren <= 1'b0; 
            is_inst_read <= 1'b0;
            is_data_read <= 1'b0;
            inst_ok_buf <= 1'b0;
            data_write_ok_buf <= 1'b0;
        end
        state_req: begin
            inst_ok_buf <= 1'b0;
            data_write_ok_buf <= 1'b0;
            if(data_cpu_ren == 1'b1) begin
                data_cache_ren <= 1'b1;
                data_cache_wen <= 4'b0000;
                inst_cache_ren <= 1'b0;
                is_inst_read <= 1'b0;
                is_data_read <= 1'b1;
                
                data_cache_ena <= data_cpu_addr[31:29] == 3'b101 ? 1'b0 : 1'b1;
                inst_cache_ena <= inst_cpu_addr[31:29] == 3'b101 ? 1'b0 : 1'b1;
                state <= state_wait_data_read;
            end else if(data_cpu_wen != 4'b0000) begin
                data_cache_wen <= data_cpu_wen;
                data_cache_ren <= 1'b0;
                inst_cache_ren <= 1'b0;
                is_inst_read <= 1'b0;
                is_data_read <= 1'b1;
                
                inst_cache_ena <= inst_cpu_addr[31:29] == 3'b101 ? 1'b0 : 1'b1;
                data_cache_ena <= data_cpu_addr[31:29] == 3'b101 ? 1'b0 : 1'b1;
                data_cache_wdata <= data_cpu_wdata;
                state <= state_wait_data_write;
            end else begin
                data_cache_wen <= 4'b0000;
                data_cache_ren <= 1'b0;
                inst_cache_ren <= 1'b1;
                is_inst_read <= 1'b1;
                is_data_read <= 1'b0;
                
                inst_cache_ena <= inst_cpu_addr[31:29] == 3'b101 ? 1'b0 : 1'b1;
                data_cache_ena <= 1'b0;
                state <= state_wait_inst_read;
            end
        end
        state_wait_inst_read: begin
            inst_cache_ren <= 1'b0;
            if(inst_cache_ok) begin
                state <= state_req;
            end
            
            if (flush == 1'b1) begin
                state <= state_req;
            end
        end
        state_wait_data_read: begin
            data_cache_ren <= 1'b0;
            if(data_cache_read_ok) begin
                state <= state_wait_inst_read;
                inst_cache_ren <= 1'b1;
                is_inst_read <= 1'b1;
                is_data_read <= 1'b0;
                dcache_rdata_buf <= data_cache_rdata;
            end
            
            if (flush == 1'b1) begin
                state <= state_req;
            end
        end
        state_wait_data_write: begin
            if(data_cache_write_ok) begin 
                data_cache_wen <= 4'b0000; //change here cause data_cache_fifo use this signal in wait state
                state <= state_wait_inst_read;
                inst_cache_ren <= 1'b1;
                is_inst_read <= 1'b1;
                is_data_read <= 1'b0;
            end
            
            if (flush == 1'b1) begin
                state <= state_req;
            end
        end
        
        
    endcase
    end
end

endmodule
