module top
	(
		input logic clk,
        input logic reset_n,
        input logic [3:0] btn,
        input logic [3:0] sw,
        output logic tx_mclk,
        output logic tx_sclk,
        output logic tx_lrclk,
        output logic tx_sd
	);

	logic clk_12_288;

    design_1_wrapper design_1_wrapper_unit (
        .clk(clk),
        .reset_n(reset_n),
        // Outputs
        .clk_i2s(clk_12_288)
    );

	logic [15:0] pcm_out;
    logic [29:0] fccw, focw; // (2 ^ PHASE_WIDTH * freq / 192_000)
    logic [29:0] pha;
    logic [15:0] env;

    always_comb begin
        if (sw == 4'b0001)
            fccw = 223_696; // 40 Hz
        else
            if (sw == 4'b0010)
                fccw = 447_392; // 80 Hz
             else
                if (sw == 4'b0100)
                    fccw = 671_088; // 120 Hz
                else
                    fccw = 2_460_658; // 440 Hz
    end

    initial begin
        focw = 0;
        pha = 0;
        env = 16'h4000; // 1.0
    end

    logic wr_ready, wr_en;

    // Example to generate a sine wave:
    ddfs ddfs_unit(
        .clk(clk),
        .reset_n(reset_n),
        .en(wr_ready),
        .fccw(fccw),
        .focw(focw),
        .pha(pha),
        .env(env),
        // Outputs
        .pcm_out(pcm_out),
        .data_valid(wr_en)
    );

	i2s_cdc i2s_cdc_unit(
        .clk(clk),
		.clk_12_288(clk_12_288),
		.reset_n(reset_n),
		.audio_l(pcm_out),
        .audio_r(pcm_out),
        .wr_en(wr_en),
		// Outputs
		.wr_ready(wr_ready),
        .tx_mclk(tx_mclk),
        .tx_sclk(tx_sclk),
        .tx_lrclk(tx_lrclk),
        .tx_sd(tx_sd)
	);
endmodule
