module mmio_controller
    (
        // MMIO bus
        input logic mmio_cs,
        input logic mmio_write,
        input logic mmio_read,
        input logic [20:0] mmio_addr,
        input logic [31:0] mmio_write_data,
        output logic [31:0] mmio_read_data,
        // Slot
        output logic [63:0] slot_cs_array,
        output logic [63:0] slot_read_array,
        output logic [63:0] slot_write_array,
        input logic [31:0] slot_read_data_array [63:0],
        output logic [31:0] slot_write_data_array [63:0],
        output logic [4:0] slot_reg_addr_array [63:0]
    );

    logic [5:0] slot_addr;
    logic [4:0] reg_addr;

    assign slot_addr = mmio_addr[10:5]; // 6 bits = 64 slots
    assign reg_addr = mmio_addr[4:0]; // 5 bits = 32 registers

    always_comb begin
        // Default value:
        slot_cs_array = 0;
        if (mmio_cs)
            slot_cs_array[slot_addr] = 1;
    end

    // Broadcast the mmio signals to all slots.
    generate
        genvar i;
        for (i=0; i<64; i=i+1) begin: slot_signal_gen
            assign slot_read_array[i] = mmio_read;
            assign slot_write_array[i] = mmio_write;
            assign slot_write_data_array[i] = mmio_write_data;
            assign slot_reg_addr_array[i] = reg_addr;
        end
    endgenerate

    // Mux to select the data from the active slot.
    assign mmio_read_data =  slot_read_data_array[slot_addr];
endmodule
