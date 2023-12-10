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

    localparam N_BYTES = 13; // Number of bytes to send.
    localparam ADDR_WIDTH = $clog2(N_BYTES);

    logic wr;
    logic [7:0] w_data;

    typedef enum {idle, load} state_type;

    logic [ADDR_WIDTH-1:0] addr_reg, addr_next;
    state_type state_reg, state_next;

    always_ff @(posedge clk, negedge reset_n) begin
        if (~reset_n) begin
            addr_reg <= 0;
            state_reg <= idle;
        end
        else begin
            addr_reg <= addr_next;
            state_reg <= state_next;
        end
    end

    always_comb begin
        // Default values:
        addr_next = addr_reg;
        state_next = state_reg;

        unique case (state_reg)
            idle:
                if (btn_db_tick)
                    state_next = load;
                else
                    addr_next = 0;
            load:
                if (addr_reg == N_BYTES - 1)
                    state_next = idle;
                else
                    addr_next = addr_reg + 1;
        endcase
    end

    assign wr = addr_reg > 0; // Write bytes to FIFO while loading.

     /* ~~ Create dual_bram_file unit ~~ */

    dual_bram_file #(.MEM_FILE("payload.mem"), .ADDR_WIDTH(ADDR_WIDTH)) dual_bram_file_unit(
        .clk(clk),
        .r_addr(addr_reg),
        .r_data(w_data)
    );

    /* ~~ Create uart unit ~~ */

    uart uart_unit(
        .clk(clk),
        .reset_n(reset_n),
        .wr(wr),
        .w_data(w_data),
        // Outputs
        .tx(uart_rxd_out)
    );
endmodule
