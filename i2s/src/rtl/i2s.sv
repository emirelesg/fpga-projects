module i2s
	#(
        parameter	DATA_BIT = 16
    )
    (
		input logic clk_12_288,
		input logic reset_n,
		input logic [DATA_BIT-1:0] audio_l,
        input logic [DATA_BIT-1:0] audio_r,
		output logic tx_mclk,
        output logic tx_sclk,
        output logic tx_lrclk,
        output logic tx_sd,
        output logic rd_en
    );

    logic sclk;
    logic _rd_en;

	i2s_clk i2s_clk_unit (
		.clk_12_288(clk_12_288),
		.reset_n(reset_n),
		// Outputs
		.rd_en(_rd_en),
		.mclk(tx_mclk),
		.sclk(sclk),
		.lrclk(tx_lrclk)
	);

	i2s_tx #(
	   .DATA_BIT(DATA_BIT)
	) i2s_tx_unit (
		.clk_12_288(clk_12_288),
		.reset_n(reset_n),
		.rd_en(_rd_en),
		.audio_l(audio_l),
		.audio_r(audio_r),
		.sclk(sclk),
		// Outputs
		.sd(tx_sd)
	);

	assign rd_en = _rd_en;
	assign tx_sclk = sclk;
endmodule
