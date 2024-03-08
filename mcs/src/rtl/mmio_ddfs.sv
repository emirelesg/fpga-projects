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
        input logic [15:0] env_ext,
        output logic [15:0] pcm_out
    );
    
    logic [PW-1:0] pha_reg, fccw_reg, focw_reg;
    logic wr_fccw, wr_focw, wr_pha;
    
    ddfs ddfs_unit(
        .clk(clk),
        .reset_n(reset_n),
        .fccw(fccw_reg),
        .focw(focw_reg),
        .pha(pha_reg),
        .env(env_ext),
        .pcm_out(pcm_out)
    );
    
    always_ff @(posedge clk, negedge reset_n) begin
        if (~reset_n) begin
            pha_reg <= 0;
            fccw_reg <= 0;
            focw_reg <= 0;
        end
        else begin
            if (wr_fccw)
                fccw_reg <= write_data[PW-1:0];
            if (wr_focw)
                focw_reg <= write_data[PW-1:0];
            if (wr_pha)
                pha_reg <= write_data[PW-1:0];
        end
    end
    
    assign wr_fccw = (addr[2:0] == 3'b000) & write;
    assign wr_focw = (addr[2:0] == 3'b001) & write;
    assign wr_pha = (addr[2:0] == 3'b010) & write;
    assign read_data = {16'h00000, pcm_out};
endmodule
