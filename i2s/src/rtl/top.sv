module top
	(
		input   logic       i_clk,
        input   logic       i_reset_n,
        input   logic [3:0] i_btn,
        input   logic [3:0] i_sw,
        output  logic       o_tx_mclk,
        output  logic       o_tx_sclk,
        output  logic       o_tx_lrclk,
        output  logic       o_tx_sd
	);

	logic clk_12_288;

    design_1_wrapper design_1_wrapper_unit (
        .clk(i_clk),
        .reset_n(i_reset_n),
        // Outputs
        .clk_i2s(clk_12_288)
    );

	logic [15:0] pcm_out;
    logic [29:0] fccw, focw; // (2 ^ PHASE_WIDTH * freq / 96_000)
    logic [29:0] pha;
    logic [15:0] env;
    logic [2:0] wave_type;

    always_comb begin
        if (i_sw == 4'b0001)
            fccw = 447_392; // 40 Hz
        else
            if (i_sw == 4'b0010)
                fccw = 671_088; // 80 Hz
             else
                if (i_sw == 4'b0100)
                    fccw = 2_460_658; // 120 Hz
                else
                    fccw = 4_921_316; // 440 Hz
    end

    initial begin
        focw = 0;
        pha = 0;
        env = 16'h4000; // 1.0
        wave_type = 3'b001; // Sine
    end

    logic data_ready, data_valid;

    // Example to generate a sine wave:
    ddfs ddfs_unit(
        .clk(i_clk),
        .reset_n(i_reset_n),
        .en(data_ready),
        .fccw(fccw),
        .focw(focw),
        .pha(pha),
        .env(env),
        .wave_type(wave_type),
        // Outputs
        .pcm_out(pcm_out),
        .data_valid(data_valid)
    );

	i2s_cdc i2s_cdc_unit(
        .i_clk(i_clk),
		.i_clk_12_288(clk_12_288),
		.i_reset_n(i_reset_n),
		.i_audio_l(pcm_out),
        .i_audio_r(pcm_out),
        .i_data_valid(data_valid),
		// Outputs
		.o_data_ready(data_ready),
        .o_tx_mclk(o_tx_mclk),
        .o_tx_sclk(o_tx_sclk),
        .o_tx_lrclk(o_tx_lrclk),
        .o_tx_sd(o_tx_sd)
	);
endmodule
