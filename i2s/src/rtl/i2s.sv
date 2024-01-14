module i2s
    (
        input logic clk_i2s, // 12.288 Mhz
        input logic reset_n,
        input logic [15:0] tx_data,
        output logic tx_mclk,
        output logic tx_sclk,
        output logic tx_lrclk,
        output logic tx_sd
    );
    
    // Generate sclk from clk_i2s.
    
    // The following ratios are required for 48 kHz: 
    // mclk/lrck = 256
    // sclk/lrck = 64
    // See section 4.1.1  https://statics.cirrus.com/pubs/proDatasheet/CS5343-44_F5.pdf
    
    // mclk: 12.288 MHz = 48 kHz * 256    
    // sclk: 3.072 MHz = 48 kHz * 64 
    // SCLK_DVSR: 12.288 MHz / 3.072 MHz = 4
    
    localparam SCLK_DVSR = 4;
    
    logic [$clog2(SCLK_DVSR)-1:0] cnt, cnt_next;
    
    logic sclk, sclk_tick;
    
    always_ff @(posedge clk_i2s, negedge reset_n) begin
        if (~reset_n)
            cnt = 0;
        else
            cnt <= cnt_next;
    end
    
    always_comb begin
        cnt_next = cnt + 1;
        sclk = cnt[1];
        sclk_tick = cnt == SCLK_DVSR - 1;
    end
    
    // Generate lrclk and sd.
    
    localparam D_BIT = 24;
    
    logic lrclk;
    logic sd;
    
    typedef enum {load, start} state_type;
    
    logic [D_BIT-1:0] w_reg, w_next;
    logic [$clog2(D_BIT*2)-1:0] sclk_cnt, sclk_cnt_next;
    
    state_type state_reg, state_next;
        
    always_ff @(posedge clk_i2s, negedge reset_n) begin
        if (~reset_n) begin
            state_reg <= load;
            sclk_cnt = 0;
            w_reg = 0;
        end
        else begin
            state_reg <= state_next;
            sclk_cnt <= sclk_cnt_next;
            w_reg <= w_next;
        end
    end
    
    always_comb begin
        // Default values:
        state_next = state_reg;
        sclk_cnt_next = sclk_cnt;
        w_next = w_reg;

        lrclk = sclk_cnt > D_BIT - 1;
        sd = w_reg[D_BIT-1];
        
        case (state_reg)
            load: begin
                state_next = start;
                w_next = {1'b0, tx_data, 7'b0};
            end
            start: begin 
                if (sclk_tick) begin
                    w_next = w_reg << 1;
                    
                    if (sclk_cnt < D_BIT * 2 - 1)
                        sclk_cnt_next = sclk_cnt + 1;
                    else begin
                        sclk_cnt_next = 0;
                        state_next = load;
                    end
                end
            end
        endcase
    end
     
    assign tx_mclk = clk_i2s;
    assign tx_sclk = sclk;
    assign tx_lrclk = lrclk;
    assign tx_sd = sd;
endmodule
