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

wire        inst_req;
wire        inst_wr;
wire [1:0]  inst_size;
wire [31:0] inst_addr;
wire [31:0] inst_wdata;
wire [31:0] inst_rdata;
wire        inst_addr_ok;
wire        inst_data_ok;
wire        inst_cache;
wire        data_req;
wire        data_wr;
wire [1:0]  data_size;
wire [31:0] data_addr;
wire [31:0] data_wdata;
wire [31:0] data_rdata;
wire        data_addr_ok;
wire        data_data_ok;
wire        data_cache;


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
wire        convert_flush;

//inst axi
//ar
wire [3 :0] inst_cache_arid         ;
wire [31:0] inst_cache_araddr       ;
wire [7 :0] inst_cache_arlen        ;
wire [2 :0] inst_cache_arsize       ;
wire [1 :0] inst_cache_arburst      ;
wire [1 :0] inst_cache_arlock       ;
wire [3 :0] inst_cache_arcache      ;
wire [2 :0] inst_cache_arprot       ;
wire        inst_cache_arvalid      ;
wire        inst_cache_arready      ;
//r
wire [3 :0] inst_cache_rid          ;
wire [31:0] inst_cache_rdata        ;
wire [1 :0] inst_cache_rresp        ;
wire        inst_cache_rlast        ;
wire        inst_cache_rvalid       ;
wire        inst_cache_rready       ;
//aw
wire [3 :0] inst_cache_awid         ;
wire [31:0] inst_cache_awaddr       ;
wire [7 :0] inst_cache_awlen        ;
wire [2 :0] inst_cache_awsize       ;
wire [1 :0] inst_cache_awburst      ;
wire [1 :0] inst_cache_awlock       ;
wire [3 :0] inst_cache_awcache      ;
wire [2 :0] inst_cache_awprot       ;
wire        inst_cache_awvalid      ;
wire        inst_cache_awready      ;
//w
wire [3 :0] inst_cache_wid          ;
wire [31:0] inst_cache_wdata        ;
wire [3 :0] inst_cache_wstrb        ;
wire        inst_cache_wlast        ;
wire        inst_cache_wvalid       ;
wire        inst_cache_wready       ;
//b
wire [3 :0] inst_cache_bid          ;
wire [1 :0] inst_cache_bresp        ;
wire        inst_cache_bvalid       ;
wire        inst_cache_bready       ;

//data axi
//ar
wire [3 :0] data_cache_arid         ;
wire [31:0] data_cache_araddr       ;
wire [7 :0] data_cache_arlen        ;
wire [2 :0] data_cache_arsize       ;
wire [1 :0] data_cache_arburst      ;
wire [1 :0] data_cache_arlock       ;
wire [3 :0] data_cache_arcache      ;
wire [2 :0] data_cache_arprot       ;
wire        data_cache_arvalid      ;
wire        data_cache_arready      ;
//r
wire [3 :0] data_cache_rid          ;
wire [31:0] data_cache_rdata        ;
wire [1 :0] data_cache_rresp        ;
wire        data_cache_rlast        ;
wire        data_cache_rvalid       ;
wire        data_cache_rready       ;
//aw
wire [3 :0] data_cache_awid         ;
wire [31:0] data_cache_awaddr       ;
wire [7 :0] data_cache_awlen        ;
wire [2 :0] data_cache_awsize       ;
wire [1 :0] data_cache_awburst      ;
wire [1 :0] data_cache_awlock       ;
wire [3 :0] data_cache_awcache      ;
wire [2 :0] data_cache_awprot       ;
wire        data_cache_awvalid      ;
wire        data_cache_awready      ;
//w
wire [3 :0] data_cache_wid          ;
wire [31:0] data_cache_wdata        ;
wire [3 :0] data_cache_wstrb        ;
wire        data_cache_wlast        ;
wire        data_cache_wvalid       ;
wire        data_cache_wready       ;
//b
wire [3 :0] data_cache_bid          ;
wire [1 :0] data_cache_bresp        ;
wire        data_cache_bvalid       ;
wire        data_cache_bready       ;

mips_top mips_core(
.clk(aclk),
.rst(aresetn),
.flush(flush),
//.convert_flush(convert_flush),
.interrupt({time_int_out || int[5],int[4:0]}),
.time_int_out(time_int_out),
.inst_sram_addr(inst_sram_addr),
.inst_sram_rdata(inst_sram_rdata),
.inst_sram_cache(inst_cache),

.data_sram_ren(data_sram_ren),
.data_sram_wen(data_sram_wen),
.data_sram_addr(data_sram_addr),
.data_sram_wdata(data_sram_wdata),
.data_sram_rdata(data_sram_rdata),
.data_sram_cache(data_cache),

.debug_wb_pc(debug_wb_pc),
.debug_wb_wen(),
//.debug_wb_wen(debug_wb_rf_wen),
.debug_wb_num(debug_wb_rf_wnum),
.debug_wb_data(debug_wb_rf_wdata),

.inst_stall(inst_stall),
.data_stall(data_stall)
);

assign debug_wb_rf_wen = 4'b0000;

data_sram_to_sram_like data_sram_to_sram_like_0(
    .clk(aclk),
    .rst(aresetn),         
    
    //sram
    .flush(flush),  
    .data_sram_wdata(data_sram_wdata),
    .data_sram_addr(data_sram_addr),
    .data_sram_wen(data_sram_wen),
    .data_sram_en(data_sram_ren || |data_sram_wen),
    .data_sram_rdata(data_sram_rdata),
    .data_stall(data_stall), 
    //sram like
    .data_req(data_req),
    .data_wr(data_wr),
    .data_size(data_size),
    .data_addr(data_addr),
    .data_wdata(data_wdata),
    .data_rdata(data_rdata),
    .data_addr_ok(data_addr_ok),
    .data_data_ok(data_data_ok) 
);

inst_sram_to_sram_like inst_sram_to_sram_like_0(
    .clk(aclk),
    .rst(aresetn),
    //sram
    .flush(flush),
    .inst_sram_addr(inst_sram_addr),
    .inst_sram_rdata(inst_sram_rdata),
    .inst_stall(inst_stall),
    //sram like
    .inst_req(inst_req),
    .inst_wr(inst_wr),
    .inst_size(inst_size),
    .inst_addr(inst_addr),
    .inst_wdata(inst_wdata),
    .inst_rdata(inst_rdata),
    .inst_addr_ok(inst_addr_ok),
    .inst_data_ok(inst_data_ok)
);

inst_cache inst_cache_0(
    .clk(aclk),
    .rstn(aresetn),
    
    // axi
    // ar
    .arid   (   inst_cache_arid         ),
    .araddr (   inst_cache_araddr       ),
    .arlen  (   inst_cache_arlen        ),
    .arsize (   inst_cache_arsize       ),
    .arburst(   inst_cache_arburst      ),
    .arlock (   inst_cache_arlock       ),
    .arcache(   inst_cache_arcache      ),
    .arprot (   inst_cache_arprot       ),
    .arvalid(   inst_cache_arvalid      ),
    .arready(   inst_cache_arready      ),
    //r
    .rid    (   inst_cache_rid          ),
    .rdata  (   inst_cache_rdata        ),
    .rresp  (   inst_cache_rresp        ),
    .rlast  (   inst_cache_rlast        ),
    .rvalid (   inst_cache_rvalid       ),
    .rready (   inst_cache_rready       ),
    //aw
    .awid   (   inst_cache_awid         ),
    .awaddr (   inst_cache_awaddr       ),
    .awlen  (   inst_cache_awlen        ),
    .awsize (   inst_cache_awsize       ),
    .awburst(   inst_cache_awburst      ),
    .awlock (   inst_cache_awlock       ),
    .awcache(   inst_cache_awcache      ),
    .awprot (   inst_cache_awprot       ),
    .awvalid(   inst_cache_awvalid      ),
    .awready(   inst_cache_awready      ),
    //w
    .wid    (   inst_cache_wid          ),
    .wdata  (   inst_cache_wdata        ),
    .wstrb  (   inst_cache_wstrb        ),
    .wlast  (   inst_cache_wlast        ),
    .wvalid (   inst_cache_wvalid       ),
    .wready (   inst_cache_wready       ),
    //b
    .bid    (   inst_cache_bid          ),
    .bresp  (   inst_cache_bresp        ),
    .bvalid (   inst_cache_bvalid       ),
    .bready (   inst_cache_bready       ),
    
    // from cpu, sram like
    .inst_req(inst_req),
    .inst_wr(inst_wr),
    .inst_size(inst_size),
    .inst_addr(inst_addr),
    .inst_wdata(inst_wdata),
    .inst_addr_ok(inst_addr_ok),
    .inst_data_ok(inst_data_ok),
    .inst_rdata(inst_rdata),
    
    .inst_cache(inst_cache)
);

data_cache data_cache_0(
    .clk(aclk),
    .rstn(aresetn),
    
    // axi
    // ar
    .arid   (   data_cache_arid         ),
    .araddr (   data_cache_araddr       ),
    .arlen  (   data_cache_arlen        ),
    .arsize (   data_cache_arsize       ),
    .arburst(   data_cache_arburst      ),
    .arlock (   data_cache_arlock       ),
    .arcache(   data_cache_arcache      ),
    .arprot (   data_cache_arprot       ),
    .arvalid(   data_cache_arvalid      ),
    .arready(   data_cache_arready      ),
    //r
    .rid    (   data_cache_rid          ),
    .rdata  (   data_cache_rdata        ),
    .rresp  (   data_cache_rresp        ),
    .rlast  (   data_cache_rlast        ),
    .rvalid (   data_cache_rvalid       ),
    .rready (   data_cache_rready       ),
    //aw
    .awid   (   data_cache_awid         ),
    .awaddr (   data_cache_awaddr       ),
    .awlen  (   data_cache_awlen        ),
    .awsize (   data_cache_awsize       ),
    .awburst(   data_cache_awburst      ),
    .awlock (   data_cache_awlock       ),
    .awcache(   data_cache_awcache      ),
    .awprot (   data_cache_awprot       ),
    .awvalid(   data_cache_awvalid      ),
    .awready(   data_cache_awready      ),
    //w
    .wid    (   data_cache_wid          ),
    .wdata  (   data_cache_wdata        ),
    .wstrb  (   data_cache_wstrb        ),
    .wlast  (   data_cache_wlast        ),
    .wvalid (   data_cache_wvalid       ),
    .wready (   data_cache_wready       ),
    //b
    .bid    (   data_cache_bid          ),
    .bresp  (   data_cache_bresp        ),
    .bvalid (   data_cache_bvalid       ),
    .bready (   data_cache_bready       ),
    
    // from cpu, sram like
    .data_req(data_req),
    .data_wr(data_wr),
    .data_size(data_size),
    .data_addr(data_addr),
    .data_wdata(data_wdata),
    .data_addr_ok(data_addr_ok),
    .data_data_ok(data_data_ok),
    .data_rdata(data_rdata),
    
    .data_cache(data_cache)
);

axi_crossbar_0 axi_cache_bridge_0 (
    .aclk         ( aclk),                   // input wire aclk
    .aresetn      ( aresetn),                // input wire aresetn
    .s_axi_awid   ( {data_cache_awid        ,inst_cache_awid        }),
    .s_axi_awaddr ( {data_cache_awaddr      ,inst_cache_awaddr      }),
    .s_axi_awlen  ( {data_cache_awlen[3:0]  ,inst_cache_awlen[3:0]  }),
    .s_axi_awsize ( {data_cache_awsize      ,inst_cache_awsize      }),
    .s_axi_awburst( {data_cache_awburst     ,inst_cache_awburst     }),
    .s_axi_awlock ( {data_cache_awlock      ,inst_cache_awlock      }),
    .s_axi_awcache( {data_cache_awcache     ,inst_cache_awcache     }),
    .s_axi_awprot ( {data_cache_awprot      ,inst_cache_awprot      }),
    .s_axi_awqos  ( {4'b0                   ,4'b0                   }),
    .s_axi_awvalid( {data_cache_awvalid     ,inst_cache_awvalid     }),
    .s_axi_awready( {data_cache_awready     ,inst_cache_awready     }),
    .s_axi_wid    ( {data_cache_wid         ,inst_cache_wid         }),
    .s_axi_wdata  ( {data_cache_wdata       ,inst_cache_wdata       }),
    .s_axi_wstrb  ( {data_cache_wstrb       ,inst_cache_wstrb       }),
    .s_axi_wlast  ( {data_cache_wlast       ,inst_cache_wlast       }),
    .s_axi_wvalid ( {data_cache_wvalid      ,inst_cache_wvalid      }),
    .s_axi_wready ( {data_cache_wready      ,inst_cache_wready      }),
    .s_axi_bid    ( {data_cache_bid         ,inst_cache_bid         }),
    .s_axi_bresp  ( {data_cache_bresp       ,inst_cache_bresp       }),
    .s_axi_bvalid ( {data_cache_bvalid      ,inst_cache_bvalid      }),
    .s_axi_bready ( {data_cache_bready      ,inst_cache_bready      }),
    .s_axi_arid   ( {data_cache_arid        ,inst_cache_arid        }),
    .s_axi_araddr ( {data_cache_araddr      ,inst_cache_araddr      }),
    .s_axi_arlen  ( {data_cache_arlen[3:0]  ,inst_cache_arlen[3:0]  }),
    .s_axi_arsize ( {data_cache_arsize      ,inst_cache_arsize      }),
    .s_axi_arburst( {data_cache_arburst     ,inst_cache_arburst     }),
    .s_axi_arlock ( {data_cache_arlock      ,inst_cache_arlock      }),
    .s_axi_arcache( {data_cache_arcache     ,inst_cache_arcache     }),
    .s_axi_arprot ( {data_cache_arprot      ,inst_cache_arprot      }),
    .s_axi_arqos  ( {4'b0                   ,4'b0                   }),
    .s_axi_arvalid( {data_cache_arvalid     ,inst_cache_arvalid     }),
    .s_axi_arready( {data_cache_arready     ,inst_cache_arready     }),
    .s_axi_rid    ( {data_cache_rid         ,inst_cache_rid         }),
    .s_axi_rdata  ( {data_cache_rdata       ,inst_cache_rdata       }),
    .s_axi_rresp  ( {data_cache_rresp       ,inst_cache_rresp       }),
    .s_axi_rlast  ( {data_cache_rlast       ,inst_cache_rlast       }),
    .s_axi_rvalid ( {data_cache_rvalid      ,inst_cache_rvalid      }),
    .s_axi_rready ( {data_cache_rready      ,inst_cache_rready      }),
    .m_axi_awid   ( awid        ),
    .m_axi_awaddr ( awaddr      ),
    .m_axi_awlen  ( awlen[3:0]  ),
    .m_axi_awsize ( awsize      ),
    .m_axi_awburst( awburst     ),
    .m_axi_awlock ( awlock      ),
    .m_axi_awcache( awcache     ),
    .m_axi_awprot ( awprot      ),
    .m_axi_awqos  (             ),
    .m_axi_awvalid( awvalid     ),
    .m_axi_awready( awready     ),
    .m_axi_wid    ( wid         ),
    .m_axi_wdata  ( wdata       ),
    .m_axi_wstrb  ( wstrb       ),
    .m_axi_wlast  ( wlast       ),
    .m_axi_wvalid ( wvalid      ),
    .m_axi_wready ( wready      ),
    .m_axi_bid    ( bid         ),
    .m_axi_bresp  ( bresp       ),
    .m_axi_bvalid ( bvalid      ),
    .m_axi_bready ( bready      ),
    .m_axi_arid   ( arid        ),
    .m_axi_araddr ( araddr      ),
    .m_axi_arlen  ( arlen[3:0]  ),
    .m_axi_arsize ( arsize      ),
    .m_axi_arburst( arburst     ),
    .m_axi_arlock ( arlock      ),
    .m_axi_arcache( arcache     ),
    .m_axi_arprot ( arprot      ),
    .m_axi_arqos  (             ),
    .m_axi_arvalid( arvalid     ),
    .m_axi_arready( arready     ),
    .m_axi_rid    ( rid         ),
    .m_axi_rdata  ( rdata       ),
    .m_axi_rresp  ( rresp       ),
    .m_axi_rlast  ( rlast       ),
    .m_axi_rvalid ( rvalid      ),
    .m_axi_rready ( rready      ) 
);

endmodule
