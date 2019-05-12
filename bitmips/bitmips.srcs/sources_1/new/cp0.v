`include "defines.v"
module cp0
(
input wire                   clk,
input wire                   rst,
input wire [`CP0_ADDR_BUS]   cp0_read_addr_i,
input wire                   cp0_write_enable_i,
input wire [`CP0_ADDR_BUS]   cp0_write_addr_i,
input wire [`CP0_BUS]        cp0_write_data_i,
input wire [`EXCEP_TYPE_BUS] exception_type_i,
input wire [`INST_BUS]       pc_i,    
input wire [`INST_BUS]       exception_addr_i,
input wire [5:0]             int_i,
input wire                   now_in_delayslot,
output reg [`CP0_BUS]        cp0_read_data_o,
output reg [`CP0_BUS]        cp0_badvaddr_o,
output reg [`CP0_BUS]        cp0_epc_o,    
output reg                   timer_int_o,    
output reg                   flush_o
);

reg [`CP0_BUS] cp0_count;
reg [`CP0_BUS] cp0_compare;
reg [`CP0_BUS] cp0_status;
reg [`CP0_BUS] cp0_cause;
reg [`CP0_BUS] cp0_epc;
reg [`CP0_BUS] cp0_config;
reg [`CP0_BUS] cp0_prid;
reg [`CP0_BUS] cp0_badvaddr;

reg timer_int;
reg rubbish;
reg flush;


function is_exception_asserted(input rubbish);
begin
    is_exception_asserted = (flush == 1'b1) ? 1 : 0;
end
endfunction

function de_asserted_exception(input rubbish);
begin
    flush = 0;
end
endfunction

function update_timer(input rubbish);
begin
    cp0_count = cp0_count + 1;
    if(cp0_compare != `ZEROWORD32 && cp0_compare == cp0_count)
        timer_int = 1;
end
endfunction


function [31:0] cp0_read(input [`CP0_ADDR_BUS] read_addr);
begin
    case(read_addr)
        5'd9: //count:
            cp0_read = cp0_count;
        5'd11: //compare
            cp0_read = cp0_compare;
        5'd12: //status:
            cp0_read = cp0_status;
        5'd13: //cause:
            cp0_read = cp0_cause;
        5'd14: //epc:
            cp0_read = cp0_epc;
        5'd15:
            cp0_read = cp0_prid;
        5'd16:
            cp0_read = cp0_config;
    endcase
end
endfunction

function cp0_write(input [`CP0_ADDR_BUS] write_addr, input [`CP0_BUS]  write_data);
begin
    case(write_addr)
        5'd9: //count
            cp0_count = write_data;
        5'd11: //compare
            cp0_compare = write_data;
        5'd12:
            cp0_status = write_data;
        5'd13:
        begin
            cp0_cause[9:8] = write_data[9:8];
            cp0_cause[23:22] = write_data[23:22];
        end
        5'd16:
            cp0_epc = write_data;
    endcase
end
endfunction

function assert_exception(input [`EXCEP_CODE_BUS] exception_code, input [`INST_BUS] offset);
begin
    if(cp0_cause[`EXL] ==0) begin
        if(now_in_delayslot == 1'b1) begin
            cp0_epc = pc_i - 4;
            cp0_cause[`BD] = 1;
        end else begin
            cp0_epc = pc_i;
            cp0_cause[`BD] = 0;
        end
    end
    cp0_status[`EXL] = 1;
    cp0_cause[6:2] = exception_code;
end
endfunction


function assert_general_exception(input [`EXCEP_CODE_BUS] exception_code);
begin
    assert_exception(exception_code,32'h0000_0380);
end
endfunction

function assert_general_memory_exception(input [`EXCEP_CODE_BUS] exception_code, input [`INST_BUS] exception_addr);
begin
    assert_exception(exception_code,32'h0000_0380);
    cp0_badvaddr = exception_addr_i;
end
endfunction

function assert_exception_return(input [`EXCEP_CODE_BUS] exception_code);
begin
    cp0_status[`EXL] = 0;
end
endfunction


function handle_exception(input [`EXCEP_TYPE_BUS] exception_type);
begin
    if(exception_type[31] == 1'b1) begin  
        assert_general_memory_exception(`EXCEP_CODE_ADEL,exception_addr_i);
    end else if(exception_type[30] == 1'b1) begin
        assert_general_exception(`EXCEP_CODE_RI); 
    end else if(exception_type[29] == 1'b1) begin
        assert_general_exception(`EXCEP_CODE_OV); 
    end else if(exception_type[28] == 1'b1) begin
        assert_general_exception(`EXCEP_CODE_TR);
    end else if(exception_type[27] == 1'b1) begin
        assert_general_exception(`EXCEP_CODE_SYS);
    end else if(exception_type[26] == 1'b1) begin
        assert_general_memory_exception(`EXCEP_CODE_ADEL,exception_addr_i);
    end else if(exception_type[25] == 1'b1) begin
        assert_general_memory_exception(`EXCEP_CODE_ADES,exception_addr_i);
    end else if(exception_type[0] == 1'b1) begin
        assert_exception_return(`EXCEP_CODE_ERET);
    end
end
endfunction

always @(posedge clk)
begin
    if(rst == `RST_ENABLE) begin
        cp0_count <= `ZEROWORD32;
        cp0_compare <= `ZEROWORD32;
        // [31:  28]
        // CU3...CU0
        // CU0 = 1 -> enable cp0 
        cp0_status <= 32'h10000000;
        cp0_cause <= `ZEROWORD32;
        cp0_epc <= `ZEROWORD32;
        // littel endian
        cp0_config <= `ZEROWORD32;
        // cp0_prid seems not important
        cp0_prid <= `ZEROWORD32;
    end else begin
        if(is_exception_asserted(rubbish))
            de_assert_exception();      
        update_timer(rubbish);
        handle_exception(exception_type_i);
        cp0_read_data_o = cp0_read(cp0_read_addr_i);
        if(cp0_write_enable_i)
            cp0_write(cp0_write_addr_i,cp0_write_data_i);
        cp0_epc_o <= cp0_epc;
        timer_int_o <= timer_int;
        flush_o <= flush;
    end
end

endmodule