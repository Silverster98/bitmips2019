`include "defines.v"
module cp0(
input  wire                   clk,
input  wire                   rst,
input  wire                   cp0_write_enable,
input  wire [`GPR_ADDR_BUS]   cp0_write_addr_i,
input  wire [`GPR_BUS]        cp0_write_data_i,
input  wire [`GPR_ADDR_BUS]   cp0_read_addr_i,
input  wire [`EXCEP_TYPE_BUS] exception_type_i,
input  wire [`INST_BUS]       pc_i,
input  wire                   now_in_delayslot_i,        
output reg  [`GPR_BUS]        cp0_read_data_o,
output reg  [`GPR_BUS]        epc_o,
output reg  [`GPR_BUS]        status_o,
output reg  [`GPR_BUS]        cause_o,

// need to understan later
output reg                    pl_reset_o    
);

reg [`GPR_BUS] count;
reg [`GPR_BUS] compare;

reg pl_reset;
reg pl_flush;

reg hard_reset_pending;



function reg isExceptionAsserted;
	return pl_reset == 1 || pl_flush == 1;
endfunction

/*
always @ (posedge clk) begin
    if(rst == `RST_ENABLE) begin
        hard_reset_pending = 1'b1;
        pl_reset_o <= 1'b1;
    end 
    else begin
        if(is_exception_asserted) deassert_exception();
        update_timer();
        end
        if(hard_reset_pending) begin
            assert_reset();
            hard_reset_pending = 1'b0;
        end
        else if(int_reset) assert_soft_reset();
        else if(int_nmi) assert_nmi();
        else begin
            handle_exception();
            reg_cause_ip[1:0] <= intr_soft;
            if(!is_exception_asserted() && cmd_valid == 1'b1) begin
                case(cmd_op)
                    `CP0_CMD_READREG: cmd_read_reg();
					`CP0_CMD_WRITEREG: cmd_write_reg();
			    endcase
			end
	    end
        cmd_resp_o <= cmd_resp;
        cmd_error_o <= cmd_error;
        pl_reset_o <= pl_reset;
        pl_flush_o <= pl_flush;
        pl_rv_o <= pl_rv;
        intr_timer_o <= intr_timer;    
end*/
endmodule
