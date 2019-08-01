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
    output [3 :0] arid         ,
    output [31:0] araddr       ,
    output [3 :0] arlen        ,
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
    output [3 :0] awlen        ,
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

wire inst_cache;
wire data_cache;

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

wire [31:0]	cpu_to_inst_cache_araddr;
wire [1:0]  cpu_to_inst_cache_arbusrt;
wire [3:0]  cpu_to_inst_cache_arcache;
wire [3:0]  cpu_to_inst_cache_arid;
wire [7:0]  cpu_to_inst_cache_arlen;
wire [1:0]  cpu_to_inst_cache_arlock;
wire [2:0]  cpu_to_inst_cache_arprot;
wire 	 	cpu_to_inst_cache_arready;
wire [2:0]  cpu_to_inst_cache_arsize;
wire 		cpu_to_inst_cache_arvalid;
wire [1:0] cpu_to_inst_cache_arburst;
wire [31:0] cpu_to_inst_cache_awaddr;
wire [1:0]  cpu_to_inst_cache_awburst;
wire [3:0]  cpu_to_inst_cache_awcache;
wire [3:0]  cpu_to_inst_cache_awid;
wire [7:0]  cpu_to_inst_cache_awlen;
wire [1:0]  cpu_to_inst_cache_awlock;
wire [2:0]  cpu_to_inst_cache_awprot;
wire 		cpu_to_inst_cache_awready;
wire [2:0]  cpu_to_inst_cache_awsize;
wire 		cpu_to_inst_cache_awvalid;
wire [3:0]  cpu_to_inst_cache_bid;
wire 		cpu_to_inst_cache_bready;
wire [1:0]	cpu_to_inst_cache_bresp;
wire 		cpu_to_inst_cache_bvalid;
wire [31:0] cpu_to_inst_cache_rdata;
wire [3:0]  cpu_to_inst_cache_rid;
wire 		cpu_to_inst_cache_rlast;
wire 		cpu_to_inst_cache_rready;
wire [1:0]  cpu_to_inst_cache_rresp;
wire 		cpu_to_inst_cache_rvalid;
wire [31:0] cpu_to_inst_cache_wdata;
wire 		cpu_to_inst_cache_wlast;
wire 		cpu_to_inst_cache_wready;
wire [3:0]  cpu_to_inst_cache_wstrb;
wire 		cpu_to_inst_cache_wvalid;

cpu_axi_interface cpu_axi_interface_1
(
    .clk            (aclk      ),
    .resetn         (aresetn   ), 
    `ifdef cache
    .inst_cache     (inst_cache),
    .data_cache     (data_cache),
    `endif
    
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

    .araddr		(cpu_to_inst_cache_araddr),
    .arburst    (cpu_to_inst_cache_arbusrt),
    .arcache    (cpu_to_inst_cache_arcache),
    .arid       (cpu_to_inst_cache_arid),
    .arlen      (cpu_to_inst_cache_arlen),
    .arlock     (cpu_to_inst_cache_arlock),
    .arprot     (cpu_to_inst_cache_arprot),
    .arready    (cpu_to_inst_cache_arready),
    .arsize     (cpu_to_inst_cache_arsize),
    .arvalid    (cpu_to_inst_cache_arvalid),
    .awaddr     (awaddr),
    .awburst    (awburst),
    .awcache    (awcache),
    .awid       (awid),
    .awlen      (awlen),
    .awlock     (awlock),
    .awprot     (awprot),
    .awready    (awready),
    .awsize     (awsize),
    .awvalid    (awvalid),
    .bid        (bid),
    .bready     (bready),
    .bresp      (bresp),
    .bvalid     (bvalid),
    .rdata      (cpu_to_inst_cache_rdata),
    .rid        (cpu_to_inst_cache_rid),
    .rlast      (cpu_to_inst_cache_rlast),
    .rready     (cpu_to_inst_cache_rready),
    .rresp      (cpu_to_inst_cache_rresp),
    .rvalid     (cpu_to_inst_cache_rvalid),
    .wdata      (wdata),
    .wlast      (wlast),
    .wready     (wready),
    .wstrb      (wstrb),
    .wvalid     (wvalid)
);

wire [31:0]	inst_cache_to_bus_araddr;
wire [1:0]  inst_cache_to_bus_arburst;
wire [3:0]  inst_cache_to_bus_arcache;
wire [3:0]  inst_cache_to_bus_arid;
wire [7:0]  inst_cache_to_bus_arlen;
wire [1:0]  inst_cache_to_bus_arlock;
wire [2:0]  inst_cache_to_bus_arprot;
wire 	 	inst_cache_to_bus_arready;
wire [2:0]  inst_cache_to_bus_arsize;
wire 		inst_cache_to_bus_arvalid;
wire [31:0] inst_cache_to_bus_rdata;
wire [3:0]  inst_cache_to_bus_rid;
wire 		inst_cache_to_bus_rlast;
wire 		inst_cache_to_bus_rready;
wire [1:0]  inst_cache_to_bus_rresp;
wire 		inst_cache_to_bus_rvalid;


inst_cache_fifo inst_cache_fifo_1
(
.rst           (aresetn),
.clk           (aclk),
.m_arid        (arid),
.m_araddr      (araddr),
.m_arlen       (arlen),
.m_arsize      (arsize),
.m_arburst     (arburst),
.m_arlock      (arlock),
.m_arcache     (arcache),
.m_arprot      (arprot),
.m_arvalid     (arvalid),
.m_arready     (arready),
.m_rid         (rid),
.m_rdata       (rdata),
.m_rresp       (rresp),
.m_rlast       (rlast),
.m_rvalid      (rvalid),
.m_rready      (rready),

.s_arid         (cpu_to_inst_cache_arid),
.s_araddr       (cpu_to_inst_cache_araddr),
.s_arlen        (cpu_to_inst_cache_arlen),
.s_arsize       (cpu_to_inst_cache_arsize),
.s_arburst      (cpu_to_inst_cache_arburst),
.s_arlock       (cpu_to_inst_cache_arlock),
.s_arcache      (cpu_to_inst_cache_arcache),
.s_arprot       (cpu_to_inst_cache_arprot),
.s_arvalid      (cpu_to_inst_cache_arvalid),
.s_arready      (cpu_to_inst_cache_arready),
               
.s_rid          (cpu_to_inst_cache_rid),
.s_rdata        (cpu_to_inst_cache_rdata),
.s_rresp        (cpu_to_inst_cache_rresp),
.s_rlast        (cpu_to_inst_cache_rlast),
.s_rvalid       (cpu_to_inst_cache_rvalid),
.s_rready       (cpu_to_inst_cache_rready)
);

wire [3:0] arqos;
wire [3:0] awqos;
/*
axi_protocol_converter_0 axi_protocol_convert_0
(
    .aclk(aclk),
    .aresetn(aresetn),
    .m_axi_araddr(araddr),
    .m_axi_arburst(arburst),
    .m_axi_arcache(arcache),
    .m_axi_arid(arid),
    .m_axi_arlen(arlen),
    .m_axi_arlock(arlock),
    .m_axi_arprot(arprot),
    .m_axi_arqos(arqos),
    .m_axi_arready(arready),
    .m_axi_arsize(arsize),
    .m_axi_arvalid(arvalid),
    .m_axi_awaddr(awaddr),
    .m_axi_awburst(awburst),
    .m_axi_awcache(awcache),
    .m_axi_awid(awid),
    .m_axi_awlen(awlen),
    .m_axi_awlock(awlock),
    .m_axi_awprot(awprot),
    .m_axi_awqos(awqos),
    .m_axi_awready(awready),
    .m_axi_awsize(awsize),
    .m_axi_awvalid(awvalid),
    .m_axi_bid(bid),
    .m_axi_bready(bready),
    .m_axi_bresp(bresp),
    .m_axi_bvalid(bvalid),
    .m_axi_rdata(rdata),
    .m_axi_rid(rid),
    .m_axi_rlast(rlast),
    .m_axi_rready(rready),
    .m_axi_rresp(rresp),
    .m_axi_rvalid(rvalid),
    .m_axi_wdata(wdata),
    .m_axi_wid(wid),
    .m_axi_wlast(wlast),
    .m_axi_wready(wready),
    .m_axi_wstrb(wstrb),
    .m_axi_wvalid(wvalid),
  
    .s_axi_araddr            (inst_cache_to_bus_araddr)  ,
    .s_axi_arburst           (inst_cache_to_bus_arburst) ,
    .s_axi_arcache           (inst_cache_to_bus_arcache) ,
    .s_axi_arid              (inst_cache_to_bus_arid)    ,
    .s_axi_arlen             (inst_cache_to_bus_arlen)   ,
    .s_axi_arlock            (inst_cache_to_bus_arlock)  ,
    .s_axi_arprot            (inst_cache_to_bus_arprot)  ,
    .s_axi_arqos             (4'b0000)   ,
    .s_axi_arready           (inst_cache_to_bus_arready) ,
    .s_axi_arregion          (4'b0000),
    .s_axi_arsize            (inst_cache_to_bus_arsize)  ,
    .s_axi_arvalid           (inst_cache_to_bus_arvalid) ,
    .s_axi_awaddr            (cpu_to_inst_cache_awaddr)  ,
    .s_axi_awburst           (cpu_to_inst_cache_awburst) ,
    .s_axi_awcache           (cpu_to_inst_cache_awcache) ,
    .s_axi_awid              (cpu_to_inst_cache_awid)    ,
    .s_axi_awlen             (cpu_to_inst_cache_awlen)   ,
    .s_axi_awlock            (cpu_to_inst_cache_awlock)  ,
    .s_axi_awprot            (cpu_to_inst_cache_awprot)  ,
    .s_axi_awqos             (4'b0000),
    .s_axi_awready           (cpu_to_inst_cache_awready) ,
    .s_axi_awregion          (4'b0000),
    .s_axi_awsize            (cpu_to_inst_cache_awsize)  ,
    .s_axi_awvalid           (cpu_to_inst_cache_awvalid) ,
    .s_axi_bid               (cpu_to_inst_cache_bid)     ,
    .s_axi_bready            (cpu_to_inst_cache_bready)  ,
    .s_axi_bresp             (cpu_to_inst_cache_bresp)   ,
    .s_axi_bvalid            (cpu_to_inst_cache_bvalid)  ,
    .s_axi_rdata             (cpu_to_inst_cache_rdata)  ,
    .s_axi_rid               (inst_cache_to_bus_rid)     ,
    .s_axi_rlast             (inst_cache_to_bus_rlast)   ,
    .s_axi_rready            (inst_cache_to_bus_rready)  ,
    .s_axi_rresp             (inst_cache_to_bus_rresp)   ,
    .s_axi_rvalid            (inst_cache_to_bus_rvalid)  ,
    .s_axi_wdata             (cpu_to_inst_cache_wdata)   ,
    .s_axi_wlast             (cpu_to_inst_cache_wlast)   ,
    .s_axi_wready            (cpu_to_inst_cache_wready)  ,
    .s_axi_wstrb             (cpu_to_inst_cache_wstrb)   ,
    .s_axi_wvalid            (cpu_to_inst_cache_wvalid)
);
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
.clock(aclk),
.reset(aresetn),
.flush_i(flush),
.stall_i(5'b00000),
// sram
.cpu_addr_i(inst_sram_addr),
.cpu_data_o(inst_sram_rdata),
.stallreq(inst_stall),
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
endmodule

