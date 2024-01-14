module i2s
    #(
        parameter   DATA_BIT = 16
    )
    (
        input logic clk_i2s, // 12.288 Mhz
        input logic reset_n,
        input logic [DATA_BIT-1:0] tx_data,
        output logic tx_mclk,
        output logic tx_sclk,
        output logic tx_lrclk,
        output logic tx_sd
    );

    // The mclk/lrclk ratio must be 256 times.
    // See section 4.1.1: https://statics.cirrus.com/pubs/proDatasheet/CS5343-44_F5.pdf
    localparam RATIO = 256;
        
    logic sclk, sclk_tick;
    logic lrclk, lrclk_tick;
    logic [$clog2(RATIO - 1):0] ctr_reg, ctr_next;
    
    always_ff @(posedge clk_i2s, negedge reset_n) begin
        if (~reset_n)
            ctr_reg <= 0;
        else
            ctr_reg <= ctr_next;
    end
    
    always_comb begin
        ctr_next = ctr_reg + 1;
        
        // sclk: 1.536 Mhz = 12.288 Mhz / 8
        sclk = ctr_reg[2]; // 0 - 3
        sclk_tick = ctr_reg[2:0] == 7;
        
        // lrclk: 48 khz = 1.536 Mhz / 16 bits / 2 channels
        lrclk = ctr_reg[7]; // 0 - 255
        lrclk_tick = ctr_reg[7:0] == 255;
    end
    
    // Transmit
    
    typedef enum {load, start} state_type;
    
    state_type state_reg, state_next;
    logic [DATA_BIT-1:0] word_reg, word_next;
    logic sd;
        
    always_ff @(posedge clk_i2s, negedge reset_n) begin
        if (~reset_n) begin
            state_reg <= load;
            word_reg <= 0;
        end
        else begin
            state_reg <= state_next;
            word_reg <= word_next;
        end
    end
    
    always_comb begin
        // Default values:
        state_next = state_reg;
        word_next = word_reg;
        sd = word_reg[DATA_BIT-1]; // The MSB of word_reg.
        
        case (state_reg)
            load: begin
                state_next = start;
                word_next = tx_data;
            end
            start: begin 
                if (lrclk_tick)
                    state_next = load;
                else if (sclk_tick)
                    word_next = word_reg << 1;
            end
        endcase
    end
     
    assign tx_mclk = clk_i2s;
    assign tx_sclk = sclk;
    assign tx_lrclk = lrclk;
    assign tx_sd = sd;
endmodule
