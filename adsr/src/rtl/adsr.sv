module adsr
    (
        input logic clk,
        input logic reset_n,
        input logic start,
        input logic [31:0] attack_step, decay_step, sustain_level, release_step,
        input logic [31:0] sustain_time,
        output logic [15:0] env // Q2.14
    );

    localparam MAX = 32'h8000_0000;

    typedef enum {idle, launch, attack, decay, sustain, rel} state_type;

    state_type state_reg, state_next;
    logic [31:0] a_reg, a_next;     // Stores the attack value as Q1.31.
    logic [31:0] a_tmp;             // Temporary storage for calculations on a_next.
    logic [31:0] t_reg, t_next;     // The number of clk cycles in the sustain phase.

    always_ff @(posedge clk, negedge reset_n) begin
        if (~reset_n) begin
            state_reg <= idle;
            a_reg <= 0;
            t_reg <= 0;
        end
        else begin
            state_reg <= state_next;
            a_reg <= a_next;
            t_reg <= t_next;
        end
    end

    always_comb begin
        // Default values:
        state_next = state_reg;
        a_next = a_reg;
        t_next = t_reg;

        case (state_reg)
            idle: begin
                if (start)
                    state_next = launch;
            end
            launch: begin
                state_next = attack;
                a_next = 0;
                t_next = 0;
            end
            attack: begin
                if (start)
                    state_next = launch; // Restart operation.
                else begin
                    a_tmp = a_reg + attack_step; // Increate a_reg by attack_step until MAX.
                    if (a_tmp < MAX)
                        a_next = a_tmp;
                    else
                        state_next = decay;
                end
            end
            decay: begin
                if (start)
                    state_next = launch; // Restart operation.
                else begin
                    a_tmp = a_reg - decay_step; // Decreate a_reg by decay_step until sustain_level.
                    if (a_tmp > sustain_level)
                        a_next = a_tmp;
                    else begin
                        a_next = sustain_level; // Keep it exactly at sustain_level.
                        state_next = sustain;
                    end
                end
            end
            sustain: begin
                if (start)
                    state_next = launch; // Restart operation.
                else
                    if (t_reg < sustain_time)
                        t_next = t_reg + 1;
                    else
                        state_next = rel;
            end
            rel: begin
                if (start)
                    state_next = launch; // Restart operation.
                else
                    if (a_reg > release_step)
                        a_next = a_reg - release_step;
                    else
                        state_next = idle;
            end
        endcase
    end

    assign env = {1'b0, a_reg[31:17]}; // Convert to Q2.14.
endmodule
