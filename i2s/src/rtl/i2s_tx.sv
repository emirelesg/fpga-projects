module i2s_tx
	#(
        parameter	DATA_BIT	= 16,
					SCLK_COUNT	= 64 	// Depends on the MCLK_LRCLK_RATIO.
    )
	(
		input	logic 					i_clk_12_288,
		input	logic 					i_reset_n,
		input	logic 					i_data_valid,
		input	logic [DATA_BIT-1:0] 	i_audio_l,
        input	logic [DATA_BIT-1:0] 	i_audio_r,
        input	logic 					i_sclk,
		output	logic 					o_sd
	);

    logic [$clog2(SCLK_COUNT)-1:0] s_reg, s_next;  // Counter to select the data bit to shift out.
	logic [SCLK_COUNT-1:0] data_reg, data_next;    // Stores the loaded data when ready is asserted.

    always_ff @(posedge i_clk_12_288, negedge i_reset_n) begin
        if (~i_reset_n) begin
            s_reg <= 0;
            data_reg <= 0;
		end
        else begin
            s_reg <= s_next;
			data_reg <= data_next;
		end
    end

    always_comb begin
		// Default values:
        s_next = s_reg;
        data_next = data_reg;

        if (i_data_valid) begin
            // For SCLK_COUNT = 32, remove the 0 padding.
            data_next = {i_audio_l, 16'h0000, i_audio_r, 16'h0000};
            s_next = SCLK_COUNT - 1; // Count in reverse so that MSB is shifted out first.
        end
        else if (i_sclk)
            s_next = s_reg - 1;
    end

	assign o_sd = data_reg[s_reg];
endmodule
