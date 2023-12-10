module top
    #(
        parameter   DB_TIME = 0.050 // 50 ms
    )
    (
        input logic clk,
        input logic reset_n,
        input logic btn,
        input logic uart_txd_in,
        output logic uart_rxd_out
    );

    /* ~~ Create debouncer_fsm unit ~~ */

    logic btn_db_tick;

    debouncer_fsm #(.DB_TIME(DB_TIME)) debouncer_fsm_unit(
        .clk(clk),
        .reset_n(reset_n),
        .sw(btn),
        // Outputs
        .db_tick(btn_db_tick)
    );

    /* ~~ Send payload.mem contents when the button is pressed ~~ */

    localparam ADDR_WIDTH = 8; // 0 - 255 bytes

    logic [7:0] rom_data;
    logic [7:0] w_reg, w_next;
    logic wr_reg, wr_next;
    logic [ADDR_WIDTH-1:0] addr_reg, addr_next;

    typedef enum {idle, load} state_type;
    state_type state_reg, state_next;

    always_ff @(posedge clk, negedge reset_n) begin
        if (~reset_n) begin
            w_reg <= 0;
            wr_reg <= 1'b0;
            addr_reg <= 0;
            state_reg <= idle;
        end
        else begin
            w_reg <= w_next;
            wr_reg <= wr_next;
            addr_reg <= addr_next;
            state_reg <= state_next;
        end
    end

    always_comb begin
        // Default values:
        w_next = w_reg;
        wr_next = wr_reg;
        addr_next = addr_reg;
        state_next = state_reg;

        unique case (state_reg)
            idle:
                if (btn_db_tick)
                    state_next = load;
            load: begin
                addr_next = addr_reg + 1;
                // Since the ROM is synchronous the data is delayed by one clock cycle.
                // When the addr_reg is 1, rom_data has clocked the data for addr_reg 0.
                if (addr_reg > 0) begin
                    // End of message (0x00) found.
                    if (rom_data == 8'h00) begin
                        state_next = idle;
                        addr_next = 0;
                        wr_next = 1'b0;
                    end
                    else begin
                        wr_next = 1'b1;
                        w_next = rom_data;
                    end
                end
            end
        endcase
    end

     /* ~~ Create dual_bram_file unit ~~ */

    dual_bram_file #(.MEM_FILE("payload.mem"), .ADDR_WIDTH(ADDR_WIDTH)) dual_bram_file_unit(
        .clk(clk),
        .r_addr(addr_reg),
        .r_data(rom_data)
    );

    /* ~~ Create uart unit ~~ */

    uart uart_unit(
        .clk(clk),
        .reset_n(reset_n),
        .wr(wr_reg),
        .w_data(w_reg),
        // Outputs
        .tx(uart_rxd_out)
    );
endmodule
