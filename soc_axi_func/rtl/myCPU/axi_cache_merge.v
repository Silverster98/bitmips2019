module axi_cache_merge
(
	input 	      inst_ren			,
    input  [31:0] inst_araddr       ,
    input         inst_arvalid      ,
    output        inst_arready      ,         
    output [31:0] inst_rdata        ,
    output        inst_rlast        ,
    output        inst_rvalid       ,
    output        inst_rready       ,

    input  	      data_ren			,
    input  [31:0] data_araddr       ,
    input         data_arvalid      ,
    output        data_arready      ,
    output [31:0] data_rdata        ,
    output        data_rlast        ,
    output        data_rvalid       ,
    output        data_rready       ,
	
	
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
    output        rready       
);

assign arvalid = data_arvalid | inst_arvalid;
assign arlen = 8'h0f;
assign arid = 4'b0000;
assign arsize = 3'b010;
assign arburst = 2'b01;
assign arlock = 2'b00;
assign arcache = 4'b0000;
assign arprot = 3'b000;
assign rready = 1'b1;

assign araddr = inst_ren? inst_araddr : data_araddr;

assign inst_arready = inst_ren ? arready : 1'b0;
assign data_arready = data_ren ? arready : 1'b0;

assign inst_rready = inst_ren ? rvalid : 1'b0; 
assign data_rready = data_ren ? rvalid : 1'b0;

assign inst_rlast = inst_ren ? rlast : 1'b0;
assign data_rlast = data_ren ? rlast : 1'b0;

assign inst_rdata = inst_ren ? rdata : inst_rdata;
assign data_rdata = data_ren ? rdata : data_rdata;

assign inst_rvalid = inst_ren ? rvalid : 1'b0;
assign data_rvalid = data_ren ? rvalid : 1'b0;

endmodule
