module i2s_clk
	#(
        parameter   MCLK_LRCK_RATIO = 128
    )
    (
		input	logic i_clk_12_288,
		input	logic i_reset_n,
		output	logic o_mclk,
		output	logic o_sclk,
		output	logic o_lrclk,
		output	logic o_data_ready
    );

    localparam DVSR_WIDTH = $clog2(MCLK_LRCK_RATIO)-1;

	logic [DVSR_WIDTH:0] clk_divider;

	always_ff @(posedge i_clk_12_288, negedge i_reset_n) begin
		if (~i_reset_n)
            clk_divider <= 0;
        else
            clk_divider <= clk_divider + 1;
	end

	// The signals can be otained from the clk_divider:
    // clk_divider[0] // 6.144 Mhz => o_sclk
    // clk_divider[1] // 3.072 Mhz
    // clk_divider[2] // 1.536 MHz
    // clk_divider[3] // 768 KHz
    // clk_divider[4] // 384 KHz
    // clk_divider[5] // 192 KHz (1/64, SCLK = 32)
    // clk_divider[6] // 96 KHz (1/128, SCLK = 64) => o_lrclk
    // clk_divider[7] // 48 KHz (1/256)
	assign o_mclk = i_clk_12_288;
	assign o_sclk = clk_divider[0];
	assign o_lrclk = clk_divider[DVSR_WIDTH];

	// Data should be loaded one cycle after lrclk falls.
	assign o_data_ready = clk_divider == 1;
endmodule
