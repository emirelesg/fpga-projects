module top
    (
        input logic clk,
        input logic reset_n,
        output logic tx_mclk,
        output logic tx_sclk,
        output logic tx_lrclk,
        output logic tx_sd
    );
    
    /* ~~ Create design_1_wrapper unit ~~ */
    
    logic clk_i2s;
    
    design_1_wrapper design_1_wrapper_unit (
        .clk(clk),
        .reset_n(reset_n),
        // Outputs
        .clk_i2s(clk_i2s)
    );
    
    /* ~~ Create i2s unit ~~ */
    
    // logic [15:0] tx_data = 16'b0101010101010101;
    logic [15:0] tx_data = 16'b1010101010101010;

    i2s i2s_unit(
        .clk_i2s(clk_i2s),
        .reset_n(reset_n),
        .tx_data(tx_data),
        // Outputs
        .tx_mclk(tx_mclk),
        .tx_sclk(tx_sclk),
        .tx_lrclk(tx_lrclk),
        .tx_sd(tx_sd)
    );
endmodule
