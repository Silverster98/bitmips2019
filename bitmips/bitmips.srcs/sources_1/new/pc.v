`include "defines.v"
`include "CP0.svh"
module pc(
    input wire                    rst,
    input wire                    clk,
    input wire                    stall,
    input wire                    exception,
    input wire  [`INST_ADDR_BUS]  exception_pc_i,
    input wire                    branch_enable_i,
    input wire  [`INST_ADDR_BUS]  branch_addr_i,
    
    output wire [`EXCEP_TYPE_BUS] exception_type_o,
    output wire                   exception_valid_o,
    output wire [`INST_ADDR_BUS]  exception_addr_o,
    output reg  [`INST_ADDR_BUS]  pc_o
//    output reg cs_o
    );
    
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE) begin
            pc_o <= `ZEROWORD32;
        end else begin
            if (exception == `EXCEPTION_ON) begin
                pc_o <= exception_pc_i;
            end else if (stall == `NOSTOP) begin
                if (branch_enable_i == `BRANCH_ENABLE) begin
                    pc_o <= branch_addr_i;
                end else begin
                    pc_o <= pc_o + 4;
                end
            end
        end
    end
   
    function get_exception_valid(input [31:0] ibus_addr /*input ibus_read, input tlb_miss, input tlb_ready, input tlb_v, input tlb_kern, input iskernel*/);
        begin
            if (ibus_addr[1:0] != 2'b00) begin
                get_exception_valid = 1;
            end
            /*else if (ibus_read && tlb_miss == 1) begin
                get_exrvalid = 1;
            end
            else if (ibus_read && tlb_ready && tlb_v == 0) begin
                get_exrvalid = 1;
            end
            else if (ibus_read && tlb_ready && tlb_kern == 1 && iskernel == 0) begin
                get_exrvalid = 1;
            end*/
            else begin
                get_exception_valid = 0;
            end
        end
    endfunction
    
    function [5:0] get_exception_type(input [31:0] ibus_addr/*input ibus_read, input tlb_miss, input tlb_ready,  input tlb_v, input tlb_kern, input iskernel*/);
        begin
            if (ibus_addr[1:0] != 2'b00) begin
                get_exception_type = `CP0_EX_IF_ADDRERR;
            end
            /*else if (ibus_read && tlb_miss == 1) begin
                get_exception_type = `CP0_EX_IF_TLBMISS;
            end
            else if (ibus_read  && tlb_ready && tlb_v == 0) begin
                get_exception_type = `CP0_EX_IF_TLBINV;
            end
            else if (ibus_read  && tlb_ready && tlb_kern == 1 && iskernel == 0) begin
                get_exception_type = `CP0_EX_IF_ADDRERR;
            end*/
            else begin
                get_exception_type = 6'b111111;
            end
        end
    endfunction
    
    assign exception_valid_o = get_exception_valid(pc_o);
    assign exception_type_o = get_exception_type(pc_o);
    assign exception_addr_o = pc_o;
endmodule
