module adsr
    (
        input   logic           i_clk,
        input   logic           i_reset_n,
        input   logic           i_start,
        input   logic [31:0]    i_attack_step, i_decay_step, i_sustain_level, i_release_step,
        input   logic [31:0]    i_sustain_time,
        output  logic [15:0]    o_env // Q2.14
    );

    localparam MAX = 32'h8000_0000;

    typedef enum {idle, launch, attack, decay, sustain, rel} state_type;

    state_type state_reg, state_next;
    logic [31:0] a_reg, a_next;     // Stores the attack value as Q1.31.
    logic [31:0] a_tmp;             // Temporary storage for calculations on a_next.
    logic [31:0] t_reg, t_next;     // The number of clk cycles in the sustain phase.

    always_ff @(posedge i_clk, negedge i_reset_n) begin
        if (~i_reset_n) begin
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
                if (i_start)
                    state_next = launch;
            end
            launch: begin
                state_next = attack;
                a_next = 0;
                t_next = 0;
            end
            attack: begin
                if (i_start)
                    state_next = launch; // Restart operation.
                else begin
                    a_tmp = a_reg + i_attack_step; // Increate a_reg by attack_step until MAX.
                    if (a_tmp < MAX)
                        a_next = a_tmp;
                    else
                        state_next = decay;
                end
            end
            decay: begin
                if (i_start)
                    state_next = launch; // Restart operation.
                else begin
                    a_tmp = a_reg - i_decay_step; // Decreate a_reg by decay_step until sustain_level.
                    if (a_tmp > i_sustain_level)
                        a_next = a_tmp;
                    else begin
                        a_next = i_sustain_level; // Keep it exactly at sustain_level.
                        state_next = sustain;
                    end
                end
            end
            sustain: begin
                if (i_start)
                    state_next = launch; // Restart operation.
                else
                    if (t_reg < i_sustain_time)
                        t_next = t_reg + 1;
                    else
                        state_next = rel;
            end
            rel: begin
                if (i_start)
                    state_next = launch; // Restart operation.
                else
                    if (a_reg > i_release_step)
                        a_next = a_reg - i_release_step;
                    else
                        state_next = idle;
            end
        endcase
    end

    assign o_env = {1'b0, a_reg[31:17]}; // Convert to Q2.14.
endmodule
