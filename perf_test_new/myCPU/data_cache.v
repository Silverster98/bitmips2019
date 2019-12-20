`timescale 1ns / 1ps

module data_cache(
    input         clk,
    input         rstn,
    
    // axi
    // ar
    output [3 :0] arid   ,
    output [31:0] araddr ,
    output [7 :0] arlen  ,
    output [2 :0] arsize ,
    output [1 :0] arburst,
    output [1 :0] arlock ,
    output [3 :0] arcache,
    output [2 :0] arprot ,
    output        arvalid,
    input         arready,
    //r
    input  [3 :0] rid    ,
    input  [31:0] rdata  ,
    input  [1 :0] rresp ,
    input         rlast ,
    input         rvalid ,
    output        rready ,
    //aw
    output [3 :0] awid   ,
    output [31:0] awaddr ,
    output [7 :0] awlen  ,
    output [2 :0] awsize ,
    output [1 :0] awburst,
    output [1 :0] awlock ,
    output [3 :0] awcache,
    output [2 :0] awprot ,
    output        awvalid,
    input         awready,
    //w
    output [3 :0] wid    ,
    output [31:0] wdata  ,
    output [3 :0] wstrb  ,
    output        wlast  ,
    output        wvalid ,
    input         wready ,
    //b
    input  [3 :0] bid    ,
    input  [1 :0] bresp  ,
    input         bvalid ,
    output        bready ,
    
    // from cpu, sram like
    input         data_req,
    input         data_wr,
    input  [1:0]  data_size,
    input  [31:0] data_addr,
    input  [31:0] data_wdata,
    output        data_addr_ok,
    output        data_data_ok,
    output [31:0] data_rdata,

    input         data_cache
    );
    
    wire rst;
    assign rst = ~rstn;
    
    reg[31:0] data_addr_r;
    reg[31:0] data_wdata_r;
    reg[1:0] data_size_r;
    reg data_cache_r;
    always @ (posedge clk) begin
        if (data_req) begin
            data_addr_r <= data_addr;
            data_wdata_r <= data_wdata;
            data_size_r <= data_size;
            data_cache_r <= data_cache;
        end
    end
    
    reg[127:0] lru;
    reg[127:0] way0_dirty;
    reg[127:0] way1_dirty;
    
    wire tag0_wen;
    wire tag1_wen;
    wire[20:0] tag_wdata;
//    wire[31:0] access_tag_addr;
    wire[31:0] access_cache_addr;
    wire hit0, hit1, hit;
    wire valid0, valid1;
    wire work0, work1;
    wire op0, op1;
    wire[19:0] tag0_rdata, tag1_rdata;
    dcache_tag dcache_tag_0(rst, clk, tag0_wen, tag_wdata, access_cache_addr, tag0_rdata, hit0, valid0, work0, op0);
    dcache_tag dcache_tag_1(rst, clk, tag1_wen, tag_wdata, access_cache_addr, tag1_rdata, hit1, valid1, work1, op1);
    
    wire[31:0] dcache_way0_0_rdata;
    wire[31:0] dcache_way0_1_rdata;
    wire[31:0] dcache_way0_2_rdata;
    wire[31:0] dcache_way0_3_rdata;
    wire[31:0] dcache_way0_4_rdata;
    wire[31:0] dcache_way0_5_rdata;
    wire[31:0] dcache_way0_6_rdata;
    wire[31:0] dcache_way0_7_rdata;
    wire[31:0] dcache_way1_0_rdata;
    wire[31:0] dcache_way1_1_rdata;
    wire[31:0] dcache_way1_2_rdata;
    wire[31:0] dcache_way1_3_rdata;
    wire[31:0] dcache_way1_4_rdata;
    wire[31:0] dcache_way1_5_rdata;
    wire[31:0] dcache_way1_6_rdata;
    wire[31:0] dcache_way1_7_rdata;
    
    wire[31:0] cache_wdata;
    wire[7:0] way0_wen;
    wire[7:0] way1_wen;
    wire[3:0] way0_data0_wen;
    wire[3:0] way0_data1_wen;
    wire[3:0] way0_data2_wen;
    wire[3:0] way0_data3_wen;
    wire[3:0] way0_data4_wen;
    wire[3:0] way0_data5_wen;
    wire[3:0] way0_data6_wen;
    wire[3:0] way0_data7_wen;
    wire[3:0] way1_data0_wen;
    wire[3:0] way1_data1_wen;
    wire[3:0] way1_data2_wen;
    wire[3:0] way1_data3_wen;
    wire[3:0] way1_data4_wen;
    wire[3:0] way1_data5_wen;
    wire[3:0] way1_data6_wen;
    wire[3:0] way1_data7_wen;
    
    
    
    dcache_data way0_data_0(clk, rst, 1'b1, way0_data0_wen, cache_wdata, access_cache_addr, dcache_way0_0_rdata);
    dcache_data way0_data_1(clk, rst, 1'b1, way0_data1_wen, cache_wdata, access_cache_addr, dcache_way0_1_rdata);
    dcache_data way0_data_2(clk, rst, 1'b1, way0_data2_wen, cache_wdata, access_cache_addr, dcache_way0_2_rdata);
    dcache_data way0_data_3(clk, rst, 1'b1, way0_data3_wen, cache_wdata, access_cache_addr, dcache_way0_3_rdata);
    dcache_data way0_data_4(clk, rst, 1'b1, way0_data4_wen, cache_wdata, access_cache_addr, dcache_way0_4_rdata);
    dcache_data way0_data_5(clk, rst, 1'b1, way0_data5_wen, cache_wdata, access_cache_addr, dcache_way0_5_rdata);
    dcache_data way0_data_6(clk, rst, 1'b1, way0_data6_wen, cache_wdata, access_cache_addr, dcache_way0_6_rdata);
    dcache_data way0_data_7(clk, rst, 1'b1, way0_data7_wen, cache_wdata, access_cache_addr, dcache_way0_7_rdata);
    dcache_data way1_data_0(clk, rst, 1'b1, way1_data0_wen, cache_wdata, access_cache_addr, dcache_way1_0_rdata);
    dcache_data way1_data_1(clk, rst, 1'b1, way1_data1_wen, cache_wdata, access_cache_addr, dcache_way1_1_rdata);
    dcache_data way1_data_2(clk, rst, 1'b1, way1_data2_wen, cache_wdata, access_cache_addr, dcache_way1_2_rdata);
    dcache_data way1_data_3(clk, rst, 1'b1, way1_data3_wen, cache_wdata, access_cache_addr, dcache_way1_3_rdata);
    dcache_data way1_data_4(clk, rst, 1'b1, way1_data4_wen, cache_wdata, access_cache_addr, dcache_way1_4_rdata);
    dcache_data way1_data_5(clk, rst, 1'b1, way1_data5_wen, cache_wdata, access_cache_addr, dcache_way1_5_rdata);
    dcache_data way1_data_6(clk, rst, 1'b1, way1_data6_wen, cache_wdata, access_cache_addr, dcache_way1_6_rdata);
    dcache_data way1_data_7(clk, rst, 1'b1, way1_data7_wen, cache_wdata, access_cache_addr, dcache_way1_7_rdata);
    
    
    wire dirty_victim;
    reg[2:0] write_counter;
    reg[2:0] read_counter;
    reg[31:0] wait_data;
    reg[4:0] work_state;
    parameter[4:0] state_reset = 5'b00000;
    parameter[4:0] state_access_ram_read_0 = 5'b00001;
    parameter[4:0] state_access_ram_read_1 = 5'b00010;
    parameter[4:0] state_access_ram_write_0 = 5'b00011;
    parameter[4:0] state_access_ram_write_1 = 5'b00100;
    parameter[4:0] state_access_ram_write_2 = 5'b00101;
    parameter[4:0] state_data_ready = 5'b00110;
    parameter[4:0] state_lookup_read = 5'b00111;
    parameter[4:0] state_lookup_write = 5'b01000;
    parameter[4:0] state_miss_write_read_0 = 5'b01001;
    parameter[4:0] state_miss_write_read_1 = 5'b01010;
    parameter[4:0] state_miss_write_read_2 = 5'b01011;
    parameter[4:0] state_miss_access_ram_read_0 = 5'b01100;
    parameter[4:0] state_miss_access_ram_read_1 = 5'b01101;
    parameter[4:0] state_miss_read_update = 5'b01110;
    parameter[4:0] state_miss_write_write_0 = 5'b01111;
    parameter[4:0] state_miss_write_write_1 = 5'b10000;
    parameter[4:0] state_miss_write_write_2 = 5'b10001;
    parameter[4:0] state_miss_access_ram_read_2 = 5'b10010;
    parameter[4:0] state_miss_access_ram_read_3 = 5'b10011;
    parameter[4:0] state_miss_write_update = 5'b10100;
    
    always @ (posedge clk) begin
        if (rst) begin
            work_state <= state_reset;
            wait_data <= 32'b0;
            write_counter <= 3'b0;
            read_counter <= 3'b0;
        end else begin
            case(work_state)
            state_reset: begin 
                if (data_req == 1'b1) begin
                    if (data_wr == 1'b0) begin
                        if (work0 && work1 && data_cache) work_state <= state_lookup_read;
                        else work_state <= state_access_ram_read_0;
                    end else if (data_wr == 1'b1) begin
                        if (work0 && work1 && data_cache) work_state <= state_lookup_write;
                        else work_state <= state_access_ram_write_0;
                    end
                end
            end
            state_access_ram_read_0: begin // uncache read
                if (arready) work_state <= state_access_ram_read_1;
            end
            state_access_ram_read_1: begin
                if (rvalid) begin
                    work_state <= state_data_ready;
                    wait_data <= rdata;
                end
            end
            state_data_ready: begin
                if (data_req == 1'b1) begin
                    if (data_wr == 1'b0) begin
                        if (work0 && work1 && data_cache) work_state <= state_lookup_read;
                        else work_state <= state_access_ram_read_0;
                    end else if (data_wr == 1'b1) begin
                        if (work0 && work1 && data_cache) work_state <= state_lookup_write;
                        else work_state <= state_access_ram_write_0;
                    end
                end else work_state <= state_reset;
            end 
            state_access_ram_write_0: begin // uncache write
                if (awready) work_state <= state_access_ram_write_1;
            end 
            state_access_ram_write_1: begin
                if (wready) work_state <= state_access_ram_write_2;
            end 
            state_access_ram_write_2: begin
                work_state <= state_data_ready;
            end 
            state_lookup_read: begin // cache read
                if (hit) begin
                    if (data_req == 1'b1) begin
                        if (data_wr == 1'b0) begin
                            if (work0 && work1 && data_cache) work_state <= state_lookup_read;
                            else work_state <= state_access_ram_read_0;
                        end else if (data_wr == 1'b1) begin
                            if (work0 && work1 && data_cache) work_state <= state_lookup_write;
                            else work_state <= state_access_ram_write_0;
                        end
                    end else work_state <= state_reset;
                end
                else begin
                    if (dirty_victim) work_state <= state_miss_write_read_0;
                    else work_state <= state_miss_access_ram_read_0;
                end
            end 
            state_miss_access_ram_read_0: begin
                if (arready) work_state <= state_miss_access_ram_read_1;
            end 
            state_miss_access_ram_read_1: begin
                if (rvalid) begin
                    read_counter <= read_counter + 1'b1;
                    if (read_counter == data_addr_r[4:2]) wait_data = rdata;
                end
                if (rlast && rvalid) begin
                    read_counter <= 3'b000;
                    work_state <= state_miss_read_update;
                end
            end 
            state_miss_read_update: begin
                work_state <= state_data_ready;
            end 
            state_miss_write_read_0: begin
                if (awready) work_state <= state_miss_write_read_1;
            end 
            state_miss_write_read_1: begin
                if (wready) begin
                     if (write_counter == 3'b111) begin
                        write_counter <= 3'b000;
                        work_state <= state_miss_write_read_2;
                     end else write_counter <= write_counter + 1'b1;
                end
            end 
            state_miss_write_read_2: begin
                if (bvalid) work_state <= state_miss_access_ram_read_0;
            end 
            state_lookup_write: begin // cache write
                if (hit) begin
                   work_state <= state_data_ready;
                end
                else begin
                    if (dirty_victim) work_state <= state_miss_write_write_0;
                    else work_state <= state_miss_access_ram_read_2;
                end
            end 
            state_miss_access_ram_read_2: begin
                if (arready) work_state <= state_miss_access_ram_read_3;
            end 
            state_miss_access_ram_read_3: begin
                if (rvalid) begin
                    read_counter <= read_counter + 1'b1;
                end
                if (rlast && rvalid) begin
                    read_counter <= 3'b000;
                    work_state <= state_miss_write_update;
                end
            end 
            state_miss_write_update: begin
                work_state <= state_data_ready;
            end
            state_miss_write_write_0: begin
                if (awready) work_state <= state_miss_write_write_1;
            end 
            state_miss_write_write_1: begin
                if (wready) begin
                     if (write_counter == 3'b111) begin
                        write_counter <= 3'b000;
                        work_state <= state_miss_write_write_2;
                     end else write_counter <= write_counter + 1'b1;
                end
            end
            state_miss_write_write_2: begin
                if (bvalid) work_state <= state_miss_access_ram_read_2;
            end
            default: ;
            endcase
        end
    end
    
    always @ (posedge clk) begin
        if (rst) begin
            lru <= 128'b0;
        end else begin
            if (work_state == state_lookup_read || work_state == state_lookup_write) begin
                if (hit0 && valid0) lru[data_addr_r[11:5]] <= 1'b1;
                else if (hit1 && valid1) lru[data_addr_r[11:5]] <= 1'b0;
            end else if (work_state == state_miss_read_update || work_state == state_miss_write_update) begin
                lru[data_addr_r[11:5]] <= ~lru[data_addr_r[11:5]];
            end
        end
    end
    
    always @ (posedge clk) begin
        if (rst) begin
            way0_dirty <= 128'b0;
        end else begin
            if (work_state == state_lookup_write && hit0 && valid0) begin
                way0_dirty[data_addr_r[11:5]] <= 1'b1;
            end else if (work_state == state_miss_read_update && lru[data_addr_r[11:5]] == 1'b0) begin
                way0_dirty[data_addr_r[11:5]] <= 1'b0;
            end else if (work_state == state_miss_write_update && lru[data_addr_r[11:5]] == 1'b0) begin
                way0_dirty[data_addr_r[11:5]] <= 1'b1;
            end 
        end
    end
    
    always @ (posedge clk) begin
        if (rst) begin
            way1_dirty <= 128'b0;
        end else begin
            if (work_state == state_lookup_write && hit1 && valid1) begin
                way1_dirty[data_addr_r[11:5]] <= 1'b1;
            end else if (work_state == state_miss_read_update && lru[data_addr_r[11:5]] == 1'b1) begin
                way1_dirty[data_addr_r[11:5]] <= 1'b0;
            end else if (work_state == state_miss_write_update && lru[data_addr_r[11:5]] == 1'b1) begin
                way1_dirty[data_addr_r[11:5]] <= 1'b1;
            end
        end
    end
    
    assign dirty_victim = lru[data_addr_r[11:5]] == 1'b0 ? way0_dirty[data_addr_r[11:5]] :
                          lru[data_addr_r[11:5]] == 1'b1 ? way1_dirty[data_addr_r[11:5]] : 1'b0;
    
    assign tag0_wen = ((work_state == state_miss_read_update || work_state == state_miss_write_update) && lru[data_addr_r[11:5]] == 1'b0) ? 1'b1 : 1'b0;
    assign tag1_wen = ((work_state == state_miss_read_update || work_state == state_miss_write_update) && lru[data_addr_r[11:5]] == 1'b1) ? 1'b1 : 1'b0;
    assign tag_wdata = (work_state == state_miss_read_update || work_state == state_miss_write_update) ? {1'b1, data_addr_r[31:12]} : 21'b0;
//    assign access_tag_addr = data_addr;
    
    assign hit = (hit0 && valid0) || (hit1 && valid1);
    wire[31:0] hit_word;
    wire[31:0] writeback_data;
    
    wire way0_burst_read_wen = (work_state == state_miss_access_ram_read_1 || work_state == state_miss_access_ram_read_3) && rvalid && lru[data_addr_r[11:5]] == 1'b0;
    wire way1_burst_read_wen = (work_state == state_miss_access_ram_read_1 || work_state == state_miss_access_ram_read_3) && rvalid && lru[data_addr_r[11:5]] == 1'b1;
    assign way0_wen[0] = ((way0_burst_read_wen && read_counter == 3'b000)) ? 1'b1 : 1'b0;
    assign way0_wen[1] = ((way0_burst_read_wen && read_counter == 3'b001)) ? 1'b1 : 1'b0;
    assign way0_wen[2] = ((way0_burst_read_wen && read_counter == 3'b010)) ? 1'b1 : 1'b0;
    assign way0_wen[3] = ((way0_burst_read_wen && read_counter == 3'b011)) ? 1'b1 : 1'b0;
    assign way0_wen[4] = ((way0_burst_read_wen && read_counter == 3'b100)) ? 1'b1 : 1'b0;
    assign way0_wen[5] = ((way0_burst_read_wen && read_counter == 3'b101)) ? 1'b1 : 1'b0;
    assign way0_wen[6] = ((way0_burst_read_wen && read_counter == 3'b110)) ? 1'b1 : 1'b0;
    assign way0_wen[7] = ((way0_burst_read_wen && read_counter == 3'b111)) ? 1'b1 : 1'b0;
    assign way1_wen[0] = ((way1_burst_read_wen && read_counter == 3'b000)) ? 1'b1 : 1'b0;
    assign way1_wen[1] = ((way1_burst_read_wen && read_counter == 3'b001)) ? 1'b1 : 1'b0;
    assign way1_wen[2] = ((way1_burst_read_wen && read_counter == 3'b010)) ? 1'b1 : 1'b0;
    assign way1_wen[3] = ((way1_burst_read_wen && read_counter == 3'b011)) ? 1'b1 : 1'b0;
    assign way1_wen[4] = ((way1_burst_read_wen && read_counter == 3'b100)) ? 1'b1 : 1'b0;
    assign way1_wen[5] = ((way1_burst_read_wen && read_counter == 3'b101)) ? 1'b1 : 1'b0;
    assign way1_wen[6] = ((way1_burst_read_wen && read_counter == 3'b110)) ? 1'b1 : 1'b0;
    assign way1_wen[7] = ((way1_burst_read_wen && read_counter == 3'b111)) ? 1'b1 : 1'b0;
    
    assign way0_data0_wen = (((work_state == state_lookup_write && hit0 && valid0) || (work_state == state_miss_write_update && lru[data_addr_r[11:5]] == 1'b0)) && data_addr_r[4:2] == 3'b000) ? get_wstrb(data_size_r, data_addr_r[1:0]) : {4{way0_wen[0]}}; 
    assign way0_data1_wen = (((work_state == state_lookup_write && hit0 && valid0) || (work_state == state_miss_write_update && lru[data_addr_r[11:5]] == 1'b0)) && data_addr_r[4:2] == 3'b001) ? get_wstrb(data_size_r, data_addr_r[1:0]) : {4{way0_wen[1]}};
    assign way0_data2_wen = (((work_state == state_lookup_write && hit0 && valid0) || (work_state == state_miss_write_update && lru[data_addr_r[11:5]] == 1'b0)) && data_addr_r[4:2] == 3'b010) ? get_wstrb(data_size_r, data_addr_r[1:0]) : {4{way0_wen[2]}};
    assign way0_data3_wen = (((work_state == state_lookup_write && hit0 && valid0) || (work_state == state_miss_write_update && lru[data_addr_r[11:5]] == 1'b0)) && data_addr_r[4:2] == 3'b011) ? get_wstrb(data_size_r, data_addr_r[1:0]) : {4{way0_wen[3]}};
    assign way0_data4_wen = (((work_state == state_lookup_write && hit0 && valid0) || (work_state == state_miss_write_update && lru[data_addr_r[11:5]] == 1'b0)) && data_addr_r[4:2] == 3'b100) ? get_wstrb(data_size_r, data_addr_r[1:0]) : {4{way0_wen[4]}};
    assign way0_data5_wen = (((work_state == state_lookup_write && hit0 && valid0) || (work_state == state_miss_write_update && lru[data_addr_r[11:5]] == 1'b0)) && data_addr_r[4:2] == 3'b101) ? get_wstrb(data_size_r, data_addr_r[1:0]) : {4{way0_wen[5]}};
    assign way0_data6_wen = (((work_state == state_lookup_write && hit0 && valid0) || (work_state == state_miss_write_update && lru[data_addr_r[11:5]] == 1'b0)) && data_addr_r[4:2] == 3'b110) ? get_wstrb(data_size_r, data_addr_r[1:0]) : {4{way0_wen[6]}};
    assign way0_data7_wen = (((work_state == state_lookup_write && hit0 && valid0) || (work_state == state_miss_write_update && lru[data_addr_r[11:5]] == 1'b0)) && data_addr_r[4:2] == 3'b111) ? get_wstrb(data_size_r, data_addr_r[1:0]) : {4{way0_wen[7]}};
    assign way1_data0_wen = (((work_state == state_lookup_write && hit1 && valid1) || (work_state == state_miss_write_update && lru[data_addr_r[11:5]] == 1'b1)) && data_addr_r[4:2] == 3'b000) ? get_wstrb(data_size_r, data_addr_r[1:0]) : {4{way1_wen[0]}};
    assign way1_data1_wen = (((work_state == state_lookup_write && hit1 && valid1) || (work_state == state_miss_write_update && lru[data_addr_r[11:5]] == 1'b1)) && data_addr_r[4:2] == 3'b001) ? get_wstrb(data_size_r, data_addr_r[1:0]) : {4{way1_wen[1]}};
    assign way1_data2_wen = (((work_state == state_lookup_write && hit1 && valid1) || (work_state == state_miss_write_update && lru[data_addr_r[11:5]] == 1'b1)) && data_addr_r[4:2] == 3'b010) ? get_wstrb(data_size_r, data_addr_r[1:0]) : {4{way1_wen[2]}};
    assign way1_data3_wen = (((work_state == state_lookup_write && hit1 && valid1) || (work_state == state_miss_write_update && lru[data_addr_r[11:5]] == 1'b1)) && data_addr_r[4:2] == 3'b011) ? get_wstrb(data_size_r, data_addr_r[1:0]) : {4{way1_wen[3]}};
    assign way1_data4_wen = (((work_state == state_lookup_write && hit1 && valid1) || (work_state == state_miss_write_update && lru[data_addr_r[11:5]] == 1'b1)) && data_addr_r[4:2] == 3'b100) ? get_wstrb(data_size_r, data_addr_r[1:0]) : {4{way1_wen[4]}};
    assign way1_data5_wen = (((work_state == state_lookup_write && hit1 && valid1) || (work_state == state_miss_write_update && lru[data_addr_r[11:5]] == 1'b1)) && data_addr_r[4:2] == 3'b101) ? get_wstrb(data_size_r, data_addr_r[1:0]) : {4{way1_wen[5]}};
    assign way1_data6_wen = (((work_state == state_lookup_write && hit1 && valid1) || (work_state == state_miss_write_update && lru[data_addr_r[11:5]] == 1'b1)) && data_addr_r[4:2] == 3'b110) ? get_wstrb(data_size_r, data_addr_r[1:0]) : {4{way1_wen[6]}};
    assign way1_data7_wen = (((work_state == state_lookup_write && hit1 && valid1) || (work_state == state_miss_write_update && lru[data_addr_r[11:5]] == 1'b1)) && data_addr_r[4:2] == 3'b111) ? get_wstrb(data_size_r, data_addr_r[1:0]) : {4{way1_wen[7]}};
    
    assign cache_wdata = (work_state == state_miss_access_ram_read_1 || work_state == state_miss_access_ram_read_3) ? rdata :
                         (work_state == state_lookup_write || work_state == state_miss_write_update) ? data_wdata_r : 32'b0;
    
    assign access_cache_addr = data_req ? data_addr : data_addr_r;
    
    wire[31:0] word_selection0, word_selection1;
    assign word_selection0 = (data_addr_r[4:2] == 3'b000) ? dcache_way0_0_rdata :
                             (data_addr_r[4:2] == 3'b001) ? dcache_way0_1_rdata :
                             (data_addr_r[4:2] == 3'b010) ? dcache_way0_2_rdata :
                             (data_addr_r[4:2] == 3'b011) ? dcache_way0_3_rdata :
                             (data_addr_r[4:2] == 3'b100) ? dcache_way0_4_rdata :
                             (data_addr_r[4:2] == 3'b101) ? dcache_way0_5_rdata :
                             (data_addr_r[4:2] == 3'b110) ? dcache_way0_6_rdata :
                             (data_addr_r[4:2] == 3'b111) ? dcache_way0_7_rdata : 32'b0;
    assign word_selection1 = (data_addr_r[4:2] == 3'b000) ? dcache_way1_0_rdata :
                             (data_addr_r[4:2] == 3'b001) ? dcache_way1_1_rdata :
                             (data_addr_r[4:2] == 3'b010) ? dcache_way1_2_rdata :
                             (data_addr_r[4:2] == 3'b011) ? dcache_way1_3_rdata :
                             (data_addr_r[4:2] == 3'b100) ? dcache_way1_4_rdata :
                             (data_addr_r[4:2] == 3'b101) ? dcache_way1_5_rdata :
                             (data_addr_r[4:2] == 3'b110) ? dcache_way1_6_rdata :
                             (data_addr_r[4:2] == 3'b111) ? dcache_way1_7_rdata : 32'b0;
    assign hit_word = (hit0 && valid0) ? word_selection0 :
                      (hit1 && valid1) ? word_selection1 : 32'b0;
    
    wire[31:0] wb_word0, wb_word1;
    assign wb_word0 = (write_counter == 3'b000) ? dcache_way0_0_rdata :       
                      (write_counter == 3'b001) ? dcache_way0_1_rdata :       
                      (write_counter == 3'b010) ? dcache_way0_2_rdata :       
                      (write_counter == 3'b011) ? dcache_way0_3_rdata :       
                      (write_counter == 3'b100) ? dcache_way0_4_rdata :       
                      (write_counter == 3'b101) ? dcache_way0_5_rdata :       
                      (write_counter == 3'b110) ? dcache_way0_6_rdata :       
                      (write_counter == 3'b111) ? dcache_way0_7_rdata : 32'b0;
    assign wb_word1 = (write_counter == 3'b000) ? dcache_way1_0_rdata :       
                      (write_counter == 3'b001) ? dcache_way1_1_rdata :       
                      (write_counter == 3'b010) ? dcache_way1_2_rdata :       
                      (write_counter == 3'b011) ? dcache_way1_3_rdata :       
                      (write_counter == 3'b100) ? dcache_way1_4_rdata :       
                      (write_counter == 3'b101) ? dcache_way1_5_rdata :       
                      (write_counter == 3'b110) ? dcache_way1_6_rdata :       
                      (write_counter == 3'b111) ? dcache_way1_7_rdata : 32'b0;
    assign writeback_data = (lru[data_addr_r[11:5]] == 1'b0) ? wb_word0 :
                            (lru[data_addr_r[11:5]] == 1'b1) ? wb_word1 : 32'b0;
    
    
    // ar
    assign arid = 4'b0000;
    assign araddr = (work_state == state_access_ram_read_0) ? {data_addr_r[31:2], 2'b00} :
                    (work_state == state_miss_access_ram_read_0 || work_state == state_miss_access_ram_read_2) ? {data_addr_r[31:5], 5'b00000} : 32'b0;
    assign arlen = (data_cache_r == 1'b1) ? 8'b0000_0111 : 8'b0000_0000;
    assign arsize = 3'b010;
    assign arburst = (data_cache_r == 1'b1) ? 2'b01 : 2'b00;
    assign arlock = 2'b00;
    assign arcache = 4'b0000;
    assign arprot = 3'b000;
    assign arvalid = (work_state == state_access_ram_read_0 || work_state == state_miss_access_ram_read_0 || work_state == state_miss_access_ram_read_2) ? 1'b1 : 1'b0;
    
    // r
    assign rready = 1'b1;
    
    // aw
    assign awid = 4'b0000;
    assign awaddr = (work_state == state_access_ram_write_0) ? {data_addr_r[31:2], 2'b00} :
                    ((work_state == state_miss_write_read_0 || work_state == state_miss_write_write_0) && lru[data_addr_r[11:5]] == 1'b0) ? {tag0_rdata, data_addr_r[11:5], 5'b0} :
                    ((work_state == state_miss_write_read_0 || work_state == state_miss_write_write_0) && lru[data_addr_r[11:5]] == 1'b1) ? {tag1_rdata, data_addr_r[11:5], 5'b0} : 32'b0;
    assign awlen = (data_cache_r == 1'b1) ? 8'b0000_0111 : 8'b0000_0000;
    assign awsize = 3'b010;
    assign awburst = (data_cache_r == 1'b1) ? 2'b01 : 2'b00;
    assign awlock = 2'b00;
    assign awcache = 4'b0000;
    assign awprot = 3'b000;
    assign awvalid = (work_state == state_access_ram_write_0 || work_state == state_miss_write_read_0 || work_state == state_miss_write_write_0) ? 1'b1 : 1'b0;
    
    // w
    assign wid = 4'b0000;
    assign wdata = (work_state == state_access_ram_write_1) ? data_wdata_r : 
                   (work_state == state_miss_write_read_1 || work_state == state_miss_write_write_1) ? writeback_data : 32'b0;
    assign wstrb = (work_state == state_access_ram_write_1) ? get_wstrb(data_size_r, data_addr_r[1:0]) :
                   (work_state == state_miss_write_read_1 || work_state == state_miss_write_write_1) ? 4'b1111 : 4'b0000;
    assign wlast = (work_state == state_access_ram_write_1 || (work_state == state_miss_write_read_1 && write_counter == 3'b111) || (work_state == state_miss_write_write_1 && write_counter == 3'b111)) ? 1'b1 : 1'b0;
    assign wvalid = (work_state == state_access_ram_write_1 || work_state == state_miss_write_read_1 || work_state == state_miss_write_write_1) ? 1'b1 : 1'b0;
    
    // b
    assign bready = 1'b1;
    
    
    // data sram like
    assign data_addr_ok = 1'b1;
    assign data_data_ok = (work_state == state_data_ready) ? 1'b1 : 
                          (work_state == state_lookup_read && hit) ? 1'b1 :
                          1'b0;
    assign data_rdata = (work_state == state_data_ready) ? wait_data :
                        (work_state == state_lookup_read) ? hit_word : 32'b0;
    
    
    function [3:0] get_wstrb(input [1:0] data_size, input [1:0] data_addr);
        begin
            case(data_size)
            2'b00: begin
                case(data_addr)
                2'b00: get_wstrb = 4'b0001;
                2'b01: get_wstrb = 4'b0010;
                2'b10: get_wstrb = 4'b0100;
                2'b11: get_wstrb = 4'b1000;
                default: get_wstrb = 4'b0000;
                endcase
            end
            2'b01: begin
                case(data_addr)
                2'b00: get_wstrb = 4'b0011;
                2'b10: get_wstrb = 4'b1100;
                default: get_wstrb = 4'b0000;
                endcase
            end
            2'b10: begin
                get_wstrb = 4'b1111;
            end
            default: get_wstrb = 4'b0000;
            endcase
        end
    endfunction
endmodule
