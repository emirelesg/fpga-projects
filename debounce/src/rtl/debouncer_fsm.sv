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
    
    /* ~~ Free running DB_TIME tick generator ~~ */
    
    localparam Q_MAX = $rtoi(CLK_FREQ * DB_TIME) - 1;
     
    logic [$clog2(Q_MAX)-1:0] q_reg, q_next;
    logic m_tick;
    
    always_ff @(posedge clk, negedge reset_n) begin
        if (~reset_n)
            q_reg <= 0;
        else
            q_reg <= q_next;
    end
    
    assign q_next = (q_reg == Q_MAX) ? 1'b0 : q_reg + 1;
    assign m_tick = (q_reg == 0) ? 1'b1 : 1'b0;
    
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
    
    // ~~ Assignment of outputs ~~ //
endmodule