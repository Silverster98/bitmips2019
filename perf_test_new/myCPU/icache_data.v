`timescale 1ns / 1ps

module icache_data(
    input   wire        clk,
    input   wire        rst,
    input   wire        en,
    input   wire[3:0]   wen,
    input   wire[31:0]  wdata,
    input   wire[31:0]  addr,
    output  wire[31:0]  rdata
    );
    
    icache_data_ram icache_data_ram_0(
        .clka(clk),         // input wire clka
        .ena(en),           // input wire ena
        .wea(wen),          // input wire [0 : 0] wea
        .addra(addr[11:5]), // input wire [6 : 0] addra
        .dina(wdata),       // input wire [31 : 0] dina
        .douta(rdata)       // output wire [31 : 0] douta
    );
endmodule
