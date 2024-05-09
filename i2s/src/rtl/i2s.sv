module i2s
	#(
        parameter	DATA_BIT = 16
    )
    (
		input	logic					i_clk_12_288,
		input	logic					i_reset_n,
		input	logic [DATA_BIT-1:0]	i_audio_l,
        input	logic [DATA_BIT-1:0]	i_audio_r,
		output	logic					o_tx_mclk,
        output	logic					o_tx_sclk,
        output	logic					o_tx_lrclk,
        output	logic					o_tx_sd,
        output	logic					o_data_ready
    );

    logic sclk;
    logic data_ready;

	i2s_clk i2s_clk_unit (
		.i_clk_12_288(i_clk_12_288),
		.i_reset_n(i_reset_n),
		// Outputs
		.o_data_ready(data_ready),
		.o_mclk(o_tx_mclk),
		.o_sclk(sclk),
		.o_lrclk(o_tx_lrclk)
	);

	i2s_tx #(
	   .DATA_BIT(DATA_BIT)
	) i2s_tx_unit (
		.i_clk_12_288(i_clk_12_288),
		.i_reset_n(i_reset_n),
		.i_data_valid(data_ready),
		.i_audio_l(i_audio_l),
		.i_audio_r(i_audio_r),
		.i_sclk(sclk),
		// Outputs
		.o_sd(o_tx_sd)
	);

	assign o_data_ready = data_ready;
	assign o_tx_sclk = sclk;
endmodule
