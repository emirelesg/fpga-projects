module top
    (
        input logic clk,
        input logic reset_n,
        input logic [3:0] btn,
        output logic tx_mclk,
        output logic tx_sclk,
        output logic tx_lrclk,
        output logic tx_sd
    );

    /* ~~ Create design_1_wrapper unit ~~ */

    localparam CLK_I2S = 12_288_000;

    logic clk_i2s;

    design_1_wrapper design_1_wrapper_unit (
        .clk(clk),
        .reset_n(reset_n),
        // Outputs
        .clk_i2s(clk_i2s)
    );

    /* ~~ Create debouncer_fsm unit ~~ */

    localparam DB_MS = 0.010;

    logic btn_db, btn_db_tick;

    debouncer_fsm #(.DB_TIME(DB_MS), .CLK_FREQ(CLK_I2S)) debouncer_fsm_unit(
        .clk(clk_i2s),
        .reset_n(reset_n),
        .sw(btn != 0), // OR all buttons
        .db(btn_db),
        .db_tick(btn_db_tick)
    );

    /* ~~ Create adsr unit ~~ */

    localparam ADSR_MAX = 32'h7fff_ffff;
    localparam CLK_PER_MS = 0.001 / (1.0 / CLK_I2S);
    localparam ATTACK_MS = 5;
    localparam DECAY_MS = 100;
    localparam SUSTAIN_MS = 50;
    localparam RELEASE_MS = 200;
    localparam SUSTAIN_LEVEL = 0.25;
    localparam SUSTAIN_ABS = $rtoi(ADSR_MAX * SUSTAIN_LEVEL);

    logic [31:0] attack_step, decay_step, sustain_level, sustain_time, release_step;
    logic [15:0] env;

    initial begin
        attack_step = $rtoi(ADSR_MAX / (ATTACK_MS * CLK_PER_MS));
        decay_step = $rtoi((ADSR_MAX - SUSTAIN_ABS) / (DECAY_MS * CLK_PER_MS));
        sustain_level = SUSTAIN_ABS;
        sustain_time = $rtoi(SUSTAIN_MS * CLK_PER_MS);
        release_step = $rtoi(SUSTAIN_ABS / (RELEASE_MS * CLK_PER_MS));
    end

    adsr adsr_unit(
        .clk(clk_i2s),
        .reset_n(reset_n),
        .start(btn_db_tick),
        .attack_step(attack_step),
        .decay_step(decay_step),
        .sustain_level(sustain_level),
        .release_step(release_step),
        .sustain_time(sustain_time),
        // Outputs
        .env(env)
    );

    /* ~~ Create ddfs unit ~~ */

    logic [29:0] fccw_reg, fccw_next;

    always_ff @(posedge clk_i2s) begin
        fccw_reg <= fccw_next;
    end

    always_comb begin
        // Default values:
        fccw_next = fccw_reg;

        if (btn_db_tick)
            case (btn)
                // (2 ^ PHASE_WIDTH * freq / 12_288_000)
                4'b1000: fccw_next = 30513; // F4 349.2 Hz
                4'b0100: fccw_next = 28800; // E4 329.6 Hz
                4'b0010: fccw_next = 25664; // D4 293.7 Hz
                default: fccw_next = 22859; // C4 261.6 Hz
            endcase
    end

    logic [29:0] focw;
    logic [29:0] pha;
    logic [15:0] pcm_out;

    initial begin
        focw = 0;
        pha = 0;
    end

    ddfs ddfs_unit(
        .clk(clk_i2s),
        .reset_n(reset_n),
        .fccw(fccw_reg),
        .focw(focw),
        .pha(pha),
        .env(env),
        // Outputs
        .pcm_out(pcm_out)
    );

    /* ~~ Create i2s unit ~~ */

    i2s i2s_unit(
        .clk_i2s(clk_i2s),
        .reset_n(reset_n),
        .tx_data_l(pcm_out),
        .tx_data_r(pcm_out),
        // Outputs
        .tx_mclk(tx_mclk),
        .tx_sclk(tx_sclk),
        .tx_lrclk(tx_lrclk),
        .tx_sd(tx_sd)
    );
endmodule
