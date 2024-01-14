module top
    (
        input logic clk,
        input logic reset_n,
        output logic tx_mclk,
        output logic tx_sclk,
        output logic tx_lrclk,
        output logic tx_data
    );
    
    /* ~~ Create design_1_wrapper unit ~~ */
    
    // clk_i2s: 12.288 MHz = 44.8 kHz * 256
    // MCLK/LRCK ration must be 256 times.
    // See section 4.1.1: https://statics.cirrus.com/pubs/proDatasheet/CS5343-44_F5.pdf
    
    logic clk_i2s;
    
    design_1_wrapper design_1_wrapper_unit (
        .clk(clk),
        .reset_n(reset_n),
        // Outputs
        .clk_i2s(clk_i2s)
    );
    
    /* ~~ Create i2s unit ~~ */
    
    i2s i2s_unit(
        .clk_i2s(clk_i2s),
        .reset_n(reset_n),
        // Outputs
        .tx_mclk(tx_mclk),
        .tx_sclk(tx_sclk),
        .tx_lrclk(tx_lrclk),
        .tx_data(tx_data)
    );
endmodule
