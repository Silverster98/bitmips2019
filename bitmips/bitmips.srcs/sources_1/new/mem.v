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
   
    output reg[`INST_ADDR_BUS] store_pc_o,
    output reg[`INST_ADDR_BUS] exception_pc_o,
    output reg exception_o,
    output reg now_in_delayslot_o,
    output reg[`EXCEP_TYPE_BUS] exception_type_o,
    
    output reg regfile_write_enable_o,
    output reg[`GPR_ADDR_BUS] regfile_write_addr_o,
    output reg hi_write_enable_o,
    output reg[`GPR_BUS] hi_write_data_o,
    output reg lo_write_enable_o,
    output reg[`GPR_BUS] lo_write_data_o,
    output reg cp0_write_enable_o,
    output reg[`CP0_ADDR_BUS] cp0_write_addr_o,
    output reg[`CP0_BUS] cp0_write_data_o,
    output reg mem_to_reg_o,
    output reg[`GPR_BUS] alu_data_o,
    output reg[`GPR_BUS] ram_data_o,
    
    output reg[3:0] ram_write_select_o, // byte select, width = 4bit for 4 byte,bit 1 is write, bit 0 is no write
    output reg ram_write_enable_o,
    output reg[`RAM_ADDR_BUS] ram_write_addr_o,
    output reg[`GPR_BUS] ram_write_data_o,
    output reg[`RAM_ADDR_BUS] ram_read_addr_o
    );
    
    always @ (*) begin
        if (rst == `RST_ENABLE) begin
            regfile_write_enable_o <= 1'b0;
            regfile_write_addr_o <= `ZEROWORD5;
            hi_write_enable_o <= 1'b0;
            hi_write_data_o <= `ZEROWORD32;
            lo_write_enable_o <= 1'b0;
            lo_write_data_o <= `ZEROWORD32;
            cp0_write_enable_o <= 1'b0;
            cp0_write_addr_o <= `ZEROWORD5;
            cp0_write_data_o <= `ZEROWORD32;
            mem_to_reg_o <= 1'b0;
            alu_data_o <= `ZEROWORD32;
        end else begin
            regfile_write_enable_o <= regfile_write_enable_i;
            regfile_write_addr_o <= regfile_write_addr_i;
            hi_write_enable_o <= hi_write_enable_i;
            hi_write_data_o <= hi_write_data_i;
            lo_write_enable_o <= lo_write_enable_i;
            lo_write_data_o <= lo_write_data_i;
            cp0_write_enable_o <= cp0_write_enable_i;
            cp0_write_addr_o <= cp0_write_addr_i;
            cp0_write_data_o <= cp0_write_data_i;
            mem_to_reg_o <= mem_to_reg_i;
            alu_data_o <= alu_data_i;
        end
    end
    
    always @ (*) begin
        if (rst == `RST_ENABLE) begin
            ram_read_addr_o <= `ZEROWORD32;
            ram_data_o <= `ZEROWORD32;
        end else begin
            ram_read_addr_o <= {ram_read_addr_i[31:2], 2'b00};
            
            case (aluop_i)
                `ALUOP_LB : begin
                    case (ram_read_addr_i[1:0])
                        2'b00 : ram_data_o <= {{24{ram_read_data_i[7]}}, ram_read_data_i[7:0]};
                        2'b01 : ram_data_o <= {{24{ram_read_data_i[15]}}, ram_read_data_i[15:8]};
                        2'b10 : ram_data_o <= {{24{ram_read_data_i[23]}}, ram_read_data_i[23:16]};
                        2'b11 : ram_data_o <= {{24{ram_read_data_i[31]}}, ram_read_data_i[31:24]};
                    endcase
                end
                `ALUOP_LBU : begin
                    case (ram_read_addr_i[1:0])
                        2'b00 : ram_data_o <= {{24'h000000}, ram_read_data_i[7:0]};
                        2'b01 : ram_data_o <= {{24'h000000}, ram_read_data_i[15:8]};
                        2'b10 : ram_data_o <= {{24'h000000}, ram_read_data_i[23:16]};
                        2'b11 : ram_data_o <= {{24'h000000}, ram_read_data_i[31:24]};
                    endcase
                end
                `ALUOP_LH : begin
                    case (ram_read_addr_i[1:0])
                        2'b00 : ram_data_o <= {{16{ram_read_data_i[15]}}, ram_read_data_i[15:0]};
                        2'b10 : ram_data_o <= {{16{ram_read_data_i[31]}}, ram_read_data_i[31:16]};
                    endcase
                end
                `ALUOP_LHU : begin
                    case (ram_read_addr_i[1:0])
                        2'b00 : ram_data_o <= {{16'h0000}, ram_read_data_i[15:0]};
                        2'b10 : ram_data_o <= {{16'h0000}, ram_read_data_i[31:16]};
                    endcase
                end
                `ALUOP_LW : begin
                    ram_data_o <= ram_read_data_i;
                end
                default : begin
                    ram_data_o <= `ZEROWORD32;
                end
            endcase
        end
    end
    
    always @ (*) begin
        if (rst == `RST_ENABLE) begin
            ram_write_select_o <= 4'b0000;
            ram_write_enable_o <= 1'b0;
            ram_write_addr_o <= `ZEROWORD32;
            ram_write_data_o <= `ZEROWORD32;
        end else begin
            ram_write_addr_o <= {ram_write_addr_i[31:2], 2'b00};
            ram_write_enable_o <= ram_write_enable_i;
            
            case (aluop_i)
                `ALUOP_SB : begin
                    ram_write_data_o <= {ram_write_data_i[7:0], ram_write_data_i[7:0], ram_write_data_i[7:0], ram_write_data_i[7:0]};
                    case (ram_write_addr_i[1:0])
                        2'b00 : ram_write_select_o <= 4'b0001;
                        2'b01 : ram_write_select_o <= 4'b0010;
                        2'b10 : ram_write_select_o <= 4'b0100;
                        2'b11 : ram_write_select_o <= 4'b1000;
                        default : ram_write_select_o <= 4'b0000;
                    endcase
                end
                `ALUOP_SH : begin
                    ram_write_data_o <= {ram_write_data_i[15:0], ram_write_data_i[15:0]};
                    case (ram_write_addr_i[1:0])
                        2'b00 : ram_write_select_o <= 4'b0011;
                        2'b10 : ram_write_select_o <= 4'b1100;
                        default : ram_write_select_o <= 4'b0000;
                    endcase
                end
                `ALUOP_SW : begin
                    ram_write_data_o <= ram_write_data_i;
                    ram_write_select_o <= 4'b1111;
                end
                default : begin
                    ram_write_data_o <= ram_write_data_i;
                    ram_write_select_o <= 4'b0000;
                end
            endcase
        end
    end
    
endmodule
