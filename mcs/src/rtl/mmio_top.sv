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
    
    logic [15:0] env;
    logic [15:0] pcm_out;
    
    mmio_ddfs mmio_ddfs_unit(
        .clk(clk),
        .reset_n(reset_n),
        // MMIO Slot
        .cs(slot_cs_array[`IO_S1_DDFS]),
        .read(slot_read_array[`IO_S1_DDFS]),
        .write(slot_write_array[`IO_S1_DDFS]),
        .addr(slot_reg_addr_array[`IO_S1_DDFS]),
        .read_data(slot_read_data_array[`IO_S1_DDFS]),
        .write_data(slot_write_data_array[`IO_S1_DDFS]),
        // External
        .env_ext(env),
        .pcm_out(pcm_out)
    );
    
    // Slot 2: ADSR
    
    mmio_adsr mmio_adsr_unit(
        .clk(clk),
        .reset_n(reset_n),
        // MMIO Slot
        .cs(slot_cs_array[`IO_S2_ADSR]),
        .read(slot_read_array[`IO_S2_ADSR]),
        .write(slot_write_array[`IO_S2_ADSR]),
        .addr(slot_reg_addr_array[`IO_S2_ADSR]),
        .read_data(slot_read_data_array[`IO_S2_ADSR]),
        .write_data(slot_write_data_array[`IO_S2_ADSR]),
        // External
        .env(env)
    );
    
    // DAC
    
    i2s i2s_unit(
        .clk(clk),
        .clk_i2s(clk_i2s),
        .reset_n(reset_n),
        .audio_l(pcm_out),
        .audio_r(pcm_out),
        .tx_mclk(audio_tx_mclk),
        .tx_sclk(audio_tx_sclk),
        .tx_lrclk(audio_tx_lrclk),
        .tx_sd(audio_tx_sd)
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
