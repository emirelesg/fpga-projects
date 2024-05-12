`include "i2s_map.svh"
module i2s_clk
    (
		input	logic							i_clk_12_288,
		input	logic							i_reset_n,
		output	logic							o_mclk,
		output	logic							o_sclk,
		output	logic							o_lrclk,
		output	logic							o_start,
		output	logic							o_finish,
		output	logic [$clog2(`DATA_BIT)-1:0]	o_count,
		output	logic							o_count_valid,
		output	logic							o_count_lrclk
    );

    localparam DVSR_WIDTH = $clog2(`MCLK_LRCLK_RATIO)-1;

    logic mclk, sclk, lrclk;
	logic [DVSR_WIDTH:0] clk_divider;

	always_ff @(posedge i_clk_12_288, negedge i_reset_n) begin
		if (~i_reset_n)
            clk_divider <= 0;
        else
            clk_divider <= clk_divider + 1;
	end

	// The signals can be otained from the clk_divider:
    // clk_divider[0] // 6.144  Mhz => o_sclk
    // clk_divider[1] // 3.072  Mhz
    // clk_divider[2] // 1.536  MHz
    // clk_divider[3] // 768    KHz
    // clk_divider[4] // 384    KHz
    // clk_divider[5] // 192    KHz    (1/64, SCLK = 32)
    // clk_divider[6] // 96     KHz    (1/128, SCLK = 64) => o_lrclk
    // clk_divider[7] // 48     KHz    (1/256)
	assign mclk = i_clk_12_288;
	assign sclk = clk_divider[0];
	assign lrclk = clk_divider[DVSR_WIDTH];

	// Count which bit is beign read or sent.

	logic [$clog2(`SCLK_LRCLK_RATIO)-1:0] s_reg;
	logic s_start, s_finish;
	logic [$clog2(`DATA_BIT)-1:0] b_reg;
	logic b_valid, b_lrclk;

	always_ff @(posedge i_clk_12_288, negedge i_reset_n) begin
		if (~i_reset_n) begin
            s_reg <= 0;
            s_start <= 1'b0;
            s_finish <= 1'b0;
        end
        else begin
            s_reg <= sclk ? s_reg - 1 : s_reg;                              // Count from SCLK_LRCLK_RATIO to 0 and wrap around.
            s_start <= s_start == 1'b0 && s_reg == `SCLK_LRCLK_RATIO - 1;   // Tick when the frame starts.
            s_finish <= s_finish == 1'b0 && s_reg == 0;                     // Tick when the frame finishes.
        end
	end

	// Do the current bits belong to the left or the right channel?
	// Since s_reg counts backwards, 1 = left and 0 = right. This is the opposite of lrclk.
	assign b_lrclk = ~s_reg[$clog2(`SCLK_LRCLK_RATIO)-1];

    // When SCLK_LRCLK_RATIO > DATA_BIT, not all bits are part of the payload.
    assign b_valid = s_reg[$clog2(`DATA_BIT)];

	assign b_reg = b_valid ? s_reg[$clog2(`DATA_BIT)-1:0] : 0;

	assign o_mclk = mclk;
    assign o_sclk = sclk;
    assign o_lrclk = lrclk;
    assign o_start = s_start;
    assign o_finish = s_finish;
    assign o_count = b_reg;
    assign o_count_valid = b_valid;
    assign o_count_lrclk = b_lrclk;
endmodule
