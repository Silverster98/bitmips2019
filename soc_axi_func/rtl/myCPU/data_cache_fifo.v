`include "defines.v"
module data_cache_fifo(
    input         clk            ,
    input         rst            ,
    input         cache_ena      ,
    output [31:0] m_araddr       ,
    output        m_arvalid      ,
    input         m_arready      ,
    
    input  [31:0] m_rdata        ,
    input         m_rlast        ,
    input         m_rvalid       ,
    output        m_rready       ,
    
    output [3:0]  m_awid         ,
    output [7 :0] m_awlen        ,
    output [2 :0] m_awsize       ,
    output [1 :0] m_awburst      ,
    output [1 :0] m_awlock       ,
    output [3 :0] m_awcache      ,
    output [2 :0] m_awprot       ,
    output [31:0] m_awaddr       ,
    output        m_awvalid      ,
    input         m_awready      ,
    
    output [3:0]  m_wid          ,         
    output [31:0] m_wdata        ,
    output        m_wlast        ,
    output [3:0]  m_wstrb        ,
    output        m_wvalid       ,
    input         m_wready       ,

    input         m_bvalid       ,
    output        m_bready       ,
	
    input  [31:0] s_addr         ,
    input         s_arvalid      ,
    output [31:0] s_rdata        ,
    output        s_rvalid       ,
    
    input  [3:0]  s_awvalid      ,
    input  [31:0] s_wdata        ,
    output        s_wready
);
  
reg [23:0] set0_0_addr;
reg [23:0] set0_1_addr;
reg [23:0] set0_2_addr;
reg [23:0] set0_3_addr;
reg [23:0] set1_0_addr;
reg [23:0] set1_1_addr;
reg [23:0] set1_2_addr;
reg [23:0] set1_3_addr;
reg [23:0] set2_0_addr;
reg [23:0] set2_1_addr;
reg [23:0] set2_2_addr;
reg [23:0] set2_3_addr;
reg [23:0] set3_0_addr;
reg [23:0] set3_1_addr;
reg [23:0] set3_2_addr;
reg [23:0] set3_3_addr;

reg [513:0] set0[3:0];
reg [513:0] set1[3:0];
reg [513:0] set2[3:0];
reg [513:0] set3[3:0];

reg [3:0] set0_empty;
reg [3:0] set1_empty;
reg [3:0] set2_empty;
reg [3:0] set3_empty;

reg [3:0] set0_dirty;
reg [3:0] set1_dirty;
reg [3:0] set2_dirty;
reg [3:0] set3_dirty;

reg [31:0]  s_addr_r;
reg         s_rvalid_r;
reg [31:0]  s_rdata_r;
reg         m_wvalid_r;
reg         m_awvalid_r;
reg         m_arvalid_r;
reg [31:0]  m_araddr_r;
reg [31:0]  m_awaddr_r;
reg [31:0]  m_wdata_r;
reg         m_wlast_r;
reg         s_wready_r;

reg         tag;
reg [1:0]   set;
reg         bus_addr_ok;
reg [31:0]  hit_cache_data;
reg         hit;
reg         dirty;
reg         set0_hit;
reg         set1_hit;
reg         set2_hit;
reg         set3_hit;
reg [1:0]   set0_ptr;
reg [1:0]   set1_ptr;
reg [1:0]   set2_ptr;
reg [1:0]   set3_ptr;
reg [1:0]   set0_hit_ptr;
reg [1:0]   set1_hit_ptr;
reg [1:0]   set2_hit_ptr;
reg [1:0]   set3_hit_ptr;
reg [4:0]   state;
reg [3:0]   cacheline_ptr;
reg [3:0]   cacheline_write_ptr;
reg         is_empty;
reg         is_read;
parameter [4:0] state_idle = 5'b00000;
parameter [4:0] state_read_hit = 5'b00001;
parameter [4:0] state_read_miss_wait_write_burst = 5'b00010;
parameter [4:0] state_read_miss_wait_bvalid = 5'b00011;
parameter [4:0] state_read_miss_wait_read_burst = 5'b00100;
parameter [4:0] state_read_miss_wait_finish = 5'b00101;
parameter [4:0] state_write_hit = 5'b00110;
parameter [4:0] state_write_miss_wait_write_burst = 5'b00111;
parameter [4:0] state_write_miss_wait_bvalid = 5'b01000;
parameter [4:0] state_write_miss_wait_read_burst = 5'b01001;
parameter [4:0] state_write_miss_wait_finish = 5'b01010;
parameter [4:0] state_read_uncache_wait_ram= 5'b01011;
parameter [4:0] state_read_uncache_wait_finish = 5'b01100;
parameter [4:0] state_write_uncache_wait_ram = 5'b01101;
parameter [4:0] state_write_uncache_wait_finish = 5'b01110;
parameter [4:0] state_write_empty = 5'b01111;
parameter [4:0] state_write_miss_wait_write_tag = 5'b10000;
parameter [4:0] state_read_miss_wait_write_tag = 5'b10001;
parameter [4:0] state_write_hit_write_data = 5'b10010;
parameter [4:0] state_read_hit_read_data = 5'b10011;

task cacheline_byte_write_data(output [513:0] cacheline, input [3:0] wen, input [31:0] write_data);
begin
    if(hit || is_empty) cacheline_write_ptr = s_addr_r[5:2];
    if(wen[3] == 1'b1) begin
    case(cacheline_write_ptr)
    4'h0:   cacheline[`addr_byte3_0]  =  write_data[31:24];
    4'h1:   cacheline[`addr_byte3_1]  =  write_data[31:24];
    4'h2:   cacheline[`addr_byte3_2]  =  write_data[31:24];
    4'h3:   cacheline[`addr_byte3_3]  =  write_data[31:24];
    4'h4:   cacheline[`addr_byte3_4]  =  write_data[31:24];
    4'h5:   cacheline[`addr_byte3_5]  =  write_data[31:24];
    4'h6:   cacheline[`addr_byte3_6]  =  write_data[31:24];
    4'h7:   cacheline[`addr_byte3_7]  =  write_data[31:24];
    4'h8:   cacheline[`addr_byte3_8]  =  write_data[31:24];
    4'h9:   cacheline[`addr_byte3_9]  =  write_data[31:24];
    4'ha:   cacheline[`addr_byte3_10] =  write_data[31:24];
    4'hb:   cacheline[`addr_byte3_11] =  write_data[31:24];
    4'hc:   cacheline[`addr_byte3_12] =  write_data[31:24];
    4'hd:   cacheline[`addr_byte3_13] =  write_data[31:24];
    4'he:   cacheline[`addr_byte3_14] =  write_data[31:24];
    4'hf:   cacheline[`addr_byte3_15] =  write_data[31:24];
    endcase
    end
    if(wen[2] == 1'b1) begin
    case(cacheline_write_ptr)
    4'h0:   cacheline[`addr_byte2_0]  =  write_data[23:16];
    4'h1:   cacheline[`addr_byte2_1]  =  write_data[23:16];
    4'h2:   cacheline[`addr_byte2_2]  =  write_data[23:16];
    4'h3:   cacheline[`addr_byte2_3]  =  write_data[23:16];
    4'h4:   cacheline[`addr_byte2_4]  =  write_data[23:16];
    4'h5:   cacheline[`addr_byte2_5]  =  write_data[23:16];
    4'h6:   cacheline[`addr_byte2_6]  =  write_data[23:16];
    4'h7:   cacheline[`addr_byte2_7]  =  write_data[23:16];
    4'h8:   cacheline[`addr_byte2_8]  =  write_data[23:16];
    4'h9:   cacheline[`addr_byte2_9]  =  write_data[23:16];
    4'ha:   cacheline[`addr_byte2_10] =  write_data[23:16];
    4'hb:   cacheline[`addr_byte2_11] =  write_data[23:16];
    4'hc:   cacheline[`addr_byte2_12] =  write_data[23:16];
    4'hd:   cacheline[`addr_byte2_13] =  write_data[23:16];
    4'he:   cacheline[`addr_byte2_14] =  write_data[23:16];
    4'hf:   cacheline[`addr_byte2_15] =  write_data[23:16];
    endcase
    end
    if(wen[1] == 1'b1) begin
    case(cacheline_write_ptr)
	4'h0:   cacheline[`addr_byte1_0]  =  write_data[15:8];
    4'h1:   cacheline[`addr_byte1_1]  =  write_data[15:8];
    4'h2:   cacheline[`addr_byte1_2]  =  write_data[15:8];
    4'h3:   cacheline[`addr_byte1_3]  =  write_data[15:8];
    4'h4:   cacheline[`addr_byte1_4]  =  write_data[15:8];
    4'h5:   cacheline[`addr_byte1_5]  =  write_data[15:8];
    4'h6:   cacheline[`addr_byte1_6]  =  write_data[15:8];
    4'h7:   cacheline[`addr_byte1_7]  =  write_data[15:8];
    4'h8:   cacheline[`addr_byte1_8]  =  write_data[15:8];
    4'h9:   cacheline[`addr_byte1_9]  =  write_data[15:8];
    4'ha:   cacheline[`addr_byte1_10] =  write_data[15:8];
    4'hb:   cacheline[`addr_byte1_11] =  write_data[15:8];
    4'hc:   cacheline[`addr_byte1_12] =  write_data[15:8];
    4'hd:   cacheline[`addr_byte1_13] =  write_data[15:8];
    4'he:   cacheline[`addr_byte1_14] =  write_data[15:8];
    4'hf:   cacheline[`addr_byte1_15] =  write_data[15:8];
    endcase
    end
    if(wen[0] == 1'b1) begin
    case(cacheline_write_ptr)
	4'h0:   cacheline[`addr_byte0_0]  =  write_data[7:0];
    4'h1:   cacheline[`addr_byte0_1]  =  write_data[7:0];
    4'h2:   cacheline[`addr_byte0_2]  =  write_data[7:0];
    4'h3:   cacheline[`addr_byte0_3]  =  write_data[7:0];
    4'h4:   cacheline[`addr_byte0_4]  =  write_data[7:0];
    4'h5:   cacheline[`addr_byte0_5]  =  write_data[7:0];
    4'h6:   cacheline[`addr_byte0_6]  =  write_data[7:0];
    4'h7:   cacheline[`addr_byte0_7]  =  write_data[7:0];
    4'h8:   cacheline[`addr_byte0_8]  =  write_data[7:0];
    4'h9:   cacheline[`addr_byte0_9]  =  write_data[7:0];
    4'ha:   cacheline[`addr_byte0_10] =  write_data[7:0];
    4'hb:   cacheline[`addr_byte0_11] =  write_data[7:0];
    4'hc:   cacheline[`addr_byte0_12] =  write_data[7:0];
    4'hd:   cacheline[`addr_byte0_13] =  write_data[7:0];
    4'he:   cacheline[`addr_byte0_14] =  write_data[7:0];
    4'hf:   cacheline[`addr_byte0_15] =  write_data[7:0];
    endcase
    end
    cacheline_write_ptr = cacheline_write_ptr + 4'b1;
end
endtask

task cacheline_get_data(input [513:0] cacheline ,output [31:0] cacheline_data);
begin
    if(hit) cacheline_ptr = s_addr_r[5:2];
    case(cacheline_ptr)
    4'h0:   cacheline_data = cacheline[`addr0];
    4'h1:   cacheline_data = cacheline[`addr1];
    4'h2:   cacheline_data = cacheline[`addr2];
    4'h3:   cacheline_data = cacheline[`addr3];
    4'h4:   cacheline_data = cacheline[`addr4];
    4'h5:   cacheline_data = cacheline[`addr5];
    4'h6:   cacheline_data = cacheline[`addr6];
    4'h7:   cacheline_data = cacheline[`addr7];
    4'h8:   cacheline_data = cacheline[`addr8];
    4'h9:   cacheline_data = cacheline[`addr9];
    4'ha:   cacheline_data = cacheline[`addr10];
    4'hb:   cacheline_data = cacheline[`addr11];
    4'hc:   cacheline_data = cacheline[`addr12];
    4'hd:   cacheline_data = cacheline[`addr13];
    4'he:   cacheline_data = cacheline[`addr14];
    4'hf:   cacheline_data = cacheline[`addr15];
    endcase
    cacheline_ptr = cacheline_ptr + 4'b1;
end
endtask

task find_set0();
begin
	if (set0_0_addr == s_addr_r[31:8]) begin  set0_hit_ptr = 2'b00; set0_hit = 1'b1; end
	else if (set0_1_addr == s_addr_r[31:8] ) begin set0_hit_ptr = 2'b01; set0_hit = 1'b1;end
	else if (set0_2_addr == s_addr_r[31:8] ) begin set0_hit_ptr = 2'b10; set0_hit = 1'b1; end
	else if (set0_3_addr == s_addr_r[31:8]) begin set0_hit_ptr = 2'b11; set0_hit = 1'b1; end
    else begin set0_hit = 1'b0; set0_hit_ptr = set0_ptr; end
end    
endtask

task find_set1();
begin
	if (set1_0_addr == s_addr_r[31:8]) begin  set1_hit_ptr = 2'b00; set1_hit = 1'b1; end
	else if (set1_1_addr == s_addr_r[31:8] ) begin set1_hit_ptr = 2'b01; set1_hit = 1'b1;end
	else if (set1_2_addr == s_addr_r[31:8] ) begin set1_hit_ptr = 2'b10; set1_hit = 1'b1; end
	else if (set1_3_addr == s_addr_r[31:8]) begin set1_hit_ptr = 2'b11; set1_hit = 1'b1; end
    else begin set1_hit = 1'b0; set1_hit_ptr = set0_ptr; end
end    
endtask

task find_set2();
begin
	if (set2_0_addr == s_addr_r[31:8]) begin  set2_hit_ptr = 2'b00; set2_hit = 1'b1; end
	else if (set2_1_addr == s_addr_r[31:8] ) begin set2_hit_ptr = 2'b01; set2_hit = 1'b1;end
	else if (set2_2_addr == s_addr_r[31:8] ) begin set2_hit_ptr = 2'b10; set2_hit = 1'b1; end
	else if (set2_3_addr == s_addr_r[31:8]) begin set2_hit_ptr = 2'b11; set2_hit = 1'b1; end
    else begin set2_hit = 1'b0; set2_hit_ptr = set0_ptr; end
end    
endtask

task find_set3();
begin
	if (set3_0_addr == s_addr_r[31:8]) begin  set3_hit_ptr = 2'b00; set3_hit = 1'b1; end
	else if (set3_1_addr == s_addr_r[31:8] ) begin set3_hit_ptr = 2'b01; set3_hit = 1'b1;end
	else if (set3_2_addr == s_addr_r[31:8] ) begin set3_hit_ptr = 2'b10; set3_hit = 1'b1; end
	else if (set3_3_addr == s_addr_r[31:8]) begin set3_hit_ptr = 2'b11; set3_hit = 1'b1; end
    else begin set3_hit = 1'b0; set3_hit_ptr = set0_ptr; end
end    
endtask

task find_cache();
begin
    set = s_addr_r[7:6];
    case(set)
    2'b00: begin 
        find_set0(); 
        case(set0_ptr)        
        2'b00: dirty = set0_dirty[0];
        2'b01: dirty = set0_dirty[1];
        2'b10: dirty = set0_dirty[2];
        2'b11: dirty = set0_dirty[3];
        endcase end
    2'b01: begin 
        find_set1(); 
        case(set1_ptr)        
        2'b00: dirty = set1_dirty[0];
        2'b01: dirty = set1_dirty[1];
        2'b10: dirty = set1_dirty[2];
        2'b11: dirty = set1_dirty[3];
        endcase end
    2'b10: begin 
        find_set2(); 
        case(set2_ptr)        
        2'b00: dirty = set2_dirty[0];
        2'b01: dirty = set2_dirty[1];
        2'b10: dirty = set2_dirty[2];
        2'b11: dirty = set2_dirty[3];
        endcase end
    2'b11: begin 
        find_set3(); 
        case(set3_ptr)        
        2'b00: dirty = set3_dirty[0];
        2'b01: dirty = set3_dirty[1];
        2'b10: dirty = set3_dirty[2];
        2'b11: dirty = set3_dirty[3];
        endcase end
    endcase
    hit = set0_hit | set1_hit | set2_hit | set3_hit;
    
end   
endtask


task cache_write_data(input [3:0] wen, input [31:0] wdata);
    case(set)
    2'b00: case(set0_hit_ptr)
           2'b00:cacheline_byte_write_data(set0[0],wen,wdata);
           2'b01:cacheline_byte_write_data(set0[1],wen,wdata);
           2'b10:cacheline_byte_write_data(set0[2],wen,wdata);
           2'b11:cacheline_byte_write_data(set0[3],wen,wdata);
           endcase
    2'b01: case(set1_hit_ptr)
           2'b00:cacheline_byte_write_data(set1[0],wen,wdata);
           2'b01:cacheline_byte_write_data(set1[1],wen,wdata);
           2'b10:cacheline_byte_write_data(set1[2],wen,wdata);
           2'b11:cacheline_byte_write_data(set1[3],wen,wdata);
           endcase
    2'b10: case(set2_hit_ptr)
           2'b00:cacheline_byte_write_data(set2[0],wen,wdata);
           2'b01:cacheline_byte_write_data(set2[1],wen,wdata);
           2'b10:cacheline_byte_write_data(set2[2],wen,wdata);
           2'b11:cacheline_byte_write_data(set2[3],wen,wdata);
           endcase
    2'b11: case(set3_hit_ptr)
           2'b00:cacheline_byte_write_data(set3[0],wen,wdata);
           2'b01:cacheline_byte_write_data(set3[1],wen,wdata);
           2'b10:cacheline_byte_write_data(set3[2],wen,wdata);
           2'b11:cacheline_byte_write_data(set3[3],wen,wdata);
           endcase
    endcase
endtask

reg write_hit;
reg write_set0_hit;
reg write_set1_hit;
reg write_set2_hit;
reg write_set3_hit;

task update_flag();
begin
    tag = 1'b0;
    set0_hit = 1'b0;
    set1_hit = 1'b0;
    set2_hit = 1'b0;
    set3_hit = 1'b0;
    hit = 1'b0;
    is_read = 1'b0;
    dirty = 1'b0;
    cacheline_ptr = 4'b0000;
    cacheline_write_ptr = 4'b0000;
end
endtask

task add_ptr();
begin
    case(set)
    2'b00:set0_ptr = set0_ptr + 2'b1;
    2'b01:set1_ptr = set1_ptr + 2'b1;
    2'b10:set2_ptr = set2_ptr + 2'b1;
    2'b11:set3_ptr = set3_ptr + 2'b1;
    endcase
end
endtask

task init();
begin
    set0_ptr = 2'b00;
    set1_ptr = 2'b00;
    set2_ptr = 2'b00;
    set3_ptr = 2'b00;
    m_wlast_r = 1'b0;
    m_wvalid_r = 1'b0;
    m_arvalid_r = 1'b0;
    m_awvalid_r = 1'b0;
    s_wready_r = 1'b0;
    s_rvalid_r = 1'b0;
    set0_empty = 4'b0000;
    set1_empty = 4'b0000;
    set2_empty = 4'b0000;
    set3_empty = 4'b0000;
    update_flag();
end
endtask

task get_empty();
begin
    case(set)
        2'b00:begin 
            if(set0_empty[2] == 1'b0) is_empty = 1'b1;
            else is_empty = 1'b0;
            if(is_empty) set0_empty = set0_empty + 1'b1;
        end
        2'b01:begin 
            if(set1_empty[2] == 1'b0) is_empty = 1'b1;
            else is_empty = 1'b0;
            if(is_empty) set1_empty = set1_empty + 1'b1;
        end
        2'b10:begin 
            if(set2_empty[2] == 1'b0) is_empty = 1'b1;
            else is_empty = 1'b0;
            if(is_empty) set2_empty = set2_empty + 1'b1; 
        end
        2'b11:begin
            if(set3_empty[2] == 1'b0) is_empty = 1'b1;
            else is_empty = 1'b0;
            if(is_empty) set3_empty = set3_empty + 1'b1; 
        end
    endcase
end
endtask

task write_cacheline_to_ram(output [31:0] write_data);
begin
    case(set)
    2'b00:begin 
         case(set0_ptr)
             2'b00: cacheline_get_data(set0[0],write_data);
             2'b01: cacheline_get_data(set0[1],write_data);
             2'b10: cacheline_get_data(set0[2],write_data);
             2'b11: cacheline_get_data(set0[3],write_data);
         endcase
         end
     2'b01:begin 
         case(set1_ptr)
             2'b00: cacheline_get_data(set1[0],write_data);
             2'b01: cacheline_get_data(set1[1],write_data);
             2'b10: cacheline_get_data(set1[2],write_data);
             2'b11: cacheline_get_data(set1[3],write_data);
         endcase
         end
     2'b10:begin 
         case(set2_ptr)
             2'b00: cacheline_get_data(set2[0],write_data);
             2'b01: cacheline_get_data(set2[1],write_data);
             2'b10: cacheline_get_data(set2[2],write_data);
             2'b11: cacheline_get_data(set2[3],write_data);
         endcase
         end
     2'b11:begin 
         case(set3_ptr)
             2'b00: cacheline_get_data(set3[0],write_data);
             2'b01: cacheline_get_data(set3[1],write_data);
             2'b10: cacheline_get_data(set3[2],write_data);
             2'b11: cacheline_get_data(set3[3],write_data);
         endcase
     end
     endcase
end
endtask

task write_current_tag();
begin
    tag = 1'b1;
    case(set)
		2'b00: begin
			case(set0_hit_ptr)
            2'b00: begin if(is_read == 1'b0) set0_dirty[0]= 1'b1;  
            set0_0_addr = s_addr_r[31:8]; end
            2'b01: begin if(is_read == 1'b0) set0_dirty[1]= 1'b1; 
            set0_1_addr = s_addr_r[31:8]; end
            2'b10: begin if(is_read == 1'b0) set0_dirty[2]= 1'b1; 
            set0_2_addr = s_addr_r[31:8]; end
            2'b11: begin if(is_read == 1'b0) set0_dirty[3]= 1'b1; 
            set0_3_addr = s_addr_r[31:8]; end
			endcase
		end
		2'b01: begin
			case(set1_hit_ptr)
            2'b00: begin if(is_read == 1'b0) set1_dirty[0]= 1'b1;  
            set1_0_addr = s_addr_r[31:8]; end
            2'b01: begin if(is_read == 1'b0) set1_dirty[1]= 1'b1; 
            set1_1_addr = s_addr_r[31:8]; end
            2'b10: begin if(is_read == 1'b0) set1_dirty[2]= 1'b1; 
            set1_2_addr = s_addr_r[31:8]; end
            2'b11: begin if(is_read == 1'b0) set1_dirty[3]= 1'b1; 
            set1_3_addr = s_addr_r[31:8]; end
            endcase
		end
		2'b10: begin
			case(set2_hit_ptr)
            2'b00: begin if(is_read == 1'b0) set2_dirty[0]= 1'b1;  
            set2_0_addr = s_addr_r[31:8]; end
            2'b01: begin if(is_read == 1'b0) set2_dirty[1]= 1'b1; 
            set2_1_addr = s_addr_r[31:8]; end
            2'b10: begin if(is_read == 1'b0) set2_dirty[2]= 1'b1; 
            set2_2_addr = s_addr_r[31:8]; end
            2'b11: begin if(is_read == 1'b0) set2_dirty[3]= 1'b1; 
            set2_3_addr = s_addr_r[31:8]; end
            endcase
		end
		2'b11: begin
			case(set3_hit_ptr)
            2'b00: begin if(is_read == 1'b0) set3_dirty[0]= 1'b1;  
            set3_0_addr = s_addr_r[31:8]; end
            2'b01: begin if(is_read == 1'b0) set3_dirty[1]= 1'b1; 
            set3_1_addr = s_addr_r[31:8]; end
            2'b10: begin if(is_read == 1'b0) set3_dirty[2]= 1'b1; 
            set3_2_addr = s_addr_r[31:8]; end
            2'b11: begin if(is_read == 1'b0) set3_dirty[3]= 1'b1; 
            set3_3_addr = s_addr_r[31:8]; end
            endcase
		end
    endcase
end
endtask

task cache_read_data(output [31:0] read_data);
begin
	case(set)
	2'b00: begin
		case(set0_hit_ptr)
		2'b00: cacheline_get_data(set0[0],read_data);
		2'b01: cacheline_get_data(set0[1],read_data);
		2'b10: cacheline_get_data(set0[2],read_data);
		2'b11: cacheline_get_data(set0[3],read_data);
		endcase
	end
	2'b01: begin
		case(set1_hit_ptr)
		2'b00: cacheline_get_data(set1[0],read_data);
		2'b01: cacheline_get_data(set1[1],read_data);
		2'b10: cacheline_get_data(set1[2],read_data);
		2'b11: cacheline_get_data(set1[3],read_data);
		endcase
	end
	2'b10: begin
		case(set2_hit_ptr)
		2'b00: cacheline_get_data(set2[0],read_data);
		2'b01: cacheline_get_data(set2[1],read_data);
		2'b10: cacheline_get_data(set2[2],read_data);
		2'b11: cacheline_get_data(set2[3],read_data);
		endcase
	end
	2'b11: begin
		case(set3_hit_ptr)
		2'b00: cacheline_get_data(set3[0],read_data);
		2'b01: cacheline_get_data(set3[1],read_data);
		2'b10: cacheline_get_data(set3[2],read_data);
		2'b11: cacheline_get_data(set3[3],read_data);
		endcase
	end
	endcase
end
endtask 


always @(*)
begin
    s_addr_r = s_addr;
end

always @(posedge clk)
begin
    if(rst == `RST_ENABLE) begin
        init();    
        state <= state_idle;
    end else begin
        case(state)
        state_idle: begin
            if(s_arvalid == 1'b1) begin
                is_read = 1'b1;
                if(cache_ena == 1'b1) begin
                    find_cache();
                    if(hit == 1'b1) begin
                        cache_read_data(s_rdata_r);
                        s_rvalid_r <= 1'b1;
                        state <= state_read_hit;
                    end else begin
                        if(dirty == 1'b1) begin
                            state <= state_read_miss_wait_write_burst;
                            m_awaddr_r <=  {s_addr_r[31:6],6'b00_0000};
                            write_cacheline_to_ram(m_wdata_r);
                            m_awvalid_r <= 1'b1;
                            m_wvalid_r <= 1'b1;
                        end else begin
                            state <= state_read_miss_wait_read_burst;
                            m_arvalid_r <= 1'b1;
                            m_araddr_r <= {s_addr_r[31:6],6'b00_0000};
                        end
                    end
                end else begin
                    state <= state_read_uncache_wait_ram;
                    m_arvalid_r <= 1'b1;
                    m_araddr_r <= s_addr_r;
                end
            end
            if(s_awvalid != 4'b0000) begin
                if(cache_ena == 1'b1) begin
                    is_read = 1'b0;
                    find_cache();
                    state <= state_write_hit_write_data;
                end else begin
                    state <= state_write_uncache_wait_ram;
                    m_awaddr_r <= s_addr_r;
                    m_awvalid_r <= 1'b1;
                    m_wvalid_r <= 1'b1;
                    m_wlast_r <= 1'b1;
                    m_wdata_r <= s_wdata;
                end
            end
        end
        state_read_hit: begin
            update_flag();
			state <= state_idle;
            s_rvalid_r <= 1'b0;
        end
        state_read_miss_wait_write_burst: begin
            m_awvalid_r <= 1'b0; 
            write_cacheline_to_ram(m_wdata_r);
		    if(cacheline_write_ptr == 4'b0000) begin 
		        state <= state_read_miss_wait_bvalid;
		        m_wlast_r <= 1'b1;
		    end
		end
        state_read_miss_wait_bvalid: begin
            m_wlast_r <= 1'b0;
            m_wvalid_r <= 1'b0;
            if(m_bvalid == 1'b1) begin
                state <= state_read_miss_wait_read_burst;
                m_arvalid_r <= 1'b1;
                m_araddr_r <= {s_addr_r[31:6],6'b00_0000};
            end
        end
        state_read_miss_wait_read_burst: begin
            if(m_arready) m_arvalid_r <= 1'b0;
            if(m_rvalid == 1'b1) cache_write_data(4'b1111,m_rdata);
            if(m_rlast == 1'b1) begin
                state <= state_read_miss_wait_write_tag;
            end
        end
        state_read_miss_wait_write_tag: begin
            write_current_tag();
            state <= state_read_miss_wait_finish;
        end       
        state_read_miss_wait_finish: begin
              find_cache();
              if(hit == 1'b1) begin
				  cache_read_data(s_rdata_r);
                  s_rvalid_r <= 1'b1;
                  state <= state_read_hit;
                  add_ptr();
              end
        end
        state_write_hit_write_data: begin
            if(hit) begin
                s_wready_r <= 1'b1;
                state <= state_write_hit;
                cache_write_data(s_awvalid,s_wdata);
            end else begin
                if(dirty == 1'b1) begin
                    state <= state_write_miss_wait_write_burst;
                    m_awaddr_r <=  {s_addr_r[31:6],6'b00_0000};
                    write_cacheline_to_ram(m_wdata_r);
                    m_awvalid_r <= 1'b1;
                    m_wvalid_r <= 1'b1;
                end else begin
                    get_empty();
                    if(is_empty) begin
                        cache_write_data(s_awvalid,s_wdata);
                        state <= state_write_empty;
                        s_wready_r <= 1'b1;
                    end else begin
                        state <= state_write_miss_wait_read_burst;
                        m_arvalid_r <= 1'b1;
                        m_araddr_r <= {s_addr_r[31:6],6'b00_0000};
                    end
                end
            end
        end
        state_write_empty:begin
            write_current_tag();
            add_ptr();
            state <= state_write_hit;
        end
		state_write_hit: begin
			update_flag();
			s_wready_r <= 1'b0;
			state <= state_idle;
		end
        state_write_miss_wait_write_burst: begin
            m_awvalid_r <= 1'b0; 
            write_cacheline_to_ram(m_wdata_r);
		    if(cacheline_write_ptr == 4'b0000) begin 
		        state <= state_write_miss_wait_bvalid;
		        m_wlast_r <= 1'b1;
		    end
		end
		state_write_miss_wait_bvalid: begin
            m_wlast_r <= 1'b0;
            m_wvalid_r <= 1'b0;
            if(m_bvalid == 1'b1) begin
                state <= state_write_miss_wait_read_burst;
                m_arvalid_r <= 1'b1;
                m_araddr_r <= {s_addr_r[31:6],6'b00_0000};
            end
        end
		state_write_miss_wait_read_burst: begin
            if(m_arready) m_arvalid_r <= 1'b0;
            if(m_rvalid == 1'b1) cache_write_data(4'b1111,m_rdata);
            if(m_rlast == 1'b1) begin
                state <= state_write_miss_wait_write_tag;
            end
        end
        state_write_miss_wait_write_tag: begin
             write_current_tag();
             state <= state_write_miss_wait_finish;
        end
        state_write_miss_wait_finish: begin
               find_cache();
               if(hit == 1'b1) begin
			     cache_write_data(s_awvalid,s_wdata);
                 s_wready_r = 1'b1;
                 state <= state_write_hit;
                 add_ptr();
               end
        end   
        state_read_uncache_wait_ram: begin
            if(m_arready) m_arvalid_r <= 1'b0;
            if(m_rvalid == 1'b1) begin
                hit_cache_data <= m_rdata;
                state <= state_read_uncache_wait_finish;
            end
        end
        state_read_uncache_wait_finish: begin
            s_rvalid_r <= 1'b1;  
            s_rdata_r  <= hit_cache_data;    
            state <= state_read_hit;
        end
		state_write_uncache_wait_ram: begin
		  if(m_awready) begin 
		      m_awvalid_r <= 1'b0;
		      m_wvalid_r <= 1'b0;
		  end
		  if(m_bvalid) begin
		      m_wvalid_r <= 1'b0;
		      m_wlast_r <= 1'b0;
		      state <= state_write_uncache_wait_finish;
		      s_wready_r <= 1'b1;
		   end
		end
		state_write_uncache_wait_finish: begin
		    m_wlast_r <= 1'b0; 
		    s_wready_r <= 1'b0;
		    state <= state_idle;
		end
		
		default: ;
        endcase
   end
end
assign m_arvalid = m_arvalid_r;
assign m_araddr = m_araddr_r;
assign m_rready = 1'b1;

assign m_awaddr = m_awaddr_r;
assign m_awvalid = m_awvalid_r;
assign m_awlen = cache_ena ? 8'h0f:8'h00;
assign m_awid = 4'b0000;
assign m_awsize = 3'b010;
assign m_awburst = cache_ena ? 2'b01:2'b00;
assign m_awlock = 2'b00;
assign m_awcache = 4'b0000;
assign m_awprot = 3'b000;

assign m_wid = 4'b0000;
assign m_wlast = m_wlast_r;
assign m_wvalid = m_wvalid_r;
assign m_wdata = m_wdata_r;
assign m_wstrb = 4'b1111;

assign m_bready = 1'b1;

assign s_wready = s_wready_r;
assign s_rdata = s_rdata_r;
assign s_rvalid = s_rvalid_r;

endmodule
