`include "defines.v"

module if_id(
    input wire                   rst,
    input wire                   clk,
    input wire [`INST_ADDR_BUS]  if_pc,
    input wire [`INST_BUS]       if_instr,
    input wire                   exception,
    input wire                   stall,
	input wire [`EXCEP_TYPE_BUS] if_exception_type,
	input wire [`INST_ADDR_BUS]  if_exception_addr,
		
	output reg [`EXCEP_TYPE_BUS] id_exception_type,
	output reg [`INST_ADDR_BUS]  id_exception_addr,
    output reg [`INST_ADDR_BUS]  id_pc,
    output reg [`INST_BUS]       id_instr
    );
    
    always @ (posedge clk) begin
        if (rst == `RST_ENABLE || exception == `EXCEPTION_ON) begin
            id_pc <= `ZEROWORD32;
            id_instr <= `ZEROWORD32;
            id_exception_type <= 6'h0;
            id_exception_addr <= `ZEROWORD32;
        end else begin
            if (stall == `NOSTOP) begin
                id_pc <= if_pc;
                id_instr <= if_instr;
                id_exception_type <= if_exception_type;
                id_exception_addr <= if_exception_addr; 
            end
        end
    end
endmodule
