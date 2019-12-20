`timescale 1ns / 1ps

`include "defines.vh"

module if_id(
    input   wire        rst,
    input   wire        clk,
    input   wire        exception,
    input   wire[3:0]   stall,
    
    input   wire[31:0]  pc_i,
    input   wire[31:0]  exception_type_i,
    
    output  reg [31:0]  pc_o,
    output  reg [31:0]  exception_type_o
    );
    
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE) begin
            pc_o <= 32'b0;
            exception_type_o <= 32'b0;
        end else if (exception == 1'b1)begin
            pc_o <= 32'b0;
            exception_type_o <= 32'b0;
        end else begin
            if (stall == 4'b0000) begin
                pc_o <= pc_i;
                exception_type_o <= exception_type_i;
            end
        end
    end
endmodule
