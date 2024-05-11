module mmio_adsr
    (
        input   logic           i_clk,
        input   logic           i_reset_n,
        // MMIO slot
        input   logic           i_cs,
        input   logic           i_write,
        input   logic           i_read,
        input   logic [4:0]     i_addr,
        input   logic [31:0]    i_write_data,
        output  logic [31:0]    o_read_data,
        // External
        output  logic [15:0]    o_env
    );

    logic [15:0] env;
    logic [31:0] attack_step_reg, decay_step_reg, sustain_time_reg, sustain_level_reg, release_step_reg;
    logic wr_en, wr_start, wr_attack_step, wr_decay_step, wr_sustain_time, wr_sustain_level, wr_release_step;

    adsr adsr_unit(
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),
        .i_start(wr_start),
        .i_attack_step(attack_step_reg),
        .i_decay_step(decay_step_reg),
        .i_sustain_time(sustain_time_reg),
        .i_sustain_level(sustain_level_reg),
        .i_release_step(release_step_reg),
        // Outputs
        .o_env(env)
    );

    always_ff @(posedge i_clk, negedge i_reset_n) begin
        if (~i_reset_n) begin
            attack_step_reg <= 0;
            decay_step_reg <= 0;
            sustain_time_reg <= 0;
            sustain_level_reg <= 0;
            release_step_reg <= 0;
        end
        else begin
            if (wr_attack_step)
                attack_step_reg <= i_write_data;
            if (wr_decay_step)
                decay_step_reg <= i_write_data;
            if (wr_sustain_time)
                sustain_time_reg <= i_write_data;
            if (wr_sustain_level)
                sustain_level_reg <= i_write_data;
            if (wr_release_step)
                release_step_reg <= i_write_data;
        end
    end

    assign wr_en = i_cs & i_write;
    assign wr_start = (i_addr[2:0] == 3'b000) & wr_en;
    assign wr_attack_step = (i_addr[2:0] == 3'b001) & wr_en;
    assign wr_decay_step = (i_addr[2:0] == 3'b010) & wr_en;
    assign wr_sustain_time = (i_addr[2:0] == 3'b011) & wr_en;
    assign wr_sustain_level = (i_addr[2:0] == 3'b100) & wr_en;
    assign wr_release_step = (i_addr[2:0] == 3'b101) & wr_en;
    assign o_read_data = 0; // No data to read from the adsr module.
    assign o_env = env;
endmodule
