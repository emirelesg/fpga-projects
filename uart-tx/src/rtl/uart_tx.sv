/*
 * uart_tx
 *
 */

module uart_tx
    #(
        parameter   DBIT = 8 // Data bits
    )
    (
        input logic clk,
        input logic reset_n,
        input logic s_tick,
        input logic tx_start,
        input logic [7:0] tx_data,
        output logic tx_done_tick,
        output logic tx
    );

    typedef enum {idle, start, data, stop} state_type;

    state_type state_reg, state_next;
    logic [3:0] s_reg, s_next; // Counts s_tick from 0-15.
    logic [2:0] n_reg, n_next; // Counts transmitted bits from 0-7.
    logic [7:0] b_reg, b_next;
    logic tx_reg, tx_next;

    always_ff @(posedge clk, negedge reset_n) begin
        if (~reset_n) begin
            state_reg <= idle;
            s_reg <= 0;
            n_reg <= 0;
            b_reg <= 0;
            tx_reg <= 1'b1;
        end
        else begin
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
            tx_reg <= tx_next;
        end
    end

    always_comb
    begin
        tx_done_tick = 1'b0;
        state_next = state_reg;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;

        case (state_reg)
            idle: begin
                tx_next = 1'b1;
                // Hold tx HIGH until tx_start.
                if (tx_start) begin
                    state_next = start;
                    s_next = 0;
                    b_next = tx_data;
                end
            end
            start: begin
                tx_next = 1'b0;
                // Hold tx LOW for 15 s_ticks.
                if (s_tick)
                    if (s_reg == 15) begin
                        state_next = data;
                        s_next = 0;
                        n_next = 0;
                    end
                    else
                       s_next = s_reg + 1;
            end
            data: begin
               tx_next = b_reg[0];
               // Hold tx at b_reg[0] for 15 s_ticks;
               if (s_tick)
                    if (s_reg == 15) begin
                        s_next = 0;
                        b_next = b_reg >> 1;
                        if (n_reg == (DBIT-1))
                            state_next = stop;
                        else
                            n_next = n_reg + 1;
                    end
                    else
                       s_next = s_reg + 1;
            end
            stop: begin
                tx_next = 1'b1;
                // Hold tx HIGH for 15 s_ticks.
                if (s_tick)
                    if (s_reg == 15) begin
                        state_next = idle;
                        tx_done_tick = 1'b1;
                    end
                    else
                       s_next = s_reg + 1;
            end
        endcase
    end

    // ~~ Assignment of outputs ~~ //

    assign tx = tx_reg;

endmodule
