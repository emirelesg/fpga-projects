module i2s
    (
        input logic clk_i2s, // 12.288 Mhz
        input logic reset_n,
        output logic tx_mclk,
        output logic tx_sclk,
        output logic tx_lrclk,
        output logic tx_data
    );
    // The mclk/lrclk ratio must be 256 times.
    // See section 4.1.1: https://statics.cirrus.com/pubs/proDatasheet/CS5343-44_F5.pdf
    localparam RATIO = 256;
        
    logic sclk, lrclk;
    logic [$clog2(RATIO - 1):0] ctr_reg, ctr_next;
    
    always_ff @(posedge clk_i2s, negedge reset_n) begin
        if (~reset_n) begin
            ctr_reg <= 0;
        end
        else begin
            ctr_reg <= ctr_next;
        end
    end
    
    always_comb begin
        ctr_next = ctr_reg + 1;
        
        // sclk: 1.536 Mhz = 12.288 Mhz / 8
        sclk = ctr_reg[2]; // 0 - 3
        
        // lrclk: 48 khz = 1.536 Mhz / 16 bits / 2 channels
        lrclk = ctr_reg[7]; // 0 - 255
    end
     
    assign tx_mclk = clk_i2s;
    assign tx_sclk = sclk;
    assign tx_lrclk = lrclk;
    assign tx_data = 1'b0;
endmodule
