/*
 * debouncer_fsm
 *
 * Debounce input signal "sw" to output signal "db".
 * The debounce time is between DB_TIME and 2*DB_TIME.
 */

module debouncer_fsm
    #(
        parameter   CLK_FREQ = 100_000_000, // 100 Mhz, 10 ns
                    DB_TIME = 0.010 // 10 ms
    )
    (
        input logic clk,
        input logic reset_n,
        input logic sw,
        output logic db
    );
    
    /* ~~ Create mod_m_counter_unit ~~ */
    
    logic m_tick;

    mod_m_counter #(.M($rtoi(CLK_FREQ * DB_TIME))) mod_m_counter_unit(
        .clk(clk),
        .reset_n(reset_n),
        .max_tick(m_tick)
    );
    
    /* ~~ Debouncer using a FSM ~~ */
    
    typedef enum { zero, wait1_1, wait1_2, one } state_type;
    state_type state_reg, state_next;
    
    always_ff @(posedge clk, negedge reset_n) begin
        if (~reset_n)
            state_reg <= zero;
        else
            state_reg <= state_next;
    end
 
    always_comb begin
        // Default values:
        state_next = state_reg; // Stay in state_reg
        db = 1'b0;
        
        case (state_reg)
            zero:
                if (sw)
                    state_next = wait1_1; // On hold -> wait1_1
            wait1_1:
                if (~sw)
                    state_next = zero; // On release -> zero
                else if (m_tick)
                    state_next = wait1_2; // On hold and after DB_TIME -> wait1_2    
            wait1_2:
                if (~sw)
                    state_next = zero; // On release -> zero
                else if (m_tick)
                    state_next = one; // On hold and after DB_TIME -> one
            one:
                if (~sw)
                    state_next = zero; // On release -> zero
                else
                    db = 1'b1;
       endcase
    end
endmodule