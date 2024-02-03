/*
 * i2s
 *
 * Implements an i2s transmitter for the CS5343 chip.
 *
 * mclk: 12.288 MHz = 48 kHz * 256
 * sclk: 3.072 MHz = 48 kHz * 64
 *
 * The default ratios are for a 48 kHz sampling rate.
 * See section 4.1.1 for other options
 * https://statics.cirrus.com/pubs/proDatasheet/CS5343-44_F5.pdf
 */

module i2s
    #(
        parameter   MCLK_LRCK_RATIO = 256,
                    SCLK_LRCK_RATIO = 64,
                    DATA_BIT = 24           // The number of bits to transmit via i2s.
                                            // The CS5343 chip requires 24 bits per channel.
    )
    (
        input logic clk_i2s, // 12.288 Mhz
        input logic reset_n,
        input logic [15:0] tx_data_l,
        input logic [15:0] tx_data_r,
        output logic tx_mclk,
        output logic tx_sclk,
        output logic tx_lrclk,
        output logic tx_sd
    );

    // Generate sclk and sclk_tick.

    localparam SCLK_DVSR = MCLK_LRCK_RATIO / SCLK_LRCK_RATIO;

    logic [$clog2(SCLK_DVSR)-1:0] cnt, cnt_next;

    logic sclk, sclk_tick;

    always_ff @(posedge clk_i2s, negedge reset_n) begin
        if (~reset_n)
            cnt = 0;
        else
            cnt <= cnt + 1;
    end

    assign sclk = cnt[1];
    assign sclk_tick = cnt == SCLK_DVSR - 1;

    // Generate lrclk and sd.

    typedef enum {load, start} state_type;
    state_type state_reg, state_next;

    logic sd_reg, sd_next;
    logic [DATA_BIT-1:0] data_l_reg, data_l_next, data_r_reg, data_r_next;
    logic [$clog2(DATA_BIT*2 - 1):0] sclk_cnt, sclk_cnt_next;

    logic lrclk;

    always_ff @(posedge clk_i2s, negedge reset_n) begin
        if (~reset_n) begin
            state_reg <= load;
            sd_reg <= 1'b0;
            sclk_cnt = 0;
            data_l_reg = 0;
            data_r_reg = 0;
        end
        else begin
            state_reg <= state_next;
            sd_reg <= sd_next;
            sclk_cnt <= sclk_cnt_next;
            data_l_reg <= data_l_next;
            data_r_reg <= data_r_next;
        end
    end

    always_comb begin
        // Default values:
        state_next = state_reg;
        sd_next = sd_reg;
        sclk_cnt_next = sclk_cnt;
        data_l_next = data_l_reg;
        data_r_next = data_r_reg;

        case (state_reg)
            load: begin
                state_next = start;
                sclk_cnt_next = 0;
                data_l_next = {tx_data_l, 8'h00}; // Convert 16 data bits to 24 data bits.
                data_r_next = {tx_data_r, 8'h00};
            end
            start: begin
                if (sclk_tick) begin
                    // The i2s protocol specifies that the MSB of a word to be clocked on the second sclk_tick.
                    // sd is delayed using sd_reg and sd_next.
                    if (sclk_cnt < DATA_BIT) begin
                        sd_next = data_l_reg[DATA_BIT-1];
                        data_l_next = data_l_reg << 1;
                    end
                    else begin
                        sd_next = data_r_reg[DATA_BIT-1];
                        data_r_next = data_r_reg << 1;
                    end

                    // For 24 data bits, count from 0 to 37.
                    if (sclk_cnt < DATA_BIT*2 - 1)
                        sclk_cnt_next = sclk_cnt + 1;
                    else begin
                        state_next = load;
                    end
                end
            end
        endcase
    end

    // For 24 data bits, toggle lrclk from 24 to 37.
    assign lrclk = sclk_cnt > DATA_BIT - 1;

    assign tx_mclk = clk_i2s;
    assign tx_sclk = sclk;
    assign tx_lrclk = lrclk;
    assign tx_sd = sd_reg;
endmodule
