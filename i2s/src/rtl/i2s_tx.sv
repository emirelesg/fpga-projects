`include "i2s_map.svh"
module i2s_tx
	(
		input   logic                           i_clk_12_288,
		input   logic                           i_reset_n,
		input   logic                           i_finish,
		input   logic [`DATA_BIT-1:0]           i_audio_l,
        input   logic [`DATA_BIT-1:0]           i_audio_r,
        input   logic                           i_sclk,
        input   logic [$clog2(`DATA_BIT)-1:0]   i_count,
		input   logic                           i_count_valid,
		input   logic                           i_count_lrclk,
		output  logic                           o_sd
	);

	logic [`DATA_BIT-1:0]
	   audio_l_reg, audio_l_next,
	   audio_r_reg, audio_r_next;
    logic sd;

    always_ff @(posedge i_clk_12_288, negedge i_reset_n) begin
        if (~i_reset_n) begin
            audio_l_reg <= 0;
            audio_r_reg <= 0;
        end
        else begin
			audio_l_reg <= audio_l_next;
            audio_r_reg <= audio_r_next;
	    end
    end

    always_comb begin
        if (i_count_valid)
            if (i_count_lrclk)
                sd = audio_r_reg[i_count];
            else
                sd = audio_l_reg[i_count];
        else
            sd = 1'b0; // Ensure no data is transmitted unless the count is valid.

        if (i_finish) begin
            audio_l_next = i_audio_l;
            audio_r_next = i_audio_r;
        end
        else begin
            audio_l_next = audio_l_reg;
            audio_r_next = audio_r_reg;
        end
    end

	assign o_sd = sd;
endmodule
