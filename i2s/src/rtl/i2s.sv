`include "i2s_map.svh"
module i2s
    (
		input	logic					i_clk_12_288,
		input	logic					i_reset_n,
		input	logic [`DATA_BIT-1:0]	i_audio_l,
        input	logic [`DATA_BIT-1:0]	i_audio_r,
        output	logic [`DATA_BIT-1:0]	o_audio_l,
        output	logic [`DATA_BIT-1:0]	o_audio_r,
		output	logic					o_audio_valid,
		output	logic					o_mclk,
        output	logic					o_sclk,
        output	logic					o_lrclk,
        output	logic					o_tx_sd,
        input   logic                   i_rx_sd
    );

    logic [$clog2(`DATA_BIT)-1:0] count;
    logic finish, count_valid, count_lrclk;
    logic mclk, sclk, lrclk;

	i2s_clk i2s_clk_unit (
		.i_clk_12_288(i_clk_12_288),
		.i_reset_n(i_reset_n),
		// Outputs
		.o_mclk(mclk),
		.o_sclk(sclk),
		.o_lrclk(lrclk),
		.o_start(o_audio_valid),
		.o_finish(finish), // Singal for the rx and tx modules to register data.
		.o_count(count),
		.o_count_valid(count_valid),
		.o_count_lrclk(count_lrclk)
	);

	i2s_tx i2s_tx_unit (
		.i_clk_12_288(i_clk_12_288),
		.i_reset_n(i_reset_n),
		.i_finish(finish),
		.i_audio_l(i_audio_l),
		.i_audio_r(i_audio_r),
		.i_count(count),
		.i_count_valid(count_valid),
		.i_count_lrclk(count_lrclk),
		// Outputs
		.o_sd(o_tx_sd)
	);

	i2s_rx i2s_rx_unit (
		.i_clk_12_288(i_clk_12_288),
		.i_reset_n(i_reset_n),
		.i_finish(finish),
		.i_sclk(sclk),
		.i_sd(i_rx_sd),
		.i_count(count),
		.i_count_valid(count_valid),
		.i_count_lrclk(count_lrclk),
		// Outputs
		.o_audio_l(o_audio_l),
		.o_audio_r(o_audio_r)
	);

	assign o_mclk = mclk;
	assign o_sclk = sclk;
	assign o_lrclk = lrclk;
endmodule
