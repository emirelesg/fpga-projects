module i2s
    (
        input logic clk_i2s,
        input logic reset_n,
        output logic tx_mclk,
        output logic tx_sclk,
        output logic tx_lrclk,
        output logic tx_data
    );
    
    // mclk = 12.288 MHz
    
    // sclk = 1.536 Mhz = 12.288 Mhz / 8
    // Count from 0 - 3 then flip the signal.
    
    localparam RATIO = 8;
    localparam SCLK_DVSR = RATIO / 2 - 1;
    
    logic sclk_reg, sclk_next;
    logic [$clog2(SCLK_DVSR):0] sclk_ctr_reg, sclk_ctr_next;
    
    always_ff @(posedge clk_i2s, negedge reset_n) begin
        if (~reset_n) begin
            sclk_reg <= 1'b0;
            sclk_ctr_reg <= 0;
        end
        else begin
            sclk_reg <= sclk_next;
            sclk_ctr_reg <= sclk_ctr_next;
        end
    end
    
    always_comb begin
        if (sclk_ctr_reg < SCLK_DVSR) begin
            sclk_next = sclk_reg;
            sclk_ctr_next = sclk_ctr_reg + 1;
        end
        else begin
            sclk_next = ~sclk_reg;
            sclk_ctr_next = 0;
        end
    end
    
    // lrclk = 96 khz = 1.536 Mhz / 16 bits
    // Make a counter from 0 - 31, flip sclk on > 15 and continue
    // counting until 31, then reset sclk.
    
    // lrclk = 44.8 kHz
    
    assign tx_mclk = clk_i2s;
    assign tx_sclk = sclk_reg;
    assign tx_lrclk = 1'b0;
    assign tx_data = 1'b0;
endmodule
