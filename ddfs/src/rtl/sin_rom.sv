module sin_rom
    #(
        parameter   DATA_WIDTH = 16,    // 16-bit data
                    ADDR_WIDTH = 11     // 2048 bytes
    )
    (
        input logic clk,
        input logic [ADDR_WIDTH-1:0] r_addr,
        output logic [DATA_WIDTH-1:0] r_data
    );

    (* ram_style = "block" *) logic [DATA_WIDTH-1:0] ram [0:2**ADDR_WIDTH-1];

    // Loads 16-bit signed integers representing a full cycle of a SINE wave.
    initial
        $readmemh("sin_rom.mem", ram);

    always_ff @(posedge clk)
        r_data <= ram[r_addr];
endmodule
