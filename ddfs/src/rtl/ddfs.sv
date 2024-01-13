module ddfs
    #(
        parameter   PHASE_WIDTH = 30    // 30-bit phase accumulator
    )
    (
        input logic clk,
        input logic reset_n,
        input logic [PHASE_WIDTH-1:0] fccw, // Carrier frequency control word
        input logic [PHASE_WIDTH-1:0] focw, // Frequency offset control word
        input logic [PHASE_WIDTH-1:0] pha,  // Phase offset
        input logic [15:0] env, // Q2.14    // Envelope
        output logic [15:0] pcm_out,
        output logic pulse_out
    );
    
    logic [7:0] p2a_r_addr;
    logic [15:0] amp;
    
    logic [PHASE_WIDTH-1:0] pcw;
    logic [PHASE_WIDTH-1:0] fcw;
    logic [PHASE_WIDTH-1:0] p_reg, p_next;
    
    logic signed [31:0] modulated; // Q18.14
    logic [15:0] pcm_reg; // Q16.0
        
    sin_rom sin_rom_unit(
        .clk(clk),
        .r_addr(p2a_r_addr),
        .r_data(amp)
    );

    always_ff @(posedge clk, negedge reset_n)
        if (~reset_n) begin
            p_reg <= 0;
            pcm_reg <= 0;
        end
        else begin
            p_reg <= p_next;
            // To trim the multiplication of two 16-bit signed integers,
            // use the 16 MSBs of the modulated value.
            pcm_reg <= modulated[29:14];
        end
    
    // Frequence modulation
    assign fcw = fccw + focw;
    
    // Phase accumulation
    assign p_next = p_reg + fcw;
    
    // Phase modulation
    assign pcw = p_reg + pha;
    
    // Phase to amplitude mapping address
    // Use the 8 MSBs of the PCW value as the address to look-up the SINE value.
    assign p2a_r_addr = pcw[PHASE_WIDTH-1:PHASE_WIDTH-8];
    
    // Amplitude modulation
    assign modulated = $signed(env) * $signed(amp);
    
    assign pcm_out = pcm_reg;
    assign pulse_out = p_reg[PHASE_WIDTH-1];
endmodule
