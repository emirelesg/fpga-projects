module top
    (
        input logic clk,
        input logic reset_n,
        // External
        input logic uart_txd_in,
        output logic uart_rxd_out,
        output logic [3:0] led,
        output logic audio_tx_mclk,
        output logic audio_tx_sclk,
        output logic audio_tx_lrclk,
        output logic audio_tx_sd
    );
    
    // Clocking Wizard
    logic clk_i2s; // 24.576 MHz

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

    design_1 design_1_unit (
        .clk(clk),
        .reset_n(reset_n),
        // Clocking Wizard
        .clk_i2s(clk_i2s),
        // UART
        .rx(uart_txd_in),
        .tx(uart_rxd_out),
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
        .io_addr_strobe(io_addr_strobe),
        .io_read_strobe(io_read_strobe),
        .io_write_strobe(io_write_strobe),
        .io_byte_enable(io_byte_enable),
        .io_address(io_address),
        .io_write_data(io_write_data),
        .io_read_data(io_read_data),
        .io_ready(io_ready),
        // MMIO bus
        .mmio_cs(mmio_cs),
        .mmio_write(mmio_write),
        .mmio_read(mmio_read),
        .mmio_addr(mmio_addr),
        .mmio_write_data(mmio_write_data),
        .mmio_read_data(mmio_read_data)
    );

    mmio_top mmio_top_unit(
        .clk(clk),
        .reset_n(reset_n),
        // MMIO bus
        .mmio_cs(mmio_cs),
        .mmio_write(mmio_write),
        .mmio_read(mmio_read),
        .mmio_addr(mmio_addr),
        .mmio_write_data(mmio_write_data),
        .mmio_read_data(mmio_read_data),
        // External
        .clk_i2s(clk_i2s),
        .led(led),
        .audio_tx_mclk(audio_tx_mclk),
        .audio_tx_sclk(audio_tx_sclk),
        .audio_tx_lrclk(audio_tx_lrclk),
        .audio_tx_sd(audio_tx_sd)
    );

endmodule
