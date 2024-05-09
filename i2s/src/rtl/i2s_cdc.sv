module i2s_cdc
    #(
        parameter	DATA_BIT = 16
    )
    (
        input   logic                   i_clk,
        input   logic                   i_clk_12_288,
        input   logic                   i_reset_n,
        input   logic [DATA_BIT-1:0]    i_audio_l,
        input   logic [DATA_BIT-1:0]    i_audio_r,
        input   logic                   i_data_valid,
        output  logic                   o_data_ready,
        output  logic                   o_tx_mclk,
        output  logic                   o_tx_sclk,
        output  logic                   o_tx_lrclk,
        output  logic                   o_tx_sd
    );

    // xpm_fifo_async requires the reset signal to hold for at least 5 clk cycles.
    // The number of bits determines the clk cycles i_reset_n is extended.
    logic [4:0] c_reg;

    always_ff @(posedge i_clk, negedge i_reset_n) begin
        if (~i_reset_n)
            c_reg <= ~0;
        else
            c_reg <= c_reg << 1;
    end

    logic fifo_rst, fifo_wr_en, fifo_rd_en, fifo_wr_rst_busy, fifo_rd_rst_busy;
    logic [(2*DATA_BIT)-1:0] fifo_din, fifo_dout;

    logic i2s_reset_n, i2s_data_ready;
    logic [DATA_BIT-1:0] i2s_audio_l, i2s_audio_r;

    // Move i_audio_l and i_audio_r to the i2s domain.
    // i_clk -> i_clk_12_288
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
        .wr_clk(i_clk),
        .wr_en(fifo_wr_en),
        .din(fifo_din),
        .rd_clk(i_clk_12_288),
        .rd_en(fifo_rd_en),
        // Outputs
        .dout(fifo_dout),
        .rd_rst_busy(fifo_rd_rst_busy),
        .wr_rst_busy(fifo_wr_rst_busy)
    );

    // Move the i_reset_n signal to the i2s domain.
    // clk -> i_clk_12_288
    xpm_cdc_sync_rst xpm_sync_rst_unit(
        .src_rst(i_reset_n),
        .dest_clk(i_clk_12_288),
        // Outputs
        .dest_rst(i2s_reset_n)
    );

    // Move the i2s_data_ready to the clk domain.
    // i_clk_12_288 -> clk
    xpm_cdc_pulse #(
        .DEST_SYNC_FF(2)
    ) xpm_cdc_pulse_unit(
        .src_rst(~i2s_reset_n),
        .src_clk(i_clk_12_288),
        .dest_rst(~i_reset_n),
        .dest_clk(i_clk),
        .src_pulse(i2s_data_ready),
        // Outputs
        .dest_pulse(o_data_ready)
    );

    // i2s data is delayed by 1 sample.
    // Data is latched when rd_en rises. Since the fifo has a 1 clk delay on the dout,
    // it will be read in the next i2s cycle.
    i2s #(
	   .DATA_BIT(DATA_BIT)
	) i2s_unit(
		.i_clk_12_288(i_clk_12_288),
		.i_reset_n(i2s_reset_n),
		.i_audio_l(i2s_audio_l),
        .i_audio_r(i2s_audio_r),
		// Outputs
        .o_tx_mclk(o_tx_mclk),
        .o_tx_sclk(o_tx_sclk),
        .o_tx_lrclk(o_tx_lrclk),
        .o_tx_sd(o_tx_sd),
		.o_data_ready(i2s_data_ready)
	);

	assign fifo_rst = c_reg[4]; // Use the most significant bit as an extended reset signal.
    assign fifo_wr_en = i_data_valid;
    assign fifo_rd_en = i2s_data_ready;
    assign fifo_din = {i_audio_l, i_audio_r}; // Pack i_audio_l and i_audio_r.
	assign i2s_audio_l = fifo_dout[(2*DATA_BIT)-1:DATA_BIT]; // Unpack i_audio_l and i_audio_r.
    assign i2s_audio_r = fifo_dout[DATA_BIT-1:0];
endmodule
