module mmio_adsr
    (
        input logic clk,
        input logic reset_n,
        // MMIO slot
        input logic cs,
        input logic write,
        input logic read,
        input logic [4:0] addr,
        input logic [31:0] write_data,
        output logic [31:0] read_data,
        // External
        input logic [15:0] env
    );

    logic [15:0] env_out;
    logic [31:0] attack_step_reg, decay_step_reg, sustain_time_reg, sustain_level_reg, release_step_reg;
    logic wr_en, wr_start, wr_attack_step, wr_decay_step, wr_sustain_time, wr_sustain_level, wr_release_step;

    adsr adsr_unit(
        .clk(clk),
        .reset_n(reset_n),
        .start(wr_start),
        .attack_step(attack_step_reg),
        .decay_step(decay_step_reg),
        .sustain_time(sustain_time_reg),
        .sustain_level(sustain_level_reg),
        .release_step(release_step_reg),
        .env(env_out)
    );

    always_ff @(posedge clk, negedge reset_n) begin
        if (~reset_n) begin
            attack_step_reg <= 0;
            decay_step_reg <= 0;
            sustain_time_reg <= 0;
            sustain_level_reg <= 0;
            release_step_reg <= 0;
        end
        else begin
            if (wr_attack_step)
                attack_step_reg <= write_data;
            if (wr_decay_step)
                decay_step_reg <= write_data;
            if (wr_sustain_time)
                sustain_time_reg <= write_data;
            if (wr_sustain_level)
                sustain_level_reg <= write_data;
            if (wr_release_step)
                release_step_reg <= write_data;
        end
    end

    assign wr_en = cs & write;
    assign wr_start = (addr[2:0] == 3'b000) & wr_en;
    assign wr_attack_step = (addr[2:0] == 3'b001) & wr_en;
    assign wr_decay_step = (addr[2:0] == 3'b010) & wr_en;
    assign wr_sustain_time = (addr[2:0] == 3'b011) & wr_en;
    assign wr_sustain_level = (addr[2:0] == 3'b100) & wr_en;
    assign wr_release_step = (addr[2:0] == 3'b101) & wr_en;
    assign read_data = 0;
    assign env = env_out;
endmodule
