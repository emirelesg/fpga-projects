/*
 * mod_m_counter
 * 
 * Generates a tick after M-1 counts.
 */

module mod_m_counter
    #(
        parameter   M = 100
    )
    (
        input logic clk,
        input logic reset_n,
        output logic max_tick
    );
             
    logic [$clog2(M)-1:0] q_reg, q_next;
    
    always_ff @(posedge clk, negedge reset_n) begin
        if (~reset_n)
            q_reg <= 0;
        else
            q_reg <= q_next;
    end
    
    assign q_next = (q_reg == M-1) ? 1'b0 : q_reg + 1;
    
    /* ~~ Assignment of outputs ~~ */
    
    assign max_tick = (q_reg == M-1) ? 1'b1 : 1'b0;
endmodule