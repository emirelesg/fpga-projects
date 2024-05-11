`include "io_mmio_map.svh"
module mmio_top
    (
        input logic clk,
        input logic clk_i2s,
        input logic reset_n,
        // MMIO bus
        input logic mmio_cs,
        input logic mmio_write,
        input logic mmio_read,
        input logic [20:0] mmio_addr,
        input logic [31:0] mmio_write_data,
        output logic [31:0] mmio_read_data,
        // External
        output logic [3:0] led,
        output logic audio_tx_mclk,
        output logic audio_tx_sclk,
        output logic audio_tx_lrclk,
        output logic audio_tx_sd
    );

    logic [63:0] slot_cs_array;
    logic [63:0] slot_read_array;
    logic [63:0] slot_write_array;
    logic [31:0] slot_read_data_array [63:0];
    logic [31:0] slot_write_data_array [63:0];
    logic [4:0] slot_reg_addr_array [63:0];

    mmio_controller mmio_controller_unit(
        // MMIO bus
        .mmio_cs(mmio_cs),
        .mmio_write(mmio_write),
        .mmio_read(mmio_read),
        .mmio_addr(mmio_addr),
        .mmio_write_data(mmio_write_data),
        .mmio_read_data(mmio_read_data),
        // MMIO Slot
        .slot_cs_array(slot_cs_array),
        .slot_read_array(slot_read_array),
        .slot_write_array(slot_write_array),
        .slot_read_data_array(slot_read_data_array),
        .slot_write_data_array(slot_write_data_array),
        .slot_reg_addr_array(slot_reg_addr_array)
    );

    // Slot 0: GPO
    logic [31:0] gpo;

    mmio_gpo mmio_gpo_unit(
        .clk(clk),
        .reset_n(reset_n),
        // MMIO Slot
        .cs(slot_cs_array[`IO_S0_GPO]),
        .read(slot_read_array[`IO_S0_GPO]),
        .write(slot_write_array[`IO_S0_GPO]),
        .addr(slot_reg_addr_array[`IO_S0_GPO]),
        .read_data(slot_read_data_array[`IO_S0_GPO]),
        .write_data(slot_write_data_array[`IO_S0_GPO]),
        // External
        .d_out(gpo)
    );

    assign led = gpo[3:0];

    // Slot 1: DDFS
    logic ddfs_en, ddfs_data_valid;
    logic [15:0] adsr_env;
    logic [15:0] ddfs_pcm_out;

    mmio_ddfs mmio_ddfs_unit(
        .i_clk(clk),
        .i_reset_n(reset_n),
        // MMIO Slot
        .i_cs(slot_cs_array[`IO_S1_DDFS]),
        .i_write(slot_write_array[`IO_S1_DDFS]),
        .i_read(slot_read_array[`IO_S1_DDFS]),
        .i_addr(slot_reg_addr_array[`IO_S1_DDFS]),
        .i_write_data(slot_write_data_array[`IO_S1_DDFS]),
        .o_read_data(slot_read_data_array[`IO_S1_DDFS]),
        // External
        .i_en(ddfs_en),
        .i_env_ext(adsr_env),
        .o_pcm_out(ddfs_pcm_out),
        .o_data_valid(ddfs_data_valid)
    );

    // Slot 2: ADSR
    mmio_adsr mmio_adsr_unit(
        .i_clk(clk),
        .i_reset_n(reset_n),
        // MMIO Slot
        .i_cs(slot_cs_array[`IO_S2_ADSR]),
        .i_write(slot_write_array[`IO_S2_ADSR]),
        .i_read(slot_read_array[`IO_S2_ADSR]),
        .i_addr(slot_reg_addr_array[`IO_S2_ADSR]),
        .i_write_data(slot_write_data_array[`IO_S2_ADSR]),
        .o_read_data(slot_read_data_array[`IO_S2_ADSR]),
        // External
        .o_env(adsr_env)
    );

    // i2s DAC
    i2s_cdc i2s_cdc_unit(
        .i_clk(clk),
        .i_clk_12_288(clk_i2s),
        .i_reset_n(reset_n),
        .i_audio_l(ddfs_pcm_out),
        .i_audio_r(ddfs_pcm_out),
        .i_data_valid(ddfs_data_valid),
        // Outputs
        .o_data_ready(ddfs_en),
        .o_tx_mclk(audio_tx_mclk),
        .o_tx_sclk(audio_tx_sclk),
        .o_tx_lrclk(audio_tx_lrclk),
        .o_tx_sd(audio_tx_sd)
    );

    // Unused slots
    // When trying to read from an unused slot, 0xffffffff is returned.
    generate
        genvar i;
        for (i=3; i<64; i=i+1) begin: unused_slot_gen
            assign slot_read_data_array[i] = 32'hffff_ffff;
        end
    endgenerate
endmodule
