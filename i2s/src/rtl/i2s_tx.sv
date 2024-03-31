module i2s_tx
	#(
        parameter	DATA_BIT = 16
    )
	(
		input logic clk_12_288,
		input logic reset_n,
		input logic rd_en,
		input logic [DATA_BIT-1:0] audio_l,
        input logic [DATA_BIT-1:0] audio_r,
        input logic sclk,
		output logic sd
	);

    logic [$clog2(2*DATA_BIT)-1:0] s_reg, s_next; // Counter to select the data bit to shift out.
	logic [(2*DATA_BIT)-1:0] data_reg, data_next; // Stores the loaded data when ready is asserted.

    always_ff @(posedge clk_12_288, negedge reset_n) begin
        if (~reset_n) begin
            s_reg <= 0;
			data_reg <= 0;
		end
        else begin
            s_reg <= s_next;
			data_reg <= data_next;
		end
    end

    always_comb begin
        s_next = s_reg;
		data_next = data_reg;

		if (rd_en) begin
			data_next = {audio_l, audio_r};
			s_next = (2*DATA_BIT)-1;
	   end
	   else
           if (sclk)
               s_next = s_reg - 1;
    end

	assign sd = data_reg[s_reg];
endmodule
