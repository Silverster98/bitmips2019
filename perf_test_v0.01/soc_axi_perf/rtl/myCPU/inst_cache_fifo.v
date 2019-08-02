`include "defines.v"
module inst_cache_fifo(
    input         rst            ,
    input         clk            ,
    input         cache_ena      ,
    
    output [31:0] m_araddr       ,
    output        m_arvalid      ,
    input         m_arready      ,
    input  [31:0] m_rdata        ,
    input         m_rlast        ,
    input         m_rvalid       ,
    output        m_rready       ,

    input  [31:0] s_araddr       ,
    input         s_arvalid      ,
    output [31:0] s_rdata        ,
    output        s_rvalid       


);

assign m_rready = 1'b1;

reg [536:0] set0[3:0];
reg [536:0] set1[3:0];
reg [536:0] set2[3:0];
reg [536:0] set3[3:0];

`ifdef inst_cache_2KB
reg [536:0] set4[3:0];
reg [536:0] set5[3:0];
reg [536:0] set6[3:0];
reg [536:0] set7[3:0];
`endif

reg [31:0]  addr_r;
reg         hit;
reg         set0_hit;
reg         set1_hit;
reg         set2_hit;
reg         set3_hit;

`ifdef inst_cache_2KB
reg         set4_hit;
reg         set5_hit;
reg         set6_hit;
reg         set7_hit;
`endif

reg [1:0]   set0_ptr;
reg [1:0]   set1_ptr;
reg [1:0]   set2_ptr;
reg [1:0]   set3_ptr;

`ifdef inst_cache_2KB
reg [1:0]	set4_ptr;
reg [1:0]	set5_ptr;
reg [1:0]	set6_ptr;
reg [1:0]	set7_ptr;
`endif

reg [31:0]  s_araddr_r;
reg [3:0]   cacheline_ptr;


reg [2:0]  state;
parameter [2:0] state_idle = 3'b000;
parameter [2:0] state_wait_ram = 3'b001;
parameter [2:0] state_hit = 3'b010;
parameter [2:0] state_wait_done = 3'b011;
parameter [2:0] state_uncache_wait_ram = 3'b100;
parameter [2:0] state_uncache_wait_done = 3'b101;

task cacheline_get_data(input [536:0] cacheline ,output [31:0] cacheline_data);
    case(s_araddr_r[5:2])
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
	`ifndef inst_cache_2KB
    4'hf:   begin cacheline[`addr15] =  m_rdata; cacheline[`addr_tag] = s_araddr_r[31:8]; end
    `else
	4'hf:   begin cacheline[`addr15] =  m_rdata; cacheline[`addr_tag] = s_araddr_r[31:9]; end
	`endif
	endcase
    cacheline_ptr = cacheline_ptr + 4'h1;
end
endtask

`ifdef inst_cache_2KB

task find_set0(output [31:0] data);
begin
    if (set0[0][`addr_tag] == s_araddr_r[31:9] ) begin
        set0_hit = 1'b1;
        cacheline_get_data(set0[0],data);
    end else if (set0[1][`addr_tag] == s_araddr_r[31:9] ) begin
        set0_hit = 1'b1;
        cacheline_get_data(set0[1],data);
    end else if (set0[2][`addr_tag] == s_araddr_r[31:9] ) begin
        set0_hit = 1'b1;
        cacheline_get_data(set0[2],data);
    end else if (set0[3][`addr_tag] == s_araddr_r[31:9]) begin
        set0_hit = 1'b1;
        cacheline_get_data(set0[3],data);
    end else set0_hit = 1'b0;
end    
endtask

task find_set1(output [31:0] data);
begin
    if (set1[0][`addr_tag] == s_araddr_r[31:9] ) begin
        set1_hit = 1'b1;
        cacheline_get_data(set1[0],data);
    end else if (set1[1][`addr_tag] == s_araddr_r[31:9] ) begin
        set1_hit = 1'b1;
        cacheline_get_data(set1[1],data);
    end else if (set1[2][`addr_tag] == s_araddr_r[31:9] ) begin
        set1_hit = 1'b1;
        cacheline_get_data(set1[2],data);
    end else if (set1[3][`addr_tag] == s_araddr_r[31:9]) begin
        set1_hit = 1'b1;
        cacheline_get_data(set1[3],data);
    end else set1_hit = 1'b0;
end    
endtask

task find_set2(output [31:0] data);
begin
    if (set2[0][`addr_tag] == s_araddr_r[31:9] ) begin
        set2_hit = 1'b1;
        cacheline_get_data(set2[0],data);
    end else if (set2[1][`addr_tag] == s_araddr_r[31:9] ) begin
        set2_hit = 1'b1;
        cacheline_get_data(set2[1],data);
    end else if (set2[2][`addr_tag] == s_araddr_r[31:9] ) begin
        set2_hit = 1'b1;
        cacheline_get_data(set2[2],data);
    end else if (set2[3][`addr_tag] == s_araddr_r[31:9]) begin
        set2_hit = 1'b1;
        cacheline_get_data(set2[3],data);
    end else set2_hit = 1'b0;
end    
endtask

task find_set3(output [31:0] data);
begin
    if (set3[0][`addr_tag] == s_araddr_r[31:9] ) begin
        set3_hit = 1'b1;
        cacheline_get_data(set3[0],data);
    end else if (set3[1][`addr_tag] == s_araddr_r[31:9] ) begin
        set3_hit = 1'b1;
        cacheline_get_data(set3[1],data);
    end else if (set3[2][`addr_tag] == s_araddr_r[31:9] ) begin
        set3_hit = 1'b1;
        cacheline_get_data(set3[2],data);
    end else if (set3[3][`addr_tag] == s_araddr_r[31:9]) begin
        set3_hit = 1'b1;
        cacheline_get_data(set3[3],data);
    end else set3_hit = 1'b0;
end    
endtask

task find_set4(output [31:0] data);
begin
    if (set4[0][`addr_tag] == s_araddr_r[31:9] ) begin
        set4_hit = 1'b1;
        cacheline_get_data(set4[0],data);
    end else if (set4[1][`addr_tag] == s_araddr_r[31:9] ) begin
        set4_hit = 1'b1;
        cacheline_get_data(set4[1],data);
    end else if (set4[2][`addr_tag] == s_araddr_r[31:9] ) begin
        set4_hit = 1'b1;
        cacheline_get_data(set4[2],data);
    end else if (set4[3][`addr_tag] == s_araddr_r[31:9]) begin
        set4_hit = 1'b1;
        cacheline_get_data(set4[3],data);
    end else set4_hit = 1'b0;
end    
endtask

task find_set5(output [31:0] data);
begin
    if (set5[0][`addr_tag] == s_araddr_r[31:9] ) begin
        set5_hit = 1'b1;
        cacheline_get_data(set5[0],data);
    end else if (set5[1][`addr_tag] == s_araddr_r[31:9] ) begin
        set5_hit = 1'b1;
        cacheline_get_data(set5[1],data);
    end else if (set5[2][`addr_tag] == s_araddr_r[31:9] ) begin
        set5_hit = 1'b1;
        cacheline_get_data(set5[2],data);
    end else if (set5[3][`addr_tag] == s_araddr_r[31:9]) begin
        set5_hit = 1'b1;
        cacheline_get_data(set5[3],data);
    end else set5_hit = 1'b0;
end    
endtask

task find_set6(output [31:0] data);
begin
    if (set6[0][`addr_tag] == s_araddr_r[31:9] ) begin
        set6_hit = 1'b1;
        cacheline_get_data(set6[0],data);
    end else if (set6[1][`addr_tag] == s_araddr_r[31:9] ) begin
        set6_hit = 1'b1;
        cacheline_get_data(set6[1],data);
    end else if (set6[2][`addr_tag] == s_araddr_r[31:9] ) begin
        set6_hit = 1'b1;
        cacheline_get_data(set6[2],data);
    end else if (set6[3][`addr_tag] == s_araddr_r[31:9]) begin
        set6_hit = 1'b1;
        cacheline_get_data(set6[3],data);
    end else set6_hit = 1'b0;
end    
endtask

task find_set7(output [31:0] data);
begin
    if (set7[0][`addr_tag] == s_araddr_r[31:9] ) begin
        set7_hit = 1'b1;
        cacheline_get_data(set7[0],data);
    end else if (set7[1][`addr_tag] == s_araddr_r[31:9] ) begin
        set7_hit = 1'b1;
        cacheline_get_data(set7[1],data);
    end else if (set7[2][`addr_tag] == s_araddr_r[31:9] ) begin
        set7_hit = 1'b1;
        cacheline_get_data(set7[2],data);
    end else if (set7[3][`addr_tag] == s_araddr_r[31:9]) begin
        set7_hit = 1'b1;
        cacheline_get_data(set7[3],data);
    end else set7_hit = 1'b0;
end    
endtask


`else


task find_set0(output [31:0] data);
begin
    if (set0[0][`addr_tag] == s_araddr_r[31:8] ) begin
        set0_hit = 1'b1;
        cacheline_get_data(set0[0],data);
    end else if (set0[1][`addr_tag] == s_araddr_r[31:8] ) begin
        set0_hit = 1'b1;
        cacheline_get_data(set0[1],data);
    end else if (set0[2][`addr_tag] == s_araddr_r[31:8] ) begin
        set0_hit = 1'b1;
        cacheline_get_data(set0[2],data);
    end else if (set0[3][`addr_tag] == s_araddr_r[31:8]) begin
        set0_hit = 1'b1;
        cacheline_get_data(set0[3],data);
    end else set0_hit = 1'b0;
end    
endtask

task find_set1(output [31:0] data);
begin
    if (set1[0][`addr_tag] == s_araddr_r[31:8]) begin
        set1_hit = 1'b1;
        cacheline_get_data(set1[0],data);
    end else if (set1[1][`addr_tag] == s_araddr_r[31:8]) begin
        set1_hit = 1'b1;
        cacheline_get_data(set1[1],data);
    end else if (set1[2][`addr_tag] == s_araddr_r[31:8]) begin
        set1_hit = 1'b1;
        cacheline_get_data(set1[2],data);
    end else if (set1[3][`addr_tag] == s_araddr_r[31:8]) begin
        set1_hit = 1'b1;
        cacheline_get_data(set1[3],data);
    end else set1_hit = 1'b0;
end    
endtask

task find_set2(output [31:0] data);
begin
    if (set2[0][`addr_tag] == s_araddr_r[31:8]) begin
        set2_hit = 1'b1;
        cacheline_get_data(set2[0],data);
    end else if (set2[1][`addr_tag] == s_araddr_r[31:8]) begin
        set2_hit = 1'b1;
        cacheline_get_data(set2[1],data);
    end else if (set2[2][`addr_tag] == s_araddr_r[31:8]) begin
        set2_hit = 1'b1;
        cacheline_get_data(set2[2],data);
    end else if (set2[3][`addr_tag] == s_araddr_r[31:8]) begin
        set2_hit = 1'b1;
        cacheline_get_data(set2[3],data);
    end else set2_hit = 1'b0;
end    
endtask

task find_set3(output [31:0] data);
begin
    if (set3[0][`addr_tag] == s_araddr_r[31:8]) begin
        set3_hit = 1'b1;
        cacheline_get_data(set3[0],data);
    end else if (set3[1][`addr_tag] == s_araddr_r[31:8]) begin
        set3_hit = 1'b1;
        cacheline_get_data(set3[1],data);
    end else if (set3[2][`addr_tag] == s_araddr_r[31:8]) begin
        set3_hit = 1'b1;
        cacheline_get_data(set3[2],data);
    end else if (set3[3][`addr_tag] == s_araddr_r[31:8]) begin
        set3_hit = 1'b1;
        cacheline_get_data(set3[3],data);
    end
    else set3_hit = 1'b0;
end    
endtask

`endif

reg [31:0] set0_data;
reg [31:0] set1_data;
reg [31:0] set2_data;
reg [31:0] set3_data;

`ifdef inst_cache_2KB
reg [31:0] set4_data;
reg [31:0] set5_data;
reg [31:0] set6_data;
reg [31:0] set7_data;
`endif


task find_cache(output [31:0] data);
begin
	`ifdef inst_cache_2KB
    case(s_araddr_r[8:6])
	3'b000:find_set0(set0_data);
	3'b001:find_set1(set1_data);
	3'b010:find_set2(set2_data);
	3'b011:find_set3(set3_data);
	3'b100:find_set4(set4_data);
	3'b101:find_set5(set5_data);
	3'b110:find_set6(set6_data);
	3'b111:find_set7(set7_data);
	endcase
	hit = set0_hit | set1_hit | set2_hit | set3_hit | set4_hit | set5_hit | set6_hit | set7_hit;
	if(set0_hit) data = set0_data;
    else if(set1_hit) data = set1_data;
    else if(set2_hit) data = set2_data;
    else if(set3_hit) data = set3_data;
    else if(set4_hit) data = set4_data;
	else if(set5_hit) data = set5_data;
    else if(set6_hit) data = set6_data;
	else if(set7_hit) data = set7_data;
    else data = 32'b0;
	`else
	case(s_araddr_r[7:6])
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
	`endif
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

`ifdef inst_cache_2KB
task set4_write_data();
begin
    case(set4_ptr)  //current cacheline
        2'd0: cacheline_write_data(set4[0]);
        2'd1: cacheline_write_data(set4[1]);
        2'd2: cacheline_write_data(set4[2]);
        2'd3: cacheline_write_data(set4[3]);
    endcase
    if(cacheline_ptr == 4'b0000) set4_ptr = set4_ptr + 2'b1;
end
endtask

task set5_write_data();
begin
    case(set5_ptr)  //current cacheline
        2'd0: cacheline_write_data(set5[0]);
        2'd1: cacheline_write_data(set5[1]);
        2'd2: cacheline_write_data(set5[2]);
        2'd3: cacheline_write_data(set5[3]);
    endcase
    if(cacheline_ptr == 4'b0000) set5_ptr = set5_ptr + 2'b1;
end
endtask

task set6_write_data();
begin
    case(set6_ptr)  //current cacheline
        2'd0: cacheline_write_data(set6[0]);
        2'd1: cacheline_write_data(set6[1]);
        2'd2: cacheline_write_data(set6[2]);
        2'd3: cacheline_write_data(set6[3]);
    endcase
    if(cacheline_ptr == 4'b0000) set6_ptr = set6_ptr + 2'b1;
end
endtask

task set7_write_data();
begin
    case(set7_ptr)  //current cacheline
        2'd0: cacheline_write_data(set7[0]);
        2'd1: cacheline_write_data(set7[1]);
        2'd2: cacheline_write_data(set7[2]);
        2'd3: cacheline_write_data(set7[3]);
    endcase
    if(cacheline_ptr == 4'b0000) set7_ptr = set7_ptr + 2'b1;
end
endtask
`endif

task cache_write_data();
	`ifdef inst_cache_2KB
	case(s_araddr_r[8:6])
	3'b000: set0_write_data();
	3'b001: set1_write_data();
	3'b010: set2_write_data();
	3'b011: set3_write_data();
	3'b100: set4_write_data();
	3'b101: set5_write_data();
	3'b110: set6_write_data();
	3'b111: set7_write_data();
	endcase
	`else
    case(s_araddr_r[7:6])
    2'b00: begin set0_write_data(); end
    2'b01: begin set1_write_data(); end
    2'b10: begin set2_write_data(); end
    2'b11: begin set3_write_data(); end
    endcase
    `endif
endtask



reg [31:0] hit_cache_data;
reg        s_rvalid_r;
reg [31:0] s_rdata_r;
reg        m_arvalid_r;
reg [31:0] m_araddr_r;

task init();
begin
    state = state_idle;
    s_rvalid_r = 1'b0;
    m_arvalid_r = 1'b0;
    set0_ptr = 2'b00;
    set1_ptr = 2'b00;
    set2_ptr = 2'b00;
    set3_ptr = 2'b00;
    set0_hit = 1'b0;
    set1_hit = 1'b0;
    set2_hit = 1'b0;
    set3_hit = 1'b0;
	`ifdef inst_cache_2KB
	set4_ptr = 2'b00;
	set5_ptr = 2'b00;
	set6_ptr = 2'b00;
	set7_ptr = 2'b00;
	set4_hit = 1'b0;
	set5_hit = 1'b0;
	set6_hit = 1'b0;
	set7_hit = 1'b0;
	`endif
    hit = 1'b0;
    cacheline_ptr = 1'b0;
end
endtask

task get_s_araddr_r();
    s_araddr_r = s_araddr;
endtask 

reg bus_addr_ok;

always @(posedge clk)
begin
    if(rst == `RST_ENABLE) begin
        init();
    end else begin
        if(state == state_idle && s_arvalid == 1'b1) begin
            get_s_araddr_r();
            if(cache_ena) begin
                find_cache(hit_cache_data);
                if(hit == 1'b1) begin
                    s_rvalid_r <= 1'b1;
                    s_rdata_r  <= hit_cache_data;
                    state <= state_hit;
                end else begin
                    s_rvalid_r <= 1'b0;
                    state <= state_wait_ram; 
                    m_arvalid_r <= 1'b1;
                    m_araddr_r <= {s_araddr_r[31:6],6'b00_0000};
                    if(m_arready == 1'b1) bus_addr_ok = 1'b1;
                end
            end else begin 
                s_rvalid_r <= 1'b0;
                state <= state_uncache_wait_ram; 
                m_arvalid_r <= 1'b1;
                m_araddr_r <= s_araddr_r;
            end
        end else if(state == state_hit) begin
               set0_hit <= 1'b0;
               set1_hit <= 1'b0;
               set2_hit <= 1'b0;
               set3_hit <= 1'b0;
               `ifdef inst_cache_2KB
			   set4_hit <= 1'b0;
			   set5_hit <= 1'b0;
			   set6_hit <= 1'b0;
			   set7_hit <= 1'b0;
			   `endif
			   hit <= 1'b0;
               s_rvalid_r <= 1'b0;
               state <= state_idle;
        end else if(state == state_wait_ram) begin
            if(bus_addr_ok || m_arready)
                m_arvalid_r <= 1'b0;
            if(m_rvalid == 1'b1)
                cache_write_data();
            if(m_rlast == 1'b1)
                state <= state_wait_done;
        end else if(state == state_wait_done) begin
            find_cache(hit_cache_data);
            if(hit == 1'b1) begin
                bus_addr_ok <= 1'b0;
                s_rvalid_r <= 1'b1;
                s_rdata_r  <= hit_cache_data;
                state <= state_hit;
            end 
        end else if(state == state_uncache_wait_ram) begin
            if(bus_addr_ok || m_arready)
                m_arvalid_r <= 1'b0;
            if(m_rvalid == 1'b1) begin
                hit_cache_data <= m_rdata;
                state <= state_uncache_wait_done;
            end
        end else if(state == state_uncache_wait_done) begin
            s_rvalid_r <= 1'b1;  
            s_rdata_r  <= hit_cache_data;    
            state <= state_hit;
        end
    end
end

assign s_rvalid = s_rvalid_r;
assign s_rdata  = s_rdata_r;
assign m_arvalid = m_arvalid_r;
assign m_araddr = m_araddr_r;

endmodule
