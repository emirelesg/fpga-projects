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

    /* ~~ Send digits 0-9 when the button is pressed ~~ */

    localparam N_BYTES = 10; // Number of bytes to send.

    logic wr;
    logic [7:0] w_data;

    typedef enum {idle, load} state_type;

    logic [$clog2(N_BYTES)-1:0] c_reg, c_next;
    state_type state_reg, state_next;

    always_ff @(posedge clk, negedge reset_n) begin
        if (~reset_n) begin
            c_reg <= 0;
            state_reg <= idle;
        end
        else begin
            c_reg <= c_next;
            state_reg <= state_next;
        end
    end

    always_comb begin
        // Default values:
        c_next = c_reg;
        state_next = state_reg;

        unique case (state_reg)
            idle:
                if (btn_db_tick) begin
                    c_next = 0;
                    state_next = load;
                end
            load:
                if (c_reg == N_BYTES - 1)
                    state_next = idle;
                else
                    c_next = c_reg + 1;
        endcase
    end

    assign wr = state_reg == load; // Write bytes to FIFO while loading.
    assign w_data = 8'h30 | c_reg;

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
