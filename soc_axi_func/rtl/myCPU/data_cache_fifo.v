`include "defines.v"
module data_cache_fifo(
    input         clk            ,
    input         rst            ,
    output [31:0] m_araddr       ,
    output        m_arvalid      ,
    input         m_arready      ,
    
    input  [31:0] m_rdata        ,
    input         m_rlast        ,
    input         m_rvalid       ,
    output        m_rready       ,
    
    output [31:0] m_awaddr       ,
    output        m_awvalid      ,
    input         m_awready      ,
    
    output [31:0] m_wdata        ,
    output [3 :0] m_wstrb        ,
    output        m_wlast        ,
    output        m_wvalid       ,
    input         m_wready       ,

    input         m_bvalid       ,
    output        m_bready       ,
	
    input  [31:0] s_addr         ,
    output [31:0] s_rdata        ,
    output        s_rvalid       ,
    input         s_rready       ,
    input  [31:0] s_wdata        ,
    input  [3:0]  s_wvalid       ,
    output        s_wready
);

`ifdef test
assign  m_araddr       = 32'h0;
assign  m_arvalid      = 1'b0;
assign  m_rready       = 1'b0;
assign  m_awaddr       = 32'b0;
assign  m_awvalid      = 1'b0;
assign  m_wdata        = 32'h0;
assign  m_wstrb        = 4'h0;
assign  m_wlast        = 1'b0;
assign  m_wvalid       = 1'b0;
assign  m_bready       = 1'b0;
assign  s_rdata        = 32'b0;
assign  s_rvalid       = 1'b0;
assign  s_wready       = 1'b0;
`endif


/*  
reg [31:0] set0_data;
reg [31:0] set1_data;
reg [31:0] set2_data;
reg [31:0] set3_data;

reg [537:0] set0[3:0];
reg [537:0] set1[3:0];
reg [537:0] set2[3:0];
reg [537:0] set3[3:0];

reg [31:0]  s_addr_r;
reg [31:0]  s_data_r;
reg [3:0]   s_wvalid_r;
reg         hit;
reg         set0_hit;
reg         set1_hit;
reg         set2_hit;
reg         set3_hit;

reg [1:0]   set0_ptr;
reg [1:0]   set1_ptr;
reg [1:0]   set2_ptr;
reg [1:0]   set3_ptr;
reg [2:0]   state;
reg [3:0]   cacheline_ptr;

parameter [2:0] state_idle = 3'b000;
parameter [2:0] state_read_wait_ram = 3'b001;
parameter [2:0] state_hit = 3'b010;
parameter [2:0] state_write_wait_ram = 3'b011;
parameter [2:0] state_wait_done = 3'b110;

task cacheline_write_data(output [536:0] cacheline); 
begin
    case(cacheline_ptr)
    4'h0:   cacheline[`addr0]  =  m_rdata;
    4'h1:   cacheline[`addr1]  =  m_rdata;
    4'h2:   cacheline[`addr2]  =  m_rdata;
    4'h3:   cacheline[`addr3]  =  m_rdata;
    4'h4:   cacheline[`addr4]  =  m_rdata;
    4'h5:   cacheline[`addr5]  =  m_rdata;
    4'h6:   cacheline[`addr6]  =  m_rdata;
    4'h7:   cacheline[`addr7]  =  m_rdata;
    4'h8:   cacheline[`addr8]  =  m_rdata;
    4'h9:   cacheline[`addr9]  =  m_rdata;
    4'ha:   cacheline[`addr10] =  m_rdata;
    4'hb:   cacheline[`addr11] =  m_rdata;
    4'hc:   cacheline[`addr12] =  m_rdata;
    4'hd:   cacheline[`addr13] =  m_rdata;
    4'he:   cacheline[`addr14] =  m_rdata;
    4'hf:   begin cacheline[`addr15] =  m_rdata; cacheline[`addr_tag] = s_addr_r[31:8]; end
    endcase
    cacheline_ptr = cacheline_ptr + 4'h1;
end
endtask

task cacheline_get_data(input [537:0] cacheline ,output [31:0] cacheline_data);
    case(s_addr_r[5:2])
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
endtask

task find_set0(output [31:0] data);
begin
    if (set0[0][`addr_tag] == s_addr_r[31:8]) begin
        set0_hit = 1'b1;
        cacheline_get_data(set0[0],data);
    end else if (set0[1][`addr_tag] == s_addr_r[31:8] ) begin
        set0_hit = 1'b1;
        cacheline_get_data(set0[1],data);
    end else if (set0[2][`addr_tag] == s_addr_r[31:8] ) begin
        set0_hit = 1'b1;
        cacheline_get_data(set0[2],data);
    end else if (set0[3][`addr_tag] == s_addr_r[31:8]) begin
        set0_hit = 1'b1;
        cacheline_get_data(set0[3],data);
    end else set0_hit = 1'b0;
end    
endtask

task find_set1(output [31:0] data);
begin
    if (set1[0][`addr_tag] == s_addr_r[31:8]) begin
        set1_hit = 1'b1;
        cacheline_get_data(set1[0],data);
    end else if (set1[1][`addr_tag] == s_addr_r[31:8]) begin
        set1_hit = 1'b1;
        cacheline_get_data(set1[1],data);
    end else if (set1[2][`addr_tag] == s_addr_r[31:8]) begin
        set1_hit = 1'b1;
        cacheline_get_data(set1[2],data);
    end else if (set1[3][`addr_tag] == s_addr_r[31:8]) begin
        set1_hit = 1'b1;
        cacheline_get_data(set1[3],data);
    end else set1_hit = 1'b0;
end    
endtask

task find_set2(output [31:0] data);
begin
    if (set2[0][`addr_tag] == s_addr_r[31:8]) begin
        set2_hit = 1'b1;
        cacheline_get_data(set2[0],data);
    end else if (set2[1][`addr_tag] == s_addr_r[31:8]) begin
        set2_hit = 1'b1;
        cacheline_get_data(set2[1],data);
    end else if (set2[2][`addr_tag] == s_addr_r[31:8]) begin
        set2_hit = 1'b1;
        cacheline_get_data(set2[2],data);
    end else if (set2[3][`addr_tag] == s_addr_r[31:8]) begin
        set2_hit = 1'b1;
        cacheline_get_data(set2[3],data);
    end else set2_hit = 1'b0;
end    
endtask

task find_set3(output [31:0] data);
begin
    if (set3[0][`addr_tag] == s_addr_r[31:8]) begin
        set3_hit = 1'b1;
        cacheline_get_data(set3[0],data);
    end else if (set3[1][`addr_tag] == s_addr_r[31:8]) begin
        set3_hit = 1'b1;
        cacheline_get_data(set3[1],data);
    end else if (set3[2][`addr_tag] == s_addr_r[31:8]) begin
        set3_hit = 1'b1;
        cacheline_get_data(set3[2],data);
    end else if (set3[3][`addr_tag] == s_addr_r[31:8]) begin
        set3_hit = 1'b1;
        cacheline_get_data(set3[3],data);
    end
    else set3_hit = 1'b0;
end    
endtask

task find_cache(output [31:0] data);
begin
    case(s_addr_r[7:6])
    2'b00: find_set0(set0_data);
    2'b01: find_set1(set1_data);
    2'b10: find_set2(set2_data);
    2'b11: find_set3(set3_data);
    endcase
    hit = set0_hit | set1_hit | set2_hit | set3_hit;
    if(set0_hit) data = set0_data;
    else if(set1_hit) data = set1_data;
    else if(set2_hit) data = set2_data;
    else if(set3_hit) data = set3_data;
    else data = 32'b0;
end   
endtask

task set0_write_data();
begin
    case(set0_ptr)  //current cacheline
        2'd0: cacheline_write_data(set0[0]);
        2'd1: cacheline_write_data(set0[1]);
        2'd2: cacheline_write_data(set0[2]);
        2'd3: cacheline_write_data(set0[3]);
    endcase
    if(cacheline_ptr == 4'b0000) set0_ptr = set0_ptr + 2'b1;
end
endtask

task set1_write_data();
begin
    case(set1_ptr)  //current cacheline
        2'd0: cacheline_write_data(set1[0]);
        2'd1: cacheline_write_data(set1[1]);
        2'd2: cacheline_write_data(set1[2]);
        2'd3: cacheline_write_data(set1[3]);
    endcase
    if(cacheline_ptr == 4'b0000) set1_ptr = set1_ptr + 2'b1;
end
endtask

task set2_write_data();
begin
    case(set2_ptr)  //current cacheline
        2'd0: cacheline_write_data(set2[0]);
        2'd1: cacheline_write_data(set2[1]);
        2'd2: cacheline_write_data(set2[2]);
        2'd3: cacheline_write_data(set2[3]);
    endcase
if(cacheline_ptr == 4'b0000) set2_ptr = set2_ptr + 2'b1;
end
endtask

task set3_write_data();
begin
    case(set3_ptr)  //current cacheline
        2'd0: cacheline_write_data(set3[0]);
        2'd1: cacheline_write_data(set3[1]);
        2'd2: cacheline_write_data(set3[2]);
        2'd3: cacheline_write_data(set3[3]);
    endcase
    if(cacheline_ptr == 4'b0000) set3_ptr = set3_ptr + 2'b1;
end
endtask

task cache_write_data();
    case(s_addr_r[7:6])
    2'b00: begin set0_write_data(); end
    2'b01: begin set1_write_data(); end
    2'b10: begin set2_write_data(); end
    2'b11: begin set3_write_data(); end
    endcase
endtask

reg write_hit;
reg write_set0_hit;
reg write_set1_hit;
reg write_set2_hit;
reg write_set3_hit;

task cacheline_byte_write_data(input [537:0] cacheline);
begin
    if(s_wvalid_r[3] == 1'b1) begin
    case(s_addr_r[5:2])
    4'h0:   cacheline[`addr_byte3_0]  =  m_rdata;
    4'h1:   cacheline[`addr_byte3_1]  =  m_rdata;
    4'h2:   cacheline[`addr_byte3_2]  =  m_rdata;
    4'h3:   cacheline[`addr_byte3_3]  =  m_rdata;
    4'h4:   cacheline[`addr_byte3_4]  =  m_rdata;
    4'h5:   cacheline[`addr_byte3_5]  =  m_rdata;
    4'h6:   cacheline[`addr_byte3_6]  =  m_rdata;
    4'h7:   cacheline[`addr_byte3_7]  =  m_rdata;
    4'h8:   cacheline[`addr_byte3_8]  =  m_rdata;
    4'h9:   cacheline[`addr_byte3_9]  =  m_rdata;
    4'ha:   cacheline[`addr_byte3_10] =  m_rdata;
    4'hb:   cacheline[`addr_byte3_11] =  m_rdata;
    4'hc:   cacheline[`addr_byte3_12] =  m_rdata;
    4'hd:   cacheline[`addr_byte3_13] =  m_rdata;
    4'he:   cacheline[`addr_byte3_14] =  m_rdata;
    endcase
    end
    if(s_wvalid_r[2] == 1'b1) begin
    case(s_addr_r[5:2])
    4'h0:   cacheline[`addr_byte2_0]  =  m_rdata;
    4'h1:   cacheline[`addr_byte2_1]  =  m_rdata;
    4'h2:   cacheline[`addr_byte2_2]  =  m_rdata;
    4'h3:   cacheline[`addr_byte2_3]  =  m_rdata;
    4'h4:   cacheline[`addr_byte2_4]  =  m_rdata;
    4'h5:   cacheline[`addr_byte2_5]  =  m_rdata;
    4'h6:   cacheline[`addr_byte2_6]  =  m_rdata;
    4'h7:   cacheline[`addr_byte2_7]  =  m_rdata;
    4'h8:   cacheline[`addr_byte2_8]  =  m_rdata;
    4'h9:   cacheline[`addr_byte2_9]  =  m_rdata;
    4'ha:   cacheline[`addr_byte2_10] =  m_rdata;
    4'hb:   cacheline[`addr_byte2_11] =  m_rdata;
    4'hc:   cacheline[`addr_byte2_12] =  m_rdata;
    4'hd:   cacheline[`addr_byte2_13] =  m_rdata;
    4'he:   cacheline[`addr_byte2_14] =  m_rdata;
    endcase
    end
    if(s_wvalid_r[1] == 1'b1) begin
    case(s_addr_r[5:2])
    4'h0:   cacheline[`addr_byte1_0]  =  m_rdata;
    4'h1:   cacheline[`addr_byte1_1]  =  m_rdata;
    4'h2:   cacheline[`addr_byte1_2]  =  m_rdata;
    4'h3:   cacheline[`addr_byte1_3]  =  m_rdata;
    4'h4:   cacheline[`addr_byte1_4]  =  m_rdata;
    4'h5:   cacheline[`addr_byte1_5]  =  m_rdata;
    4'h6:   cacheline[`addr_byte1_6]  =  m_rdata;
    4'h7:   cacheline[`addr_byte1_7]  =  m_rdata;
    4'h8:   cacheline[`addr_byte1_8]  =  m_rdata;
    4'h9:   cacheline[`addr_byte1_9]  =  m_rdata;
    4'ha:   cacheline[`addr_byte1_10] =  m_rdata;
    4'hb:   cacheline[`addr_byte1_11] =  m_rdata;
    4'hc:   cacheline[`addr_byte1_12] =  m_rdata;
    4'hd:   cacheline[`addr_byte1_13] =  m_rdata;
    4'he:   cacheline[`addr_byte1_14] =  m_rdata;
    endcase
    end
    if(s_wvalid_r[0] == 1'b1) begin
    case(s_addr_r[5:2])
    4'h0:   cacheline[`addr_byte0_0]  =  m_rdata;
    4'h1:   cacheline[`addr_byte0_1]  =  m_rdata;
    4'h2:   cacheline[`addr_byte0_2]  =  m_rdata;
    4'h3:   cacheline[`addr_byte0_3]  =  m_rdata;
    4'h4:   cacheline[`addr_byte0_4]  =  m_rdata;
    4'h5:   cacheline[`addr_byte0_5]  =  m_rdata;
    4'h6:   cacheline[`addr_byte0_6]  =  m_rdata;
    4'h7:   cacheline[`addr_byte0_7]  =  m_rdata;
    4'h8:   cacheline[`addr_byte0_8]  =  m_rdata;
    4'h9:   cacheline[`addr_byte0_9]  =  m_rdata;
    4'ha:   cacheline[`addr_byte0_10] =  m_rdata;
    4'hb:   cacheline[`addr_byte0_11] =  m_rdata;
    4'hc:   cacheline[`addr_byte0_12] =  m_rdata;
    4'hd:   cacheline[`addr_byte0_13] =  m_rdata;
    4'he:   cacheline[`addr_byte0_14] =  m_rdata;
    endcase
    end
end
endtask

task write_find_set0();
begin
    if (set0[0][`addr_tag] == s_addr_r[31:8]) begin
        set0_hit = 1'b1;
        cacheline_byte_write_data(set0[0]);
    end else if (set0[1][`addr_tag] == s_addr_r[31:8] ) begin
        set0_hit = 1'b1;
        cacheline_byte_write_data(set0[1]);
    end else if (set0[2][`addr_tag] == s_addr_r[31:8] ) begin
        set0_hit = 1'b1;
        cacheline_byte_write_data(set0[2]);
    end else if (set0[3][`addr_tag] == s_addr_r[31:8]) begin
        set0_hit = 1'b1;
        cacheline_byte_write_data(set0[3]);
    end else set0_hit = 1'b0;
end    
endtask

task cache_write_hit();
    case(s_addr_r[7:6])
    2'b00:write_find_set0();
    2'b01:write_find_set1();
    2'b10:write_find_set2();
    2'b11:write_find_set3();
    endcase
endtask

task get_s_addr_r();
    s_addr_r = s_addr;
endtask 

task get_s_data_wvalid_r();
begin
    s_data_r = s_wdata;
    s_wvalid_r = s_wvalid;
end
endtask 

task init();
begin
    set0_ptr = 2'b00;
    set1_ptr = 2'b00;
    set2_ptr = 2'b00;
    set3_ptr = 2'b00;
    set0_hit = 1'b0;
    set1_hit = 1'b0;
    set2_hit = 1'b0;
    set3_hit = 1'b0;
    hit = 1'b0;
    state = state_idle;
    cacheline_ptr = 4'b0000;
end
endtask

reg        s_rvalid_r;
reg [31:0] s_rdata_r;
reg        m_arvalid_r;
reg [31:0] m_araddr_r;
reg        bus_addr_ok;
reg [31:0] hit_cache_data;
reg        dirty;
reg        s_wready_r;
always @(posedge clk)
begin
    if(rst == `RST_ENABLE) begin
        init();    
    end else begin
        if(s_rready == 1'b1 && state == state_idle) begin
            get_s_addr_r();
            find_cache(hit_cache_data);
            if(hit == 1'b1) begin
                s_rvalid_r <= 1'b1;
                s_rdata_r <= hit_cache_data;
                state <= state_hit;
            end else begin
                state <= state_read_wait_ram;
                s_rvalid_r <= 1'b0;
                m_arvalid_r <= 1'b1;
                m_araddr_r <= {s_addr_r[31:6],6'b00_0000};
                if(m_arready == 1'b1) bus_addr_ok = 1'b1;
            end
        end else if(s_wvalid != 4'b000 && state == state_idle) begin
            get_s_data_wvalid_r();
            cache_write_hit();
            if(hit == 1'b1) begin
                state <= state_write_hit;
                s_wready <= 1'b1;
            end else begin 
                //state <= ...
            end
                // tag_addr hit? 
                // if hit ok skip
                // if not select a caheline
                // if (dirty) write_back
                // else skip
                // according addr read data to cacheline
                // write current data to the cacheline
                // finish
                //cache_write_data(dirty);    //need to change
        end else if(state == state_hit) begin
               set0_hit <= 1'b0;
               set1_hit <= 1'b0;
               set2_hit <= 1'b0;
               set3_hit <= 1'b0;
               hit <= 1'b0;
               s_rvalid_r <= 1'b0;
               state <= state_idle;
        end else if(state == state_read_wait_ram) begin
            if(bus_addr_ok || m_arready)
                m_arvalid_r <= 1'b0;
            if(m_rvalid == 1'b1)
                cache_write_data();
            if(m_rlast == 1'b1)
                state <= state_wait_done;
        end else if(state == state_write_wait_ram) begin
            //if()
            if(m_bvalid == 1'b1)
                state <= state_wait_done;
        end else if(state == state_wait_done) begin
            ;   
        end
    end
end

assign s_wready = s_wready_r;
*/
endmodule
