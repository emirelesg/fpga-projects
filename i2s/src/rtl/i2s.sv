/*
 * i2s
 *
 * Implements an i2s transmitter for the CS5343 chip and crosses samples from the
 * clk domain to the clk_i2s domain.
 *
 * mclk: 24.576 MHz = 48 kHz * 512
 * sclk: 1.4112 MHz = 48 kHz * 32
 *
 * The default ratios are for a 48 kHz sampling rate.
 * See section 4.1.1 for other options
 * https://statics.cirrus.com/pubs/proDatasheet/CS5343-44_F5.pdf
 */

module i2s
    #(
        parameter   MCLK_LRCK_RATIO = 512,
                    DATA_BIT = 16           // The number of bits to transmit via i2s.
    )
    (
        input logic clk,                    // 100 MHz
        input logic clk_i2s,                // 24.576 MHz
        input logic reset_n,
        input logic [DATA_BIT-1:0] audio_l,
        input logic [DATA_BIT-1:0] audio_r,
        output logic tx_mclk,
        output logic tx_sclk,
        output logic tx_lrclk,
        output logic tx_sd
    );
    
    logic [$clog2(MCLK_LRCK_RATIO)-1:0] clk_divider;
    logic lrclk, lrclk_2x_negedge;
    logic sclk, sclk_negedge;
    logic [DATA_BIT*2-1:0] audio_lr;
    logic reset_n_i2s;
    
    // Cross the the sample from the clk to clk_i2s domain.
    
    xpm_cdc_async_rst #(
       .DEST_SYNC_FF(2),        // range: 2-10
       .INIT_SYNC_FF(0),        // 0=disable simulation init values, 1=enable simulation init values
       .RST_ACTIVE_HIGH(0)      // 0=active low reset, 1=active high reset
    ) xpm_cdc_async_rst_inst (
       .dest_arst(reset_n_i2s),
       .dest_clk(clk_i2s),
       .src_arst(reset_n)
    );
    
    xpm_cdc_gray #(
       .DEST_SYNC_FF(2),        // range: 2-10
       .INIT_SYNC_FF(0),
       .REG_OUTPUT(0),
       .SIM_ASSERT_CHK(0),
       .SIM_LOSSLESS_GRAY_CHK(0),
       .WIDTH(DATA_BIT*2)
    ) xpm_cdc_gray_inst (
       .dest_out_bin(audio_lr),
       .dest_clk(lrclk_2x_negedge),
       .src_clk(clk),
       .src_in_bin({ audio_l, audio_r })
    );

    // Generate lrclk and sclk.

    // The signals can be otained from the clk_divider: 
    // clk_divider[0] // 12.288 MHz
    // clk_divider[1] // 6.144 Mhz
    // clk_divider[2] // 3.072 Mhz
    // clk_divider[3] // 1.536 MHz - sclk = 2 * 16 * 48000
    // clk_divider[4] // 768 KHz
    // clk_divider[5] // 384 KHz
    // clk_divider[6] // 192 KHz
    // clk_divider[7] // 96 KHz - lrclk_2
    // clk_divider[8] // 48 KHz - lrclk = 2 * 48000
    always_ff @(posedge clk_i2s, negedge reset_n_i2s) begin
        if (~reset_n_i2s)
            clk_divider = 0;
        else
            clk_divider <= clk_divider + 1;
    end

    assign sclk = clk_divider[3];
    assign sclk_negedge = &clk_divider[3:0];
    assign lrclk = clk_divider[8];
    assign lrclk_2x_negedge = &clk_divider[7:0]; // Use to move a sample from the clk to clk_i2s domain.
                                                 // The xpm_cdc_gray uses two ff, therefore it needs to clk cycles
                                                 // to cross the sample.
                                                 // Samples should also be loaded on the negedge of lrclk.

    // Generate sd by latching the next bit on the negedge of sclk.

    logic sd_reg, sd_next;

    always_ff @(posedge clk_i2s, negedge reset_n_i2s) begin
        if (~reset_n_i2s)
            sd_reg <= 1'b0;
        else
            sd_reg <= sd_next;
    end

    always_comb begin
        if (sclk_negedge)
            sd_next = audio_lr[5'd31 - clk_divider[8:4]];
        else
            sd_next = sd_reg;
    end

    assign tx_mclk = reset_n_i2s & clk_i2s; // Disable all clocks during reset.
    assign tx_sclk = reset_n_i2s & sclk;
    assign tx_lrclk = reset_n_i2s & lrclk;
    assign tx_sd = sd_reg;
endmodule
