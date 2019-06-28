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
    input  [5 :0] int          , 
    input         aclk         ,
    input         aresetn      ,
    //ar
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
    
   (*mark_debug = "true"*) output [31:0] debug_wb_pc       , 
   (*mark_debug = "true"*) output [3:0]  debug_wb_rf_wen   ,
   (*mark_debug = "true"*) output [4:0]  debug_wb_rf_wnum  ,
   (*mark_debug = "true"*) output [31:0] debug_wb_rf_wdata 
);

wire        time_int_out;
wire        flush;

wire [31:0] inst_sram_addr;
wire [31:0] inst_sram_rdata;
wire        inst_stall;

wire        data_sram_ren;
wire [3:0]  data_sram_wen;
wire [31:0] data_sram_addr;
wire [31:0] data_sram_wdata;
wire [31:0] data_sram_rdata;
wire        data_stall;

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


bit_axi_interface axi_interface(
.inst_or_data(), // for cache, 1 is data, 0 is inst

.clk(aclk),
.rst(aresetn),
.flush(flush),

.inst_sram_addr(inst_sram_addr),
.inst_sram_rdata(inst_sram_rdata),
.inst_stall(inst_stall),

.data_sram_addr(data_sram_addr),
.data_sram_ren(data_sram_ren),
.data_sram_rdata(data_sram_rdata),
.data_sram_wen(data_sram_wen),
.data_sram_wdata(data_sram_wdata),
.data_stall(data_stall),

//axi
//ar
.arid(arid),
.araddr(araddr),
.arlen(arlen),
.arsize(arsize),
.arburst(arburst),
.arlock(arlock),
.arcache(arcache),
.arprot(arprot),
.arvalid(arvalid),
.arready(arready),

//r
.rid(rid),
.rdata(rdata),
.rresp(rresp),
.rlast(rlast),
.rvalid(rvalid),
.rready(rready),

//aw
.awid(awid),
.awaddr(awaddr),
.awlen(awlen),
.awsize(awsize),
.awburst(awburst),
.awlock(awlock),
.awcache(awcache),
.awprot(awprot),
.awvalid(awvalid),
.awready(awready),

//w
.wid(wid),
.wdata(wdata),
.wstrb(wstrb),
.wlast(wlast),
.wvalid(wvalid),
.wready(wready),

//b
.bid(bid),
.bresp(bresp),
.bvalid(bvalid),
.bready(bready)
);

endmodule
