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
    
    /* ~~ Create ddfs unit ~~ */
    
    logic [29:0] fccw, focw;
    logic [29:0] pha;
    logic [15:0] env;
    logic [15:0] pcm_out;
    
    initial begin
        // 38447 = 440 Hz
        fccw = 38447; // (2 ^ PHASE_WIDTH * freq / 12_288_000)
        focw = 0;
        pha = 0;
        // 1.0
        env = 16'h4000;
    end 
    
    ddfs ddfs_unit(
        .clk(clk_i2s),
        .reset_n(reset_n),
        .fccw(fccw),
        .focw(focw),
        .pha(pha),
        .env(env),
        // Outputs
        .pcm_out(pcm_out)
    );
    
    /* ~~ Create i2s unit ~~ */
    
    // logic [15:0] tx_data = 16'b0101010101010101;
    // logic [15:0] tx_data = 16'b1010101010101010;

    i2s i2s_unit(
        .clk_i2s(clk_i2s),
        .reset_n(reset_n),
        .tx_data(pcm_out),
        // Outputs
        .tx_mclk(tx_mclk),
        .tx_sclk(tx_sclk),
        .tx_lrclk(tx_lrclk),
        .tx_sd(tx_sd)
    );
endmodule
