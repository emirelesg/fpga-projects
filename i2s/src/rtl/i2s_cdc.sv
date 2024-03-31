module i2s_cdc
    #(
        parameter	DATA_BIT = 16
    )
    (
        input logic clk,
        input logic clk_12_288,
        input logic reset_n,
        input logic [DATA_BIT-1:0] audio_l,
        input logic [DATA_BIT-1:0] audio_r,
        input logic wr_en,
        output logic wr_ready,
        output logic tx_mclk,
        output logic tx_sclk,
        output logic tx_lrclk,
        output logic tx_sd
    );

    // xpm_fifo_async requires the reset signal to hold for at least 5 clk cycles.
    // The number of bits determines the clk cycles reset_n is extended.
    logic [4:0] c_reg;

    always_ff @(posedge clk, negedge reset_n) begin
        if (~reset_n)
            c_reg <= ~0;
        else
            c_reg <= c_reg << 1;
    end

    logic fifo_rst, fifo_wr_en, fifo_rd_en, fifo_wr_rst_busy, fifo_rd_rst_busy;
    logic [(2*DATA_BIT)-1:0] fifo_din, fifo_dout;

    logic i2s_reset_n, i2s_rd_en;
    logic [DATA_BIT-1:0] i2s_audio_l, i2s_audio_r;

    // Move audio_l and audio_r to the i2s domain.
    // clk -> clk_12_288
    xpm_fifo_async #(
        .CDC_SYNC_STAGES(2),
        .FIFO_MEMORY_TYPE("block"),
        .FIFO_WRITE_DEPTH(16),
        .WRITE_DATA_WIDTH(2*DATA_BIT),
        .READ_DATA_WIDTH(2*DATA_BIT),
        .READ_MODE("fwft"),
        .ECC_MODE("no_ecc")
    ) xpm_fifo_async_unit (
        .rst(fifo_rst),
        .wr_clk(clk),
        .wr_en(fifo_wr_en),
        .din(fifo_din), // Pack audio_l and audio_r.
        .rd_clk(clk_12_288),
        .rd_en(fifo_rd_en),
        // Outputs
        .dout(fifo_dout),
        .rd_rst_busy(fifo_rd_rst_busy),
        .wr_rst_busy(fifo_wr_rst_busy)
    );

    // Move the reset_n signal to the i2s domain.
    // clk -> clk_12_288
    xpm_cdc_sync_rst xpm_sync_rst_unit(
        .src_rst(reset_n),
        .dest_clk(clk_12_288),
        // Outputs
        .dest_rst(i2s_reset_n)
    );

    // Move the i2s_rd_en to the clk domain.
    // clk_12_288 -> clk
    xpm_cdc_pulse #(
        .DEST_SYNC_FF(2)
    ) xpm_cdc_pulse_unit(
        .src_rst(~i2s_reset_n),
        .src_clk(clk_12_288),
        .dest_rst(~reset_n),
        .dest_clk(clk),
        .src_pulse(i2s_rd_en),
        // Outputs
        .dest_pulse(wr_ready)
    );

    // i2s data is delayed by 1 sample.
    // Data is latched when rd_en rises. Since the fifo has a 1 clk delay on the dout,
    // it will be read in the next i2s cycle.
    i2s #(
	   .DATA_BIT(DATA_BIT)
	) i2s_unit(
		.clk_12_288(clk_12_288),
		.reset_n(i2s_reset_n),
		.rd_en(i2s_rd_en),
		.audio_l(i2s_audio_l),
        .audio_r(i2s_audio_r),
		// Outputs
        .tx_mclk(tx_mclk),
        .tx_sclk(tx_sclk),
        .tx_lrclk(tx_lrclk),
        .tx_sd(tx_sd)
	);

	assign fifo_rst = c_reg[4]; // Use the most significant bit as an extended reset signal.
    assign fifo_wr_en = wr_en;
    assign fifo_rd_en = i2s_rd_en;
    assign fifo_din = {audio_l, audio_r}; // Pack audio_l and audio_r.
	assign i2s_audio_l = fifo_dout[(2*DATA_BIT)-1:DATA_BIT]; // Unpack audio_l and audio_r.
    assign i2s_audio_r = fifo_dout[DATA_BIT-1:0];
endmodule
