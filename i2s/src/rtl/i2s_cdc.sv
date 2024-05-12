`include "i2s_map.svh"
module i2s_cdc
    (
        input   logic                   i_clk,
        input   logic                   i_clk_12_288,
        input   logic                   i_reset_n,
        input   logic [`DATA_BIT-1:0]   i_audio_l,
        input   logic [`DATA_BIT-1:0]   i_audio_r,
        input   logic                   i_audio_valid,
        input   logic                   i_rx_sd,
        output  logic [`DATA_BIT-1:0]   o_audio_l,
        output  logic [`DATA_BIT-1:0]   o_audio_r,
        output  logic                   o_audio_valid,
        output  logic                   o_mclk,
        output  logic                   o_sclk,
        output  logic                   o_lrclk,
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

    logic fifo_in_rst, fifo_in_wr_en, fifo_in_rd_en;
    logic [(2*`DATA_BIT)-1:0]
        fifo_in_din, fifo_in_dout,
        fifo_out_din, fifo_out_dout;

    logic i2s_reset_n, i2s_audio_valid_out;
    logic [`DATA_BIT-1:0]
        i2s_audio_l_in, i2s_audio_r_in,
        i2s_audio_l_out, i2s_audio_r_out;

    // Move i_audio_l and i_audio_r to the i2s domain.
    xpm_fifo_async #(
        .CDC_SYNC_STAGES(2),
        .FIFO_MEMORY_TYPE("block"),
        .FIFO_WRITE_DEPTH(16),
        .WRITE_DATA_WIDTH(2*`DATA_BIT),
        .READ_DATA_WIDTH(2*`DATA_BIT),
        .READ_MODE("fwft"),
        .ECC_MODE("no_ecc")
    ) xpm_fifo_async_unit (
        .rst(fifo_in_rst),
        .wr_clk(i_clk),
        .wr_en(fifo_in_wr_en),
        .din(fifo_in_din),
        .rd_clk(i_clk_12_288),
        .rd_en(fifo_in_rd_en),
        // Outputs
        .dout(fifo_in_dout)
    );

    // Move the i_reset_n signal to the i2s domain.
    xpm_cdc_sync_rst xpm_sync_rst_unit(
        .src_rst(i_reset_n),
        .dest_clk(i_clk_12_288),
        // Outputs
        .dest_rst(i2s_reset_n)
    );

    // Move the i2s_audio_valid_out to the clk domain.
    xpm_cdc_pulse #(
        .DEST_SYNC_FF(2)
    ) xpm_cdc_pulse_unit_2(
        .src_rst(~i2s_reset_n),
        .src_clk(i_clk_12_288),
        .dest_rst(~i_reset_n),
        .dest_clk(i_clk),
        .src_pulse(i2s_audio_valid_out),
        // Outputs
        .dest_pulse(o_audio_valid)
    );

    // Move the i2s_audio_l_out and i2s_audio_r_out to the clk domain.
    xpm_cdc_array_single #(
        .DEST_SYNC_FF(2),
        .WIDTH(2*`DATA_BIT)
    ) xpm_cdc_array_single_unit (
        .src_clk(i_clk_12_288),
        .src_in(fifo_out_din),
        .dest_clk(i_clk),
        // Outputs
        .dest_out(fifo_out_dout)
    );

    // i2s data is delayed by 1 sample.
    // Data is latched when rd_en rises. Since the fifo has a 1 clk delay on the dout,
    // it will be read in the next i2s cycle.
    i2s i2s_unit(
		.i_clk_12_288(i_clk_12_288),
		.i_reset_n(i2s_reset_n),
		.i_audio_l(i2s_audio_l_in),
        .i_audio_r(i2s_audio_r_in),
        .i_rx_sd(i_rx_sd),
		// Outputs
		.o_audio_l(i2s_audio_l_out),
        .o_audio_r(i2s_audio_r_out),
        .o_audio_valid(i2s_audio_valid_out),
        .o_mclk(o_mclk),
        .o_sclk(o_sclk),
        .o_lrclk(o_lrclk),
        .o_tx_sd(o_tx_sd)
	);

	assign fifo_in_rst = c_reg[4]; // Use the most significant bit as an extended reset signal.
    assign fifo_in_wr_en = i_audio_valid;
    assign fifo_in_rd_en = i2s_audio_valid_out;

    // Pack and unpack the input audio.
    assign fifo_in_din = {i_audio_l, i_audio_r};
	assign i2s_audio_l_in = fifo_in_dout[(2*`DATA_BIT)-1:`DATA_BIT]; // Unpack i_audio_l and i_audio_r.
    assign i2s_audio_r_in = fifo_in_dout[`DATA_BIT-1:0];

    // Pack and unpack the output audio.
    assign fifo_out_din = {i2s_audio_l_out, i2s_audio_r_out};
	assign o_audio_l = fifo_out_dout[(2*`DATA_BIT)-1:`DATA_BIT];
    assign o_audio_r = fifo_out_dout[`DATA_BIT-1:0];
endmodule
