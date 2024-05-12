module top
	(
		input   logic       i_clk,
        input   logic       i_reset_n,
        input   logic [3:0] i_btn,
        input   logic [3:0] i_sw,
        output  logic       o_tx_mclk,
        output  logic       o_tx_sclk,
        output  logic       o_tx_lrclk,
        output  logic       o_tx_sd,
        output  logic       o_rx_mclk,
        output  logic       o_rx_sclk,
        output  logic       o_rx_lrclk,
        input  logic        i_rx_sd
	);

	logic clk_12_288;

    design_1_wrapper design_1_wrapper_unit (
        .clk(i_clk),
        .reset_n(i_reset_n),
        // Outputs
        .clk_i2s(clk_12_288)
    );
    
    logic audio_valid_in, audio_valid_out;
    logic [15:0] audio_l_in, audio_r_in;
    logic [15:0] audio_l_out, audio_r_out;
    
    logic ddfs_data_valid;
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
                fccw = 894_784; // 80 Hz
             else
                if (i_sw == 4'b0100)
                    fccw = 1_789_569; // 160 Hz
                else
                    fccw = 3_579_139; // 320 Hz
    end

    initial begin
        focw = 0;
        pha = 0;
        env = 16'h4000; // 1.0
        wave_type = 3'b001; // Sine
    end

    // Example to generate a sine wave:
    ddfs ddfs_unit(
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),
        .i_en(audio_valid_out),
        .i_fccw(fccw),
        .i_focw(focw),
        .i_pha(pha),
        .i_env(env),
        .i_wave_type(wave_type),
        // Outputs
        .o_pcm_out(pcm_out),
        .o_data_valid(ddfs_data_valid)
    );

    logic mclk, sclk, lrclk;

	i2s_cdc i2s_cdc_unit(
        .i_clk(i_clk),
		.i_clk_12_288(clk_12_288),
		.i_reset_n(i_reset_n),
		.i_audio_l(audio_l_in),
        .i_audio_r(audio_r_in),
        .i_audio_valid(audio_valid_in),
		// Outputs
		.o_audio_l(audio_l_out),
		.o_audio_r(audio_r_out),
		.o_audio_valid(audio_valid_out),
        .o_mclk(mclk),
        .o_sclk(sclk),
        .o_lrclk(lrclk),
        .o_tx_sd(o_tx_sd),
        .i_rx_sd(i_rx_sd)
	);

    assign audio_l_in = audio_l_out;
    assign audio_r_in = audio_r_out;
    assign audio_valid_in = audio_valid_out;

	assign o_tx_mclk = mclk;
    assign o_rx_mclk = mclk;
	assign o_tx_sclk = sclk;
	assign o_rx_sclk = sclk;
	assign o_tx_lrclk = lrclk;
	assign o_rx_lrclk = lrclk;
endmodule
