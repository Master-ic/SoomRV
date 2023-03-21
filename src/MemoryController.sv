module MemoryController#(parameter NUM_CACHES=2)
(
    input wire clk,
    input wire rst,
    
    input CTRL_MemC IN_ctrl,
    output STAT_MemC OUT_stat,
    
    output reg[NUM_CACHES-1:0] OUT_CACHE_used,
    output reg OUT_CACHE_we[NUM_CACHES-1:0],
    output reg OUT_CACHE_ce[NUM_CACHES-1:0],
    output reg[3:0] OUT_CACHE_wm[NUM_CACHES-1:0],
    output reg[9:0] OUT_CACHE_addr[NUM_CACHES-1:0],
    output reg[31:0] OUT_CACHE_data[NUM_CACHES-1:0],
    input wire[31:0] IN_CACHE_data[NUM_CACHES-1:0],
    
    output reg OUT_EXT_oen,
    output reg OUT_EXT_en,
    output reg[31:0] OUT_EXT_bus,
    input wire[31:0] IN_EXT_bus
    
);

integer i;

reg[2:0] state;
reg isExtWrite;

reg[9:0] sramAddr;
reg[9:0] cnt;
reg[9:0] len;
reg[$clog2(NUM_CACHES)-1:0] cacheID;

reg[2:0] waitCycles;

assign OUT_CACHE_wm[0] = 4'b1111;
assign OUT_CACHE_wm[1] = 4'b1111;

wire[31:0] outDataCacheIF;
wire[0:0] idCacheIF;
CacheInterface cacheIF
(
    .clk(clk),
    .rst(rst),
    
    .IN_en(state == 0 && IN_ctrl.cmd != MEMC_NONE),
    .IN_write(IN_ctrl.cmd == MEMC_CP_EXT_TO_CACHE),
    .IN_cacheID(IN_ctrl.cacheID),
    .IN_len(IN_ctrl.cacheID ? 128 : 64),
    .IN_addr(IN_ctrl.sramAddr),
    .OUT_busy(),
    
    .IN_valid(isExtWrite ? cnt > 2 : state == 3),
    .IN_data(IN_EXT_bus),
    .OUT_data(outDataCacheIF),
    
    .OUT_CACHE_id(idCacheIF),
    .OUT_CACHE_ce(OUT_CACHE_ce[idCacheIF]),
    .OUT_CACHE_we(OUT_CACHE_we[idCacheIF]),
    .OUT_CACHE_addr(OUT_CACHE_addr[idCacheIF]),
    .OUT_CACHE_data(OUT_CACHE_data[idCacheIF]),
    .IN_CACHE_data(IN_CACHE_data[idCacheIF])
);

always_ff@(posedge clk) begin
    
    if (rst) begin
        state <= 0;
        for (i = 0; i < NUM_CACHES; i=i+1) begin
            OUT_CACHE_used[i] <= 0;
        end
        OUT_stat.busy <= 0;
        OUT_EXT_oen <= 1;
        OUT_stat.progress <= 0;
        len <= 0;
        OUT_EXT_bus <= 0;
        OUT_EXT_en <= 0;
    end
    else begin
        
        case(state)
            
            // Idle
            0: begin
                OUT_EXT_oen <= 1;
                for (i = 0; i < NUM_CACHES; i=i+1)
                    OUT_CACHE_used[i] <= 0;
                    
                if (IN_ctrl.cmd != MEMC_NONE) begin
                    
                    
                    if (IN_ctrl.cmd == MEMC_CP_CACHE_TO_EXT) begin
                        // Write
                        isExtWrite <= 1;
                        state <= 2;
                        OUT_CACHE_used[IN_ctrl.cacheID] <= 1;
                        cnt <= 1;
                    end
                    else if (IN_ctrl.cmd == MEMC_CP_EXT_TO_CACHE) begin
                        // Read
                        isExtWrite <= 0;
                        waitCycles <= 3;
                        OUT_CACHE_used[IN_ctrl.cacheID] <= 1;
                        state <= 1;
                        cnt <= 0;
                        sramAddr <= IN_ctrl.sramAddr;
                    end
                    else assert(0);
                    
                    cacheID <= IN_ctrl.cacheID;
                    
                    if (IN_ctrl.cacheID == 0) len <= 64;
                    else len <= 128;
                    
                    // External RAM
                    OUT_EXT_en <= 1;
                    OUT_EXT_bus <= {IN_ctrl.cmd == MEMC_CP_CACHE_TO_EXT, IN_ctrl.cacheID[0], IN_ctrl.extAddr[29:0]};
                    OUT_EXT_oen <= 1;
                    
                    // Interface
                    OUT_stat.busy <= 1;
                    OUT_stat.progress <= 0;
                    OUT_stat.cacheID <= IN_ctrl.cacheID;
                end
                else begin
                    OUT_stat.busy <= 0;
                    OUT_EXT_en <= 0;
                    OUT_stat.progress <= 0;
                    OUT_EXT_bus <= 0;
                end
            end
            
            
            // Wait until external memory is ready to send data
            1: begin
                if (waitCycles == 0) begin
                    state <= 3;
                    OUT_EXT_oen <= 0;
                end
                waitCycles <= waitCycles - 1;
            end
            
            // Write to External
            2: begin
                if (cnt < len) sramAddr <= sramAddr + 1;
                else OUT_CACHE_used[cacheID] <= 0;
                
                cnt <= cnt + 1;
                
                if (cnt == len + 3) begin
                    OUT_EXT_en <= 0;
                    state <= 0;
                    OUT_stat.busy <= 0;
                end
                else if (cnt > 2) begin
                    OUT_EXT_bus <= outDataCacheIF;
                end
            end
            
            // Read from External
            3: begin
                cnt <= cnt + 1;
                if (cnt < len) begin
                    sramAddr <= sramAddr + 1;
                    OUT_stat.progress <= OUT_stat.progress + 1;
                end
                else begin
                    OUT_stat.busy <= 0;
                    OUT_stat.progress <= 0;
                    state <= 0;
                    OUT_EXT_en <= 0;
                end
            end

        endcase
    
    end

end

endmodule
