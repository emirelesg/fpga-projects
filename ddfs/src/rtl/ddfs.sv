module ddfs
    #(
        parameter   PHASE_WIDTH = 30,   // 30-bit phase accumulator
                    ADDR_WIDTH  = 11    // 2048 bytes
    )
    (
        input   logic                   i_clk,
        input   logic                   i_reset_n,
        input   logic                   i_en,           // Enable signal to generate a new sample.
        input   logic [PHASE_WIDTH-1:0] i_fccw,         // Carrier frequency control word
        input   logic [PHASE_WIDTH-1:0] i_focw,         // Frequency offset control word
        input   logic [PHASE_WIDTH-1:0] i_pha,          // Phase offset
        input   logic [15:0]            i_env,          // Q2.14 Envelope
        input   logic [2:0]             i_wave_type,    // Wave selection control
        output  logic [15:0]            o_pcm_out,
        output  logic                   o_pulse_out,
        output  logic                   o_data_valid
    );

    logic [ADDR_WIDTH-1:0] p2a_r_addr;

    logic [PHASE_WIDTH-1:0] pcw;
    logic [PHASE_WIDTH-1:0] fcw;
    logic [PHASE_WIDTH-1:0] p_reg, p_next;

    logic signed [31:0] modulated; // Q18.14
    logic [15:0] wave, sine, saw, triangle, square; // Q16.0
    logic [15:0] pcm_reg, pcm_next; // Q16.0
    logic valid_reg, valid_next;

    sin_rom #(.ADDR_WIDTH(ADDR_WIDTH)) sin_rom_unit(
        .i_clk(i_clk),
        .i_r_addr(p2a_r_addr),
        .o_r_data(sine)
    );

    always_ff @(posedge i_clk, negedge i_reset_n)
        if (~i_reset_n) begin
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
    assign fcw = i_fccw + i_focw;

    // Phase modulation
    assign pcw = p_reg + i_pha;

    // Phase to amplitude mapping address
    // Use the ADDR_WIDTH MSBs of the PCW value as the address to look-up the SINE value.
    assign p2a_r_addr = pcw[PHASE_WIDTH-1:PHASE_WIDTH-ADDR_WIDTH];

    // Sawtooth generation
    // The singal is identical to the upper 16 bits of the accomulator.
    assign saw = pcw[PHASE_WIDTH-1:PHASE_WIDTH-16];

    // Triangle generation
    // The signal uses the sawtooth's MSB to detect the rising or falling cycle of the triangle wave.
    assign triangle = saw[15] ? {saw[14], ~saw[13:0], 1'b1} : {~saw[14], saw[13:0], 1'b0};

    // Square generation
    assign square = {~saw[15], {15{saw[15]}}};

    // Wave MUX
    always_comb begin
        unique case (i_wave_type)
            3'b001: wave = sine;
            3'b010: wave = saw;
            3'b011: wave = triangle;
            3'b100: wave = square;
            default: wave = 0; // No wave.
        endcase
    end

    // Amplitude modulation
    assign modulated = $signed(i_env) * $signed(wave);

    always_comb begin
        p_next = p_reg;
        pcm_next = pcm_reg;
        valid_next = 1'b0;

        if (i_en) begin
            // Phase accumulation
            p_next = p_reg + fcw;

            // To trim the multiplication of two 16-bit signed integers,
            // use the 16 MSBs of the modulated value.
            pcm_next = modulated[29:14];

            // Generate a tick when the data changes. Used to interface with a fifo as a wr_en signal.
            valid_next = 1'b1;
        end
    end

    assign o_pcm_out = pcm_reg;
    assign o_pulse_out = p_reg[PHASE_WIDTH-1];
    assign o_data_valid = valid_reg;
endmodule
