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
    input         s_arvalid      ,
    output [31:0] s_rdata        ,
    output        s_rvalid       ,
    
    input         s_awvalid      ,
    input  [31:0] s_wdata        ,
    input  [3:0]  s_wvalid       ,
    output        s_wready
);
  
reg [31:0] set0_data;
reg [31:0] set1_data;
reg [31:0] set2_data;
reg [31:0] set3_data;

reg [537:0] set0[3:0];
reg [537:0] set1[3:0];
reg [537:0] set2[3:0];
reg [537:0] set3[3:0];

reg [1:0]   set;
reg [31:0]  s_addr_r;
reg [31:0]  s_data_r;
reg [3:0]   s_wvalid_r;
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
reg [3:0]   state;
reg [3:0]   cacheline_ptr;

reg         is_read;

parameter [3:0] state_idle = 4'b0000;
parameter [3:0] state_read_hit = 4'b0001;
parameter [3:0] state_read_miss_wait_awready = 4'b0010;
parameter [3:0] state_read_miss_wait_write_burst = 4'b0011;
parameter [3:0] state_read_miss_wait_read_burst = 4'b0100;
parameter [3:0] state_read_miss_wait_finish = 4'b0101;

parameter [3:0] state_write_hit = 4'b0101;
parameter [3:0] state_write_miss_wait_write = 4'b0110;
parameter [3:0] state_write_miss_wait_read = 4'b0111;
parameter [3:0] state_write_miss_done = 4'b1000; 

task cacheline_byte_write_data(input [537:0] cacheline, input [3:0] wen, input [31:0] write_data);
begin
    if(is_read == 1'b0) cacheline[`dirty_bit] = 1'b1;
    if(wen[3] == 1'b1) begin
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
    4'hf:   cacheline[`addr_byte3_15] =  m_rdata;
    endcase
    end
    if(wen[2] == 1'b1) begin
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
    4'hf:   cacheline[`addr_byte2_15] =  m_rdata;
    endcase
    end
    if(wen[1] == 1'b1) begin
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
    4'hf:   cacheline[`addr_byte1_15] =  m_rdata;
    endcase
    end
    if(wen[0] == 1'b1) begin
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
    4'he:   cacheline[`addr_byte0_15] =  m_rdata;
    endcase
    end
end
endtask

task cacheline_get_data(input [537:0] cacheline ,output [31:0] cacheline_data);
begin
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
    if(cacheline[`dirty_bit] == 1'b1) dirty = 1'b1;
    else dirty = 1'b0;
end
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
    set = s_addr_r[7:6];
    case(set)
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


task cache_write_data();
    case(set)
    2'b00: case(set0_ptr)
           2'b00:cacheline_byte_write_data(set0[0],4'b1111,m_rdata);
           2'b01:cacheline_byte_write_data(set0[1],4'b1111,m_rdata);
           2'b10:cacheline_byte_write_data(set0[2],4'b1111,m_rdata);
           2'b11:cacheline_byte_write_data(set0[3],4'b1111,m_rdata);
           endcase
    2'b01: case(set1_ptr)
           2'b00:cacheline_byte_write_data(set1[0],4'b1111,m_rdata);
           2'b01:cacheline_byte_write_data(set1[1],4'b1111,m_rdata);
           2'b10:cacheline_byte_write_data(set1[2],4'b1111,m_rdata);
           2'b11:cacheline_byte_write_data(set1[3],4'b1111,m_rdata);
           endcase
    2'b10: case(set2_ptr)
           2'b00:cacheline_byte_write_data(set2[0],4'b1111,m_rdata);
           2'b01:cacheline_byte_write_data(set2[1],4'b1111,m_rdata);
           2'b10:cacheline_byte_write_data(set2[2],4'b1111,m_rdata);
           2'b11:cacheline_byte_write_data(set2[3],4'b1111,m_rdata);
           endcase
    2'b11: case(set3_ptr)
           2'b00:cacheline_byte_write_data(set3[0],4'b1111,m_rdata);
           2'b01:cacheline_byte_write_data(set3[1],4'b1111,m_rdata);
           2'b10:cacheline_byte_write_data(set3[2],4'b1111,m_rdata);
           2'b11:cacheline_byte_write_data(set3[3],4'b1111,m_rdata);
           endcase
    endcase
endtask

reg write_hit;
reg write_set0_hit;
reg write_set1_hit;
reg write_set2_hit;
reg write_set3_hit;

task get_s_addr_r();
    s_addr_r = s_addr;
endtask 

task get_s_data_wvalid_r();
begin
    s_data_r = s_wdata;
    s_wvalid_r = s_wvalid;
end
endtask 

task update_flag();
begin
    set0_hit = 1'b0;
    set1_hit = 1'b0;
    set2_hit = 1'b0;
    set3_hit = 1'b0;
    hit = 1'b0;
    is_read = 1'b0;
    state = state_idle;
    dirty = 1'b0;
    cacheline_ptr = 4'b0000;
    case(set)
    2'b00: set0_ptr = set0_ptr + 2'b1;
    2'b01: set1_ptr = set1_ptr + 2'b1;
    2'b10: set2_ptr = set2_ptr + 2'b1;
    2'b11: set3_ptr = set3_ptr + 2'b1;
    endcase
end
endtask

task init();
begin
    set0_ptr = 2'b00;
    set1_ptr = 2'b00;
    set2_ptr = 2'b00;
    set3_ptr = 2'b00;
    reset_flag();
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
     2'b00:begin 
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

task read_miss_update();
begin
    dirty = 1'b0;
end
endtask

reg        s_rvalid_r;
reg [31:0] s_rdata_r;
reg        m_wvalid_r;
reg        m_awvalid_r;
reg        m_arvalid_r;
reg [31:0] m_araddr_r;
reg [31:0] m_awaddr_r;
reg [31:0] m_wdata_r;
reg        m_wlast_r;
reg        bus_addr_ok;
reg [31:0] hit_cache_data;
reg        s_wready_r;

always @(posedge clk)
begin
    if(rst == `RST_ENABLE) begin
        init();    
    end else begin
        case(state)
        state_idle: begin
            if(s_arvalid == 1'b1) begin
            is_read = 1'b1;        
            get_s_addr_r();
            find_cache(hit_cache_data);
            if(hit == 1'b1) begin
                s_rvalid_r <= 1'b1;
                s_rdata_r <= hit_cache_data;
                state <= state_read_hit;
            end else begin
                if(dirty == 1'b1) begin
                    state <= state_read_miss_wait_awready;
                    m_awaddr_r <=  {s_addr_r[31:6],6'b00_0000};
                    m_awvalid_r <= 1'b1;
                    s_wready_r <= 1'b0;
                end else begin
                    state <= state_read_miss_wait_read_burst;
                    m_arvalid_r <= 1'b1;
                    m_araddr_r <= {s_addr_r[31:6],6'b00_0000};
                end
            end
            end
        end
        state_read_hit: begin
                update_flag();
                s_rvalid_r <= 1'b0;
        end
        state_read_miss_wait_awready: begin
            if(m_awready == 1'b1) begin
                 m_awvalid_r <= 1'b0; 
                 m_wvalid_r <= 1'b1;
                 state <=state_read_miss_wait_write_burst;  
                 write_cacheline_to_ram(m_wdata_r);
                 cacheline_ptr <= cacheline_ptr + 4'b1;
            end
        end
        state_read_miss_wait_write_burst: begin
            if(m_wready) begin
                write_cacheline_to_ram(m_wdata_r);
                cacheline_ptr <= cacheline_ptr + 4'b1;
                if(cacheline_ptr == 4'b0000) begin 
                    state <= state_read_miss_wait_read_burst;
                    m_wlast_r <= 1'b1;
                    m_araddr_r <= {s_addr_r[31:6],6'b00_0000};
                end
            end
        end
        state_read_miss_wait_read_burst: begin
            m_wlast_r <= 1'b0;
            m_wvalid_r <= 1'b0;
            if(m_arready) m_arvalid_r <= 1'b0;
            if(m_rvalid == 1'b1) cache_write_data();
            if(m_rlast == 1'b1) begin
                state <= state_read_miss_wait_finish;
                read_miss_update();
            end
        end
        state_read_miss_wait_finish: begin
              find_cache(hit_cache_data);
              if(hit == 1'b1) begin
                  s_rvalid_r <= 1'b1;
                  s_rdata_r  <= hit_cache_data;
                  state <= state_read_hit;
              end
        end
        
        endcase

        /*
        end else if(s_wvalid != 4'b000 && state == state_idle) begin
            get_s_data_wvalid_r();
            cache_write_hit();
            if(hit == 1'b1) begin
                state <= state_write_hit;
                s_wready_r <= 1'b1;
            end else begin 
                if(dirty == 1'b1) begin
                    state <= state_write_miss_wait_write;
                end
                else begin 
                    state <= state_write_miss_wait_read;
                end
            end
            */
   end
end
assign m_wlast = m_wlast_r;
assign m_wvalid = m_wvalid_r;
assign s_wready = s_wready_r;
assign m_wdata = m_wdata_r;

endmodule
