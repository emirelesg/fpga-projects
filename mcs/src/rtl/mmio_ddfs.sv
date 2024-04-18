module mmio_ddfs
    #(
        PW = 30 // Phase width
    )
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
        input logic en,
        input logic [15:0] env_ext,
        output logic [15:0] pcm_out,
        output logic data_valid
    );

    logic [3:0] ctrl_reg;
    // Bit 0: env source select
    // Bit 1-15: unused

    logic [PW-1:0] pha_reg, fccw_reg, focw_reg;
    logic [15:0] env, env_reg;
    logic wr_en, wr_ctrl, wr_env, wr_fccw, wr_focw, wr_pha;

    ddfs ddfs_unit(
        .clk(clk),
        .reset_n(reset_n),
        .en(en),
        .fccw(fccw_reg),
        .focw(focw_reg),
        .pha(pha_reg),
        .env(env),
        // Outputs
        .pcm_out(pcm_out),
        .data_valid(data_valid)
    );

    always_ff @(posedge clk, negedge reset_n) begin
        if (~reset_n) begin
            pha_reg <= 0;
            fccw_reg <= 0;
            focw_reg <= 0;
            env_reg <= 16'h4000; // 1.0
            ctrl_reg <= 0;
        end
        else begin
            if (wr_fccw)
                fccw_reg <= write_data[PW-1:0];
            if (wr_focw)
                focw_reg <= write_data[PW-1:0];
            if (wr_pha)
                pha_reg <= write_data[PW-1:0];
            if (wr_env)
                env_reg <= write_data[15:0];
            if (wr_ctrl)
                ctrl_reg <= write_data[3:0];
        end
    end

    assign env = ctrl_reg[0] ? env_ext : env_reg;

    assign wr_en = cs & write;
    assign wr_fccw = (addr[2:0] == 3'b000) & wr_en;
    assign wr_focw = (addr[2:0] == 3'b001) & wr_en;
    assign wr_pha = (addr[2:0] == 3'b010) & wr_en;
    assign wr_env = (addr[2:0] == 3'b011) & wr_en;
    assign wr_ctrl = (addr[2:0] == 3'b100) & wr_en;
    assign read_data = {28'h0000000, ctrl_reg};
endmodule
