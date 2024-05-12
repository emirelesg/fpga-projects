module i2s_rx
	#(
        parameter	DATA_BIT = 16
    )
	(
		input   logic                           i_clk_12_288,
		input   logic                           i_reset_n,
		input   logic                           i_finish,
        input   logic                           i_sclk,
		input   logic                           i_sd,
		input   logic [$clog2(DATA_BIT)-1:0]    i_count,
		input   logic                           i_count_valid,
		input   logic                           i_count_lrclk,
        output  logic [DATA_BIT-1:0]            o_audio_l,
        output  logic [DATA_BIT-1:0]            o_audio_r
	);

	logic [DATA_BIT-1:0]
	   audio_l_reg, audio_l_next,
	   audio_l_shift_reg, audio_l_shift_next,
	   audio_r_reg, audio_r_next,
	   audio_r_shift_reg, audio_r_shift_next;

    always_ff @(posedge i_clk_12_288, negedge i_reset_n) begin
        if (~i_reset_n) begin
            audio_l_reg <= 0;
            audio_l_shift_reg <= 0;
            audio_r_reg <= 0;
            audio_r_shift_reg <= 0;
        end
        else begin
			audio_l_reg <= audio_l_next;
			audio_l_shift_reg <= audio_l_shift_next;
            audio_r_reg <= audio_r_next;
            audio_r_shift_reg <= audio_r_shift_next;
	    end
    end

    always_comb begin
        audio_l_shift_next = audio_l_shift_reg;
        audio_r_shift_next = audio_r_shift_reg;

        if (i_sclk)
            if (i_count_valid)
                if (i_count_lrclk)
                    audio_r_shift_next[i_count] = i_sd;
                else
                    audio_l_shift_next[i_count] = i_sd;

        if (i_finish) begin
            audio_l_next = audio_l_shift_reg;
            audio_r_next = audio_r_shift_reg;
        end
        else begin
            audio_l_next = audio_l_reg;
            audio_r_next = audio_r_reg;
        end
    end

	assign o_audio_l = audio_l_reg;
	assign o_audio_r = audio_r_reg;
endmodule
