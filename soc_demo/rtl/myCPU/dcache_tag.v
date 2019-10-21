`timescale 1ns / 1ps

module dcache_tag(
    input   wire        rst,
    input   wire        clk,
    input   wire        wen,
    input   wire[20:0]  wdata,
    
    input   wire[31:0]  addr,
    output  wire[19:0]  rdata,
    output  wire        hit,
    output  wire        valid,
    output  wire        work,
    input   wire        op
    );
    
    reg[20:0] tag[127:0];
    
    // store addr
    reg[31:0] addr_temp;
    always @ (posedge clk) begin
        if (rst) begin
            addr_temp <= 32'b0;
        end else begin
            addr_temp <= addr;
        end
    end
    
    // reset tag
    reg[6:0] reset_counter;
    always @ (posedge clk) begin
        if (rst) reset_counter <= 7'b0;
        else if (reset_counter != 7'b111_1111) reset_counter <= reset_counter + 1'b1;
    end
    wire reset_done = reset_counter == 7'b111_1111 ? 1'b1 : 1'b0;
    reg work_t;
    always @ (posedge clk) begin
        if (rst) work_t <= 1'b0;
        else work_t <= reset_done;
    end
    assign work = work_t;
    
    always @ (posedge clk) begin
        if (!work) tag[reset_counter] <= 21'b0; // reset
        else if (wen || op) tag[addr[11:5]] <= wdata; // modify tag according to addr
    end
    
    // read tag
    wire[20:0] tag_read;
    reg[20:0] tag_t;
    assign tag_read = tag[addr[11:5]];
    always @ (posedge clk) begin
        tag_t <= tag_read;
    end
    
    assign hit = (addr_temp[31:12] == tag_t[19:0]) ? 1'b1 : 1'b0;
    assign valid = tag_t[20];
    assign rdata = tag_t[19:0];
endmodule
