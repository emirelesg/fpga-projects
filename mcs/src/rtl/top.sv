module top
    (
        input   logic       i_clk,
        input   logic       i_reset_n,
        // External
        input   logic       i_uart_txd_in,
        output  logic       o_uart_rxd_out,
        output  logic [3:0] o_led,
        output  logic       o_audio_tx_mclk,
        output  logic       o_audio_tx_sclk,
        output  logic       o_audio_tx_lrclk,
        output  logic       o_audio_tx_sd,
        output  logic       o_audio_rx_mclk,
        output  logic       o_audio_rx_sclk,
        output  logic       o_audio_rx_lrclk,
        input   logic       i_audio_rx_sd
    );

    // Clocking Wizard
    logic clk_i2s; // 12.288 MHz

    // uBlaze MCS I/O bus
    logic io_addr_strobe;
    logic io_read_strobe;
    logic io_write_strobe;
    logic [3:0] io_byte_enable;
    logic [31:0] io_address;
    logic [31:0] io_write_data;
    logic [31:0] io_read_data;
    logic io_ready;

    // MMIO bus
    logic mmio_cs;
    logic mmio_write;
    logic mmio_read;
    logic [20:0] mmio_addr;
    logic [31:0] mmio_write_data;
    logic [31:0] mmio_read_data;

    // Audio
    logic audio_mclk;
    logic audio_sclk;
    logic audio_lrclk;

    design_1 design_1_unit (
        .clk(i_clk),
        .reset_n(i_reset_n),
        // Clocking Wizard
        .clk_i2s(clk_i2s),
        // UART
        .rx(i_uart_txd_in),
        .tx(o_uart_rxd_out),
        // uBlaze MCS I/O bus
        .IO_addr_strobe(io_addr_strobe),
        .IO_address(io_address),
        .IO_byte_enable(io_byte_enable),
        .IO_read_data(io_read_data),
        .IO_read_strobe(io_read_strobe),
        .IO_ready(io_ready),
        .IO_write_data(io_write_data),
        .IO_write_strobe(io_write_strobe)
    );

    io_mmio_bridge io_mmio_bridge_unit(
        // uBlaze MCS I/O bus
        .i_io_addr_strobe(io_addr_strobe),
        .i_io_read_strobe(io_read_strobe),
        .i_io_write_strobe(io_write_strobe),
        .i_io_byte_enable(io_byte_enable),
        .i_io_address(io_address),
        .i_io_write_data(io_write_data),
        .o_io_read_data(io_read_data),
        .o_io_ready(io_ready),
        // MMIO bus
        .o_mmio_cs(mmio_cs),
        .o_mmio_write(mmio_write),
        .o_mmio_read(mmio_read),
        .o_mmio_addr(mmio_addr),
        .o_mmio_write_data(mmio_write_data),
        .i_mmio_read_data(mmio_read_data)
    );

    mmio_top mmio_top_unit(
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),
        // MMIO bus
        .i_mmio_cs(mmio_cs),
        .i_mmio_write(mmio_write),
        .i_mmio_read(mmio_read),
        .i_mmio_addr(mmio_addr),
        .i_mmio_write_data(mmio_write_data),
        .o_mmio_read_data(mmio_read_data),
        // External
        .i_clk_i2s(clk_i2s),
        .o_led(o_led),
        // Audio
        .o_audio_mclk(audio_mclk),
        .o_audio_sclk(audio_sclk),
        .o_audio_lrclk(audio_lrclk),
        .o_audio_tx_sd(o_audio_tx_sd),
        .i_audio_rx_sd(i_audio_rx_sd)
    );

    assign o_audio_tx_mclk = audio_mclk;
    assign o_audio_rx_mclk = audio_mclk;
    assign o_audio_tx_sclk = audio_sclk;
    assign o_audio_rx_sclk = audio_sclk;
    assign o_audio_tx_lrclk = audio_lrclk;
    assign o_audio_rx_lrclk = audio_lrclk;
endmodule
