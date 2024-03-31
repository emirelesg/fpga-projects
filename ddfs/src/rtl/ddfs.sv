module ddfs
    #(
        parameter   PHASE_WIDTH = 30,   // 30-bit phase accumulator
                    ADDR_WIDTH = 11     // 2048 values
    )
    (
        input logic clk,
        input logic reset_n,
        input logic en,                     // Enable signal to generate a new sample.
        input logic [PHASE_WIDTH-1:0] fccw, // Carrier frequency control word
        input logic [PHASE_WIDTH-1:0] focw, // Frequency offset control word
        input logic [PHASE_WIDTH-1:0] pha,  // Phase offset
        input logic [15:0] env, // Q2.14    // Envelope
        output logic [15:0] pcm_out,
        output logic pulse_out,
        output logic data_valid
    );

    logic [ADDR_WIDTH-1:0] p2a_r_addr;
    logic [15:0] amp;

    logic [PHASE_WIDTH-1:0] pcw;
    logic [PHASE_WIDTH-1:0] fcw;
    logic [PHASE_WIDTH-1:0] p_reg, p_next;

    logic signed [31:0] modulated; // Q18.14
    logic [15:0] pcm_reg, pcm_next; // Q16.0
    logic valid_reg, valid_next;

    sin_rom #(.ADDR_WIDTH(ADDR_WIDTH)) sin_rom_unit(
        .clk(clk),
        .r_addr(p2a_r_addr),
        .r_data(amp)
    );

    always_ff @(posedge clk, negedge reset_n)
        if (~reset_n) begin
            p_reg <= 0;
            pcm_reg <= 0;
            valid_reg <= 1'b0;
        end
        else begin
            p_reg <= p_next;
            pcm_reg <= pcm_next;
            valid_reg <= valid_next;
        end

    // Frequence modulation
    assign fcw = fccw + focw;

    // Phase modulation
    assign pcw = p_reg + pha;

    // Phase to amplitude mapping address
    // Use the ADDR_WIDTH MSBs of the PCW value as the address to look-up the SINE value.
    assign p2a_r_addr = pcw[PHASE_WIDTH-1:PHASE_WIDTH-ADDR_WIDTH];

    // Amplitude modulation
    assign modulated = $signed(env) * $signed(amp);

    always_comb begin
        p_next = p_reg;
        pcm_next = pcm_reg;
        valid_next = 1'b0;

        if (en) begin
            // Phase accumulation
            p_next = p_reg + fcw;

            // To trim the multiplication of two 16-bit signed integers,
            // use the 16 MSBs of the modulated value.
            pcm_next = modulated[29:14];

            // Generate a tick when the data changes. Used to interface with a fifo as a wr_en signal.
            valid_next = 1'b1;
        end
    end

    assign pcm_out = pcm_reg;
    assign pulse_out = p_reg[PHASE_WIDTH-1];
    assign data_valid = valid_reg;
endmodule
