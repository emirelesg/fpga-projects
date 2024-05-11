module mmio_ddfs
    #(
        parameter   PW = 30 // Phase width
    )
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
        input   logic           i_en,
        input   logic [15:0]    i_env_ext,
        output  logic [15:0]    o_pcm_out,
        output  logic           o_data_valid
    );

    logic [31:0] ctrl_reg;
    // Bit 0: env source select
    // Bit 1-3: unused
    // Bit 4-6: wave type select
    // Bit 7-15: unused

    logic [PW-1:0] pha_reg, fccw_reg, focw_reg;
    logic [2:0] wave_type;
    logic [15:0] env, env_reg;
    logic wr_en, wr_ctrl, wr_env, wr_fccw, wr_focw, wr_pha;

    ddfs ddfs_unit(
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),
        .i_en(i_en),
        .i_fccw(fccw_reg),
        .i_focw(focw_reg),
        .i_pha(pha_reg),
        .i_env(env),
        .i_wave_type(wave_type),
        // Outputs
        .o_pcm_out(o_pcm_out),
        .o_data_valid(o_data_valid)
    );

    always_ff @(posedge i_clk, negedge i_reset_n) begin
        if (~i_reset_n) begin
            pha_reg <= 0;
            fccw_reg <= 0;
            focw_reg <= 0;
            env_reg <= 16'h4000; // 1.0
            ctrl_reg <= 0;
        end
        else begin
            if (wr_fccw)
                fccw_reg <= i_write_data[PW-1:0];
            if (wr_focw)
                focw_reg <= i_write_data[PW-1:0];
            if (wr_pha)
                pha_reg <= i_write_data[PW-1:0];
            if (wr_env)
                env_reg <= i_write_data[15:0];
            if (wr_ctrl)
                ctrl_reg <= i_write_data;
        end
    end

    assign env = ctrl_reg[0] ? i_env_ext : env_reg;
    assign wave_type = ctrl_reg[6:4];

    assign wr_en = i_cs & i_write;
    assign wr_fccw = (i_addr[2:0] == 3'b000) & wr_en;
    assign wr_focw = (i_addr[2:0] == 3'b001) & wr_en;
    assign wr_pha = (i_addr[2:0] == 3'b010) & wr_en;
    assign wr_env = (i_addr[2:0] == 3'b011) & wr_en;
    assign wr_ctrl = (i_addr[2:0] == 3'b100) & wr_en;
    assign o_read_data = ctrl_reg;
endmodule
