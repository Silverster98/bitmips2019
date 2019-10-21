`include "defines.v"

module mem(
    input wire rst,
    
    input wire[`INST_ADDR_BUS] pc_i,
    input wire[`ALUOP_BUS] aluop_i,
    input wire now_in_delayslot_i,
    input wire[`EXCEP_TYPE_BUS] exception_type_i,
    input wire regfile_write_enable_i,
    input wire ram_write_enable_i,
    input wire hi_write_enable_i,
    input wire lo_write_enable_i,
    input wire cp0_write_enable_i,
    input wire[`GPR_ADDR_BUS] regfile_write_addr_i,
    input wire[`RAM_ADDR_BUS] ram_write_addr_i,
    input wire[`CP0_ADDR_BUS] cp0_write_addr_i,
    input wire[`GPR_BUS] alu_data_i,
    input wire[`GPR_BUS] ram_write_data_i,
    input wire[`GPR_BUS] hi_write_data_i,
    input wire[`GPR_BUS] lo_write_data_i,
    input wire[`GPR_BUS] cp0_write_data_i,
    input wire mem_to_reg_i,
    input wire[`RAM_ADDR_BUS] ram_read_addr_i,
    input wire[`GPR_BUS] ram_read_data_i,
   
    output wire[`INST_ADDR_BUS] store_pc_o,
    output wire[`RAM_ADDR_BUS] access_mem_addr_o,
    output wire now_in_delayslot_o,
    output wire[`EXCEP_TYPE_BUS] exception_type_o,
    
    output wire regfile_write_enable_o,
    output wire[`GPR_ADDR_BUS] regfile_write_addr_o,
    output wire hi_write_enable_o,
    output wire[`GPR_BUS] hi_write_data_o,
    output wire lo_write_enable_o,
    output wire[`GPR_BUS] lo_write_data_o,
    output wire cp0_write_enable_o,
    output wire[`CP0_ADDR_BUS] cp0_write_addr_o,
    output wire[`CP0_BUS] cp0_write_data_o,
    output wire[`GPR_BUS] regfile_write_data_o,
    
    output wire[3:0] ram_write_select_o, // byte select, width = 4bit for 4 byte,bit 1 is write, bit 0 is no write
    output wire ram_write_enable_o,
    output wire[`RAM_ADDR_BUS] ram_write_addr_o,
    output wire[`GPR_BUS] ram_write_data_o,
    output wire[`RAM_ADDR_BUS] ram_read_addr_o,
    output wire ram_read_enable_o,
    
    output wire convert_flush_o,
    
    input wire data_addr_miss,
    input wire data_addr_invalid,
    input wire data_addr_modified,
    
    input wire[31:0] rt_data
    );
    
    wire is_read_bad_addr, is_write_bad_addr;
    wire[`GPR_BUS] ram_data_o;
    assign convert_flush_o = exception_type_o == 32'h0 ? 1'b0 : 1'b1;
    
    assign regfile_write_enable_o = rst == `RST_ENABLE ? 32'b0 : 
                                    exception_type_i != 32'h0 ? 1'b0 :
                                    regfile_write_enable_i;
    assign regfile_write_addr_o   = rst == `RST_ENABLE ? `ZEROWORD5 :
                                    regfile_write_addr_i;
    assign hi_write_enable_o      = rst == `RST_ENABLE ? 1'b0 :
                                    hi_write_enable_i;
    assign hi_write_data_o        = rst == `RST_ENABLE ? `ZEROWORD32 :
                                    hi_write_data_i;
    assign lo_write_enable_o      = rst == `RST_ENABLE ? 1'b0 :
                                    lo_write_enable_i;
    assign lo_write_data_o        = rst == `RST_ENABLE ? `ZEROWORD32 :
                                    lo_write_data_i;
    assign cp0_write_enable_o     = rst == `RST_ENABLE ? 1'b0 :
                                    cp0_write_enable_i;
    assign cp0_write_addr_o       = rst == `RST_ENABLE ? `ZEROWORD5 :
                                    cp0_write_addr_i;
    assign cp0_write_data_o       = rst == `RST_ENABLE ? `ZEROWORD32 :
                                    cp0_write_data_i;
    assign regfile_write_data_o   = rst == `RST_ENABLE ? `ZEROWORD32 :
                                    mem_to_reg_i == 1'b1 ? ram_data_o : alu_data_i;

    assign ram_read_addr_o = rst == `RST_ENABLE ? `ZEROWORD32 : {ram_read_addr_i[31:2], 2'b00};
    
    assign ram_data_o = get_ram_data_o(rst, aluop_i, ram_read_addr_i, ram_read_data_i, rt_data);
function [31:0] get_ram_data_o(input rst, input [7:0] aluop_i, input [31:0] ram_read_addr_i,
                               input [31:0] ram_read_data_i, input [31:0] rt_data);
begin
    if (rst == `RST_ENABLE) begin
        get_ram_data_o = `ZEROWORD32;
    end else begin
        case (aluop_i)
            `ALUOP_LB : begin
                case (ram_read_addr_i[1:0])
                    2'b00 : get_ram_data_o = {{24{ram_read_data_i[7]}}, ram_read_data_i[7:0]};
                    2'b01 : get_ram_data_o = {{24{ram_read_data_i[15]}}, ram_read_data_i[15:8]};
                    2'b10 : get_ram_data_o = {{24{ram_read_data_i[23]}}, ram_read_data_i[23:16]};
                    2'b11 : get_ram_data_o = {{24{ram_read_data_i[31]}}, ram_read_data_i[31:24]};
                    default : get_ram_data_o = `ZEROWORD32;
                endcase
            end
            `ALUOP_LBU : begin
                case (ram_read_addr_i[1:0])
                    2'b00 : get_ram_data_o = {{24'h000000}, ram_read_data_i[7:0]};
                    2'b01 : get_ram_data_o = {{24'h000000}, ram_read_data_i[15:8]};
                    2'b10 : get_ram_data_o = {{24'h000000}, ram_read_data_i[23:16]};
                    2'b11 : get_ram_data_o = {{24'h000000}, ram_read_data_i[31:24]};
                    default : get_ram_data_o = `ZEROWORD32;
                endcase
            end
            `ALUOP_LH : begin
                case (ram_read_addr_i[1:0])
                    2'b00 : get_ram_data_o = {{16{ram_read_data_i[15]}}, ram_read_data_i[15:0]};
                    2'b10 : get_ram_data_o = {{16{ram_read_data_i[31]}}, ram_read_data_i[31:16]};
                    default : get_ram_data_o = `ZEROWORD32;
                endcase
            end
            `ALUOP_LHU : begin
                case (ram_read_addr_i[1:0])
                    2'b00 : get_ram_data_o = {{16'h0000}, ram_read_data_i[15:0]};
                    2'b10 : get_ram_data_o = {{16'h0000}, ram_read_data_i[31:16]};
                    default : get_ram_data_o = `ZEROWORD32;
                endcase
            end
            `ALUOP_LW : begin
                get_ram_data_o = ram_read_data_i;
            end
            `ALUOP_LWL:begin
                case (ram_read_addr_i[1:0])
                    2'b00 : get_ram_data_o = {ram_read_data_i[7:0], rt_data[23:0]};
                    2'b01 : get_ram_data_o = {ram_read_data_i[15:0], rt_data[15:0]};
                    2'b10 : get_ram_data_o = {ram_read_data_i[23:0], rt_data[7:0]};
                    2'b11 : get_ram_data_o = {ram_read_data_i[31:0]};
                    default : get_ram_data_o = rt_data;
                endcase
            end
            `ALUOP_LWR:begin
                case (ram_read_addr_i[1:0])
                    2'b00 : get_ram_data_o = {ram_read_data_i[31:0]};
                    2'b01 : get_ram_data_o = {rt_data[31:24], ram_read_data_i[31:8]};
                    2'b10 : get_ram_data_o = {rt_data[31:16], ram_read_data_i[31:16]};
                    2'b11 : get_ram_data_o = {rt_data[31:8], ram_read_data_i[31:24]};
                    default : get_ram_data_o = rt_data;
                endcase
            end
            default : begin
                get_ram_data_o = `ZEROWORD32;
            end
        endcase
    end
end
endfunction

    assign is_read_bad_addr = get_is_read_bad_addr(rst, aluop_i, ram_read_addr_i);
function get_is_read_bad_addr(input rst, input [7:0] aluop_i, input [31:0] ram_read_addr_i);
begin
    if (rst == `RST_ENABLE) begin
        get_is_read_bad_addr = 1'b0;
    end else begin
        case (aluop_i)
            `ALUOP_LB, `ALUOP_LBU : begin
                get_is_read_bad_addr = 1'b0;
            end
            `ALUOP_LH, `ALUOP_LHU : begin
                get_is_read_bad_addr = (ram_read_addr_i[0] == 1'b0) ? 1'b0 : 1'b1;
            end
            `ALUOP_LW : begin
                get_is_read_bad_addr = (ram_read_addr_i[1:0] == 2'b00) ? 1'b0 : 1'b1;
            end
            default : begin
                get_is_read_bad_addr = 1'b0;
            end
        endcase
    end
end
endfunction
    
    assign ram_read_enable_o = get_ram_read_enable_o(rst, aluop_i);
function get_ram_read_enable_o(input rst, input [7:0] aluop_i);
begin
    if (rst == `RST_ENABLE) begin
        get_ram_read_enable_o = 1'b0;
    end else begin
        case (aluop_i)
            `ALUOP_LB, `ALUOP_LBU, `ALUOP_LH, `ALUOP_LHU, `ALUOP_LW, `ALUOP_LWL, `ALUOP_LWR : begin
                get_ram_read_enable_o = 1'b1;
            end
            default : begin
                get_ram_read_enable_o = 1'b0;
            end
        endcase
    end
end
endfunction

    assign ram_write_select_o = get_ram_write_select_o(rst, aluop_i, ram_write_addr_i);
function [3:0] get_ram_write_select_o(input rst, input [7:0] aluop_i, 
                                      input [31:0] ram_write_addr_i);
begin
    if (rst == `RST_ENABLE) begin
        get_ram_write_select_o = 4'b0000;
    end else begin
        case(aluop_i)
            `ALUOP_SB : begin
                case (ram_write_addr_i[1:0])
                    2'b00 : get_ram_write_select_o = 4'b0001;
                    2'b01 : get_ram_write_select_o = 4'b0010;
                    2'b10 : get_ram_write_select_o = 4'b0100;
                    2'b11 : get_ram_write_select_o = 4'b1000;
                    default : get_ram_write_select_o = 4'b0000;
                endcase
            end
            `ALUOP_SH : begin
                case (ram_write_addr_i[1:0])
                    2'b00 : get_ram_write_select_o = 4'b0011;
                    2'b10 : get_ram_write_select_o = 4'b1100;
                    default : get_ram_write_select_o = 4'b0000;
                endcase
            end
            `ALUOP_SW : begin
                get_ram_write_select_o = 4'b1111;
            end
            `ALUOP_SWL: begin
                case (ram_write_addr_i[1:0])
                    2'b00 : get_ram_write_select_o = 4'b0001;
                    2'b01 : get_ram_write_select_o = 4'b0011;
                    2'b10 : get_ram_write_select_o = 4'b0111;
                    2'b11 : get_ram_write_select_o = 4'b1111;
                    default : get_ram_write_select_o = 4'b0000;
                endcase
            end
            `ALUOP_SWR:begin
                case (ram_write_addr_i[1:0])
                    2'b00 : get_ram_write_select_o = 4'b1111;
                    2'b01 : get_ram_write_select_o = 4'b1110;
                    2'b10 : get_ram_write_select_o = 4'b1100;
                    2'b11 : get_ram_write_select_o = 4'b1000;
                    default : get_ram_write_select_o = 4'b0000;
                endcase
            end
            default : begin
                get_ram_write_select_o = 4'b0000;
            end
        endcase
    end
end
endfunction

    assign ram_write_enable_o = rst == `RST_ENABLE ? 1'b0 : 
                                is_write_bad_addr == 1'b1 ? 1'b0 : ram_write_enable_i;
    assign ram_write_addr_o   = rst == `RST_ENABLE ? `ZEROWORD32 :
                                {ram_write_addr_i[31:2], 2'b00};
    
    assign ram_write_data_o   = get_ram_write_data_o(rst, aluop_i, ram_write_data_i, ram_write_addr_i);
function [31:0] get_ram_write_data_o(input rst, input [7:0] aluop_i, 
                                     input [31:0] ram_write_data_i, input [31:0] ram_write_addr);
begin
    if (rst == `RST_ENABLE) begin
        get_ram_write_data_o = `ZEROWORD32;
    end else begin
        case (aluop_i)
            `ALUOP_SB : begin
                get_ram_write_data_o = {ram_write_data_i[7:0], ram_write_data_i[7:0], ram_write_data_i[7:0], ram_write_data_i[7:0]};
            end
            `ALUOP_SH : begin
                get_ram_write_data_o = {ram_write_data_i[15:0], ram_write_data_i[15:0]};
            end
            `ALUOP_SW : begin
                get_ram_write_data_o = ram_write_data_i;
            end
            `ALUOP_SWL: begin
                case(ram_write_addr[1:0])
                2'b00: get_ram_write_data_o = {24'b0, ram_write_data_i[31:24]};
                2'b01: get_ram_write_data_o = {16'b0, ram_write_data_i[31:16]};
                2'b10: get_ram_write_data_o = {8'b0, ram_write_data_i[31:8]};
                2'b11: get_ram_write_data_o = {ram_write_data_i[31:0]};
                default: get_ram_write_data_o = 32'b0;
                endcase
            end
            `ALUOP_SWR: begin
                case(ram_write_addr[1:0])
                2'b00: get_ram_write_data_o = {ram_write_data_i[31:0]};
                2'b01: get_ram_write_data_o = {ram_write_data_i[23:0], 8'b0};
                2'b10: get_ram_write_data_o = {ram_write_data_i[15:0], 16'b0};
                2'b11: get_ram_write_data_o = {ram_write_data_i[7:0], 24'b0};
                default: get_ram_write_data_o = 32'b0;
                endcase
            end
            default : begin
                get_ram_write_data_o = ram_write_data_i;
            end
        endcase
    end
end
endfunction

    assign is_write_bad_addr = get_is_write_bad_addr(rst, aluop_i, ram_write_addr_i);
function [31:0] get_is_write_bad_addr(input rst, input [7:0] aluop_i, 
                                     input [31:0] ram_write_addr_i);
begin
    if (rst == `RST_ENABLE) begin
        get_is_write_bad_addr = 1'b0;
    end else begin
        case (aluop_i)
            `ALUOP_SB : begin
                get_is_write_bad_addr = 1'b0;
            end
            `ALUOP_SH : begin
                get_is_write_bad_addr = (ram_write_addr_i[0] == 1'b0) ? 1'b0 : 1'b1;
            end
            `ALUOP_SW : begin
                get_is_write_bad_addr = (ram_write_addr_i[1:0] == 2'b00) ? 1'b0 : 1'b1;
            end
            default : begin
                get_is_write_bad_addr = 1'b0;
            end
        endcase
    end
end
endfunction
    
    assign store_pc_o         = rst == `RST_ENABLE ? `ZEROWORD32 : pc_i;
    assign now_in_delayslot_o = rst == `RST_ENABLE ? `ZEROWORD32 : now_in_delayslot_i;
    
    assign access_mem_addr_o  = get_access_mem_addr_o(rst, aluop_i, ram_read_addr_i, ram_write_addr_i);
function [31:0] get_access_mem_addr_o(input rst, input [7:0] aluop_i, 
                            input [31:0] ram_read_addr_i, input [31:0] ram_write_addr_i);
begin
    if (rst == `RST_ENABLE) begin
        get_access_mem_addr_o = `ZEROWORD32;
    end else begin
        case (aluop_i)
            `ALUOP_LB, `ALUOP_LH, `ALUOP_LBU, `ALUOP_LHU, `ALUOP_LW, `ALUOP_LWL, `ALUOP_LWR : begin
                get_access_mem_addr_o = ram_read_addr_i;
            end
            `ALUOP_SB, `ALUOP_SH, `ALUOP_SW, `ALUOP_SWL, `ALUOP_SWR : begin
                get_access_mem_addr_o = ram_write_addr_i;
            end
            default : begin
                get_access_mem_addr_o = `ZEROWORD32;
            end
        endcase
    end
end
endfunction

    assign exception_type_o = get_exception_type_o(rst, aluop_i, is_read_bad_addr, is_write_bad_addr, exception_type_i,data_addr_miss,data_addr_invalid,data_addr_modified);
function [31:0] get_exception_type_o(input rst, input [7:0] aluop_i, 
                input is_read_bad_addr, input is_write_bad_addr, input [31:0] exception_type_i,
                input data_addr_miss,input data_addr_invalid,input data_addr_modified);
begin
    if (rst == `RST_ENABLE) begin
        get_exception_type_o = `ZEROWORD32;
    end else begin
        case (aluop_i)
            `ALUOP_LB, `ALUOP_LH, `ALUOP_LBU, `ALUOP_LHU, `ALUOP_LW : begin
                get_exception_type_o = {exception_type_i[31:27], is_read_bad_addr, exception_type_i[25:22], data_addr_miss,data_addr_invalid,data_addr_modified,exception_type_i[18:0]};
            end
            `ALUOP_SB, `ALUOP_SH, `ALUOP_SW : begin
                get_exception_type_o = {exception_type_i[31:26], is_write_bad_addr, exception_type_i[24:22],data_addr_miss,data_addr_invalid,data_addr_modified,1'b1,exception_type_i[17:0]};
            end
            default : begin
                get_exception_type_o = exception_type_i;
            end
        endcase
    end
end
endfunction
    
endmodule
