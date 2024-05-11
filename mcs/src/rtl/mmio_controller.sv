module mmio_controller
    (
        // MMIO bus
        input   logic           i_mmio_cs,
        input   logic           i_mmio_write,
        input   logic           i_mmio_read,
        input   logic [20:0]    i_mmio_addr,
        input   logic [31:0]    i_mmio_write_data,
        output  logic [31:0]    o_mmio_read_data,
        // Slot
        output  logic [63:0]    o_slot_cs_array,
        output  logic [63:0]    o_slot_read_array,
        output  logic [63:0]    o_slot_write_array,
        input   logic [31:0]    i_slot_read_data_array  [63:0],
        output  logic [31:0]    o_slot_write_data_array [63:0],
        output  logic [4:0]     o_slot_reg_addr_array   [63:0]
    );

    logic [5:0] slot_addr;
    logic [4:0] reg_addr;

    assign slot_addr = i_mmio_addr[10:5]; // 6 bits = 64 slots
    assign reg_addr = i_mmio_addr[4:0]; // 5 bits = 32 registers

    always_comb begin
        // Default value:
        o_slot_cs_array = 0;
        if (i_mmio_cs)
            o_slot_cs_array[slot_addr] = 1;
    end

    // Broadcast the mmio signals to all slots.
    generate
        genvar i;
        for (i=0; i<64; i=i+1) begin: slot_signal_gen
            assign o_slot_read_array[i] = i_mmio_read;
            assign o_slot_write_array[i] = i_mmio_write;
            assign o_slot_write_data_array[i] = i_mmio_write_data;
            assign o_slot_reg_addr_array[i] = reg_addr;
        end
    endgenerate

    // Mux to select the data from the active slot.
    assign o_mmio_read_data = i_slot_read_data_array[slot_addr];
endmodule
