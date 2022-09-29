module MemRTL
#(
    parameter WORD_SIZE=32,
    parameter NUM_WORDS=65536
)
(
    input wire clk,
    
    input wire IN_nce,
    input wire IN_nwe,
    
    input wire[$clog2(NUM_WORDS)-1:0] IN_addr,
    input wire[WORD_SIZE-1:0] IN_data,
    input wire[(WORD_SIZE/8)-1:0] IN_wm,
    
    output reg[WORD_SIZE-1:0] OUT_data
);
integer i;

reg[WORD_SIZE-1:0] mem[NUM_WORDS-1:0] /*verilator public*/;

reg ce_reg;
reg we_reg;
reg[$clog2(NUM_WORDS)-1:0] addr_reg;
reg[WORD_SIZE-1:0] data_reg;
reg[(WORD_SIZE/8)-1:0] wm_reg;

always@(posedge clk) begin
    
    ce_reg <= IN_nce;
    we_reg <= IN_nwe;
    addr_reg <= IN_addr;
    data_reg <= IN_data;
    wm_reg <= IN_wm;
    
    if (!ce_reg) begin
        if (!we_reg) begin
            for (i = 0; i < WORD_SIZE/8; i=i+1) begin
                if (wm_reg[i])
                    mem[addr_reg][(8*i)+:8] <= data_reg[(8*i)+:8];
            end
            OUT_data <= 'bx;
        end
        else begin
            OUT_data <= mem[addr_reg];
        end
    end

end

endmodule
