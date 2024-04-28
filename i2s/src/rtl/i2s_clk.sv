module i2s_clk
	#(
        parameter   MCLK_LRCK_RATIO = 128
    )
    (
		input logic clk_12_288,
		input logic reset_n,
		output logic mclk,
		output logic sclk,
		output logic lrclk,
		output logic rd_en
    );
    
    localparam DVSR_WIDTH = $clog2(MCLK_LRCK_RATIO)-1;

	logic [DVSR_WIDTH:0] clk_divider;

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
    // clk_divider[5] // 192 KHz (1/64)
    // clk_divider[6] // 96 KHz (1/128) => lrclk
    // clk_divider[7] // 48 KHz (1/256)
	assign mclk = clk_12_288;
	assign sclk = clk_divider[0];
	assign lrclk = clk_divider[DVSR_WIDTH];

	// Data should be loaded one cycle after lrclk falls.
	assign rd_en = clk_divider == 1;
endmodule
