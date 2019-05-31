/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Copyright (c) 2016, Loongson Technology Corporation Limited.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this 
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of Loongson Technology Corporation Limited nor the names of 
its contributors may be used to endorse or promote products derived from this 
software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL LOONGSON TECHNOLOGY CORPORATION LIMITED BE LIABLE
TO ANY PARTY FOR DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
module mycpu_top
(
    input  [4 :0] int          , 
    input         aclk         ,
    input         aresetn      ,
    output [3 :0] arid         ,
    output [31:0] araddr       ,
    output [7 :0] arlen        ,
    output [2 :0] arsize       ,
    output [1 :0] arburst      ,
    output [1 :0] arlock       ,
    output [3 :0] arcache      ,
    output [2 :0] arprot       ,
    output        arvalid      ,
    input         arready      ,
    //r           
    input  [3 :0] rid          ,
    input  [31:0] rdata        ,
    input  [1 :0] rresp        ,
    input         rlast        ,
    input         rvalid       ,
    output        rready       ,
    //aw          
    output [3 :0] awid         ,
    output [31:0] awaddr       ,
    output [7 :0] awlen        ,
    output [2 :0] awsize       ,
    output [1 :0] awburst      ,
    output [1 :0] awlock       ,
    output [3 :0] awcache      ,
    output [2 :0] awprot       ,
    output        awvalid      ,
    input         awready      ,
    //w          
    output [3 :0] wid          ,
    output [31:0] wdata        ,
    output [3 :0] wstrb        ,
    output        wlast        ,
    output        wvalid       ,
    input         wready       ,
    //b           
    input  [3 :0] bid          ,
    input  [1 :0] bresp        ,
    input         bvalid       ,
    output        bready       ,
    
    output [31:0] debug_wb_pc       , 
    output [3:0]  debug_wb_rf_wen   ,
    output [4:0]  debug_wb_rf_wnum  ,
    output [31:0] debug_wb_rf_wdata 
);

wire        inst_req;
wire        inst_wr;
wire [1:0]  inst_size;
wire [31:0] inst_addr;
wire [31:0] inst_wdata;
wire [31:0] inst_rdata;
wire        inst_addr_ok;
wire        inst_data_ok;
wire        data_req;
wire        data_wr;
wire [1:0]  data_size;
wire [31:0] data_addr;
wire [31:0] data_wdata;
wire [31:0] data_rdata;
wire        data_addr_ok;
wire        data_data_ok;

cpu_axi_interface cpu_axi_interface_1
(
    .clk            (aclk      ),
    .resetn         (aresetn   ), 

    
    .inst_req       (inst_req    ),
    .inst_wr        (inst_wr     ),
    .inst_size      (inst_size   ),
    .inst_addr      (inst_addr   ),
    .inst_wdata     (inst_wdata  ),
    .inst_rdata     (inst_rdata  ),
    .inst_addr_ok   (inst_addr_ok),
    .inst_data_ok   (inst_data_ok),
    

    .data_req       (data_req    ),
    .data_wr        (data_wr     ),
    .data_size      (data_size   ),
    .data_addr      (data_addr   ),
    .data_wdata     (data_wdata  ),
    .data_rdata     (data_rdata  ),
    .data_addr_ok   (data_addr_ok),
    .data_data_ok   (data_data_ok),

    .arid           (arid        ),
    .araddr         (araddr      ),
    .arlen          (arlen       ),
    .arsize         (arsize      ),
    .arburst        (arburst     ),
    .arlock         (arlock      ),
    .arcache        (arcache     ),
    .arprot         (arprot      ),
    .arvalid        (arvalid     ),
    .arready        (arready     ),
                                
    .rid            (rid         ),
    .rdata          (rdata       ),
    .rresp          (rresp       ),
    .rlast          (rlast       ),
    .rvalid         (rvalid      ),
    .rready         (rready      ),
                                
    .awid           (awid        ),
    .awaddr         (awaddr      ),
    .awlen          (awlen       ),
    .awsize         (awsize      ),
    .awburst        (awburst     ),
    .awlock         (awlock      ),
    .awcache        (awcache     ),
    .awprot         (awprot      ),
    .awvalid        (awvalid     ),
    .awready        (awready     ),
                                
    .wid            (wid         ),
    .wdata          (wdata       ),
    .wstrb          (wstrb       ),
    .wlast          (wlast       ),
    .wvalid         (wvalid      ),
    .wready         (wready      ),
                                
    .bid            (bid         ),
    .bresp          (bresp       ),
    .bvalid         (bvalid      ),
    .bready         (bready      )
);


/*
assign inst_sram_en = (resetn == `RST_ENABLE) ? 1'b0 : 1'b1;
assign inst_sram_wen = 4'b0000;

assign data_sram_en = (resetn == `RST_ENABLE) ? 1'b0 : 1'b1;

wire time_int_out;
wire[31:0] _data_ram_addr;

reg[31:0] inst_addr;
reg[31:0] data_addr;
reg inst_stall, data_stall;
wire data_sram_read_enable;

assign data_sram_addr = (_data_ram_addr[31:30] == 2'b11) ? _data_ram_addr : {3'b000, _data_ram_addr[28:0]}; // mmu
*/
wire        time_int_out;
wire [31:0] inst_sram_addr;
wire [31:0] inst_sram_rdata;
wire        inst_stall;

wire        data_sram_ren;
wire [3:0]  data_sram_wen;
wire [31:0] data_sram_addr;
wire [31:0] data_sram_wdata;
wire [31:0] data_sram_rdata;
wire        data_stall;
wire        flush;

mips_top mips_core(
.clk(aclk),
.rst(aresetn),
.flush(flush),
.interrupt({time_int_out || int[5],int[4:0]}),
.time_int_out(time_int_out),
.inst_sram_addr(inst_sram_addr),
.inst_sram_rdata(inst_sram_rdata),

.data_sram_ren(data_sram_ren),
.data_sram_wen(data_sram_wen),
.data_sram_addr(data_sram_addr),
.data_sram_wdata(data_sram_wdata),
.data_sram_rdata(data_sram_rdata),

.debug_wb_pc(debug_wb_pc),
.debug_wb_wen(debug_wb_rf_wen),
.debug_wb_num(debug_wb_rf_wnum),
.debug_wb_data(debug_wb_rf_wdata),

.inst_stall(inst_stall),
.data_stall(data_stall)
);

inst_sram_to_sram_like inst_sram_convert
(
.clk(aclk),
.rst(aresetn),
.flush(flush),
// sram
.inst_sram_addr(inst_sram_addr),
.inst_sram_rdata(inst_sram_rdata),
.inst_stall(inst_stall),
//instr sram_like
.inst_req(inst_req),
.inst_wr(inst_wr),
.inst_size(inst_size),
.inst_addr(inst_addr),
.inst_wdata(inst_wdata),
.inst_rdata(inst_rdata),
.inst_addr_ok(inst_addr_ok),
.inst_data_ok(inst_data_ok)
);

data_sram_to_sram_like data_sram_convert
(
.clk(aclk),
.rst(aresetn),
.flush(flush),
// sram
.data_sram_i(data_sram_wdata),
.addr_sram_i(data_sram_addr),
.wen_sram_i(data_sram_wen),
.ren_sram_i(data_sram_ren),
.data_sram_o(data_sram_rdata),           
.data_stall(data_stall),
//datar sram_like
.data_req(data_req),
.data_wr(data_wr),
.data_size(data_size),
.data_addr(data_addr),
.data_wdata(data_wdata),
.data_rdata(data_rdata),
.data_addr_ok(data_addr_ok),
.data_data_ok(data_data_ok)
);

/*
always @ (negedge clk) begin
    if (resetn == `RST_ENABLE) begin
        inst_addr <= 32'b0;
        inst_stall <= 1'b0;
    end else begin
        if (inst_addr != inst_sram_addr) begin
            inst_addr <= inst_sram_addr;
            inst_stall <= 1'b1;
        end else begin
            inst_stall <= 1'b0;
        end
    end
end

always @ (negedge clk) begin
    if (resetn == `RST_ENABLE) begin
        data_addr <= 32'b0;
        data_stall <= 1'b0;
    end else begin
        if (data_addr != data_sram_addr && data_sram_read_enable == 1'b1) begin
            data_addr <= data_sram_addr;
            data_stall <= 1'b1;
        end else begin
            data_stall <= 1'b0;
            data_addr <= `ZEROWORD32;
        end
    end
end
*/
endmodule
