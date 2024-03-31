module i2s_clk
	#(
        parameter   MCLK_LRCK_RATIO = 64
    )
    (
		input logic clk_12_288,
		input logic reset_n,
		output logic mclk,
		output logic sclk,
		output logic lrclk,
		output logic rd_en
    );

	logic [$clog2(MCLK_LRCK_RATIO)-1:0] clk_divider;

	always_ff @(posedge clk_12_288, negedge reset_n) begin
		if (~reset_n)
            clk_divider <= 0;
        else
            clk_divider <= clk_divider + 1;
	end

	// The signals can be otained from the clk_divider:
    // clk_divider[0] // 6.144 Mhz => sclk
    // clk_divider[1] // 3.072 Mhz
    // clk_divider[2] // 1.536 MHz
    // clk_divider[3] // 768 KHz
    // clk_divider[4] // 384 KHz
    // clk_divider[5] // 192 KHz => lrclk
	assign mclk = clk_12_288;
	assign sclk = clk_divider[0];
	assign lrclk = clk_divider[5];

	// Data should be loaded one cycle after lrclk falls.
	assign rd_en = clk_divider == 1;
endmodule
