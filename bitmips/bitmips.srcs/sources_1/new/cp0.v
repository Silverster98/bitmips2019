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
input wire                   now_in_delayslot_i,
output reg [`CP0_BUS]        cp0_read_data_o,
//output reg [`CP0_BUS]        cp0_badvaddr_o,
output reg [`CP0_BUS]        cp0_return_pc_o,    
output reg                   timer_int_o,    
output reg                   flush_o
);

reg [`CP0_BUS] cp0_badvaddr;
reg [`CP0_BUS] cp0_count;
reg [`CP0_BUS] cp0_compare;
reg [`CP0_BUS] cp0_status;
reg [`CP0_BUS] cp0_cause;
reg [`CP0_BUS] cp0_epc;
//reg [`CP0_BUS] cp0_prid;
//reg [`CP0_BUS] cp0_config;

reg timer_int;
reg flush;
reg [`CP0_BUS] cp0_return_pc;
reg exception_flag;

task is_exception_asserted(output is_exception_asserted);
begin
    is_exception_asserted = (flush == 1'b1) ? 1 : 0;
end
endtask

task de_asserted_exception;
begin
    flush = 0;
end
endtask

function [31:0] cp0_read(input [`CP0_ADDR_BUS] read_addr);
begin
    if(cp0_write_enable_i && read_addr == cp0_write_addr_i) begin
        if(cp0_write_addr_i == 5'd13) // cp0_cause
            cp0_read = {cp0_cause[31:24],cp0_write_data_i[23:22],cp0_cause[21:10],cp0_write_data_i[9:8],cp0_cause[7:0]};
        else
            cp0_read = cp0_write_data_i;
    end
        /****************************************
         * some reg is readonly at some bit,so don't give all bit to cp0_read
         ****************************************/
    else begin
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
//        5'd15:
//            cp0_read = cp0_prid;
//        5'd16:
//            cp0_read = cp0_config;
         default:
            cp0_read = 32'h0;
    endcase
    end
end
endfunction

task cp0_write(input [`CP0_ADDR_BUS] write_addr, input [`CP0_BUS]  write_data);
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
endtask

task assert_exception(input [`EXCEP_CODE_BUS] exception_code, input [`INST_BUS] int_offset);
begin
    if(cp0_cause[`EXL] ==0) begin
        if(now_in_delayslot_i == 1'b1) begin
            cp0_epc = pc_i - 4;
            cp0_cause[`BD] = 1;
        end else begin
            cp0_epc = pc_i;
            cp0_cause[`BD] = 0;
        end
    end
    cp0_status[`EXL] = 1;
    //cp0_return_pc = int_offset + 32'hbfc0000;
    cp0_return_pc = int_offset;
    flush = 1'b1;
    cp0_cause[6:2] = exception_code;
end
endtask


task assert_general_exception(input [`EXCEP_CODE_BUS] exception_code);
begin
    assert_exception(exception_code,32'h0000_0020);
end
endtask

task assert_general_memory_exception(input [`EXCEP_CODE_BUS] exception_code, input [`INST_BUS] exception_addr);
begin
    assert_exception(exception_code,32'h0000_0020);
    cp0_badvaddr = exception_addr_i;
end
endtask

task assert_exception_return(input [`EXCEP_CODE_BUS] exception_code);
begin
    cp0_status[`EXL] = 0;
    cp0_return_pc = cp0_epc;
    flush = 1'b1;
end
endtask

task update_timer;
begin
    cp0_count = cp0_count + 1;
    if(cp0_compare != `ZEROWORD32 && cp0_compare == cp0_count) begin
        timer_int = 1;
        assert_exception(`EXCEP_CODE_INT,32'h0000_0020);
    end
    else 
        timer_int = 0;
end
endtask

task handle_exception(input [`EXCEP_TYPE_BUS] exception_type);
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
endtask

always @(*)
begin
    cp0_read_data_o = cp0_read(cp0_read_addr_i);
end


always @(posedge clk)
begin
    if(rst == `RST_ENABLE) begin
        flush <= 1'b0;
        timer_int <= 1'b0;
        exception_flag <= 1'b0;
        cp0_return_pc <= `ZEROWORD32;
        cp0_badvaddr <= `ZEROWORD32;
        cp0_count <= `ZEROWORD32;
        cp0_compare <= `ZEROWORD32;
        // [31:  28]
        // CU3...CU0
        // CU0 = 1 -> enable cp0 
        cp0_status <= 32'h10000000;
        cp0_cause <= `ZEROWORD32;
        cp0_epc <= `ZEROWORD32;
        // littel endian
//        cp0_config <= `ZEROWORD32;
        // cp0_prid seems not important
//        cp0_prid <= `ZEROWORD32;
    end else begin
        is_exception_asserted(exception_flag);
        if(exception_flag)
            de_asserted_exception();      
        update_timer();
        handle_exception(exception_type_i);
        if(cp0_write_enable_i)
            cp0_write(cp0_write_addr_i,cp0_write_data_i);
        cp0_return_pc_o <= cp0_return_pc;
        timer_int_o <= timer_int;
        flush_o <= flush;
    end
end

endmodule