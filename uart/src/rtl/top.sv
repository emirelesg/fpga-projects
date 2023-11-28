module top
    (
        input logic clk,
        input logic reset_n,
        input logic btn,
        input logic [3:0] sw,
        input logic uart_txd_in,
        output logic uart_rxd_out
    );

    logic [7:0] tx_data = 8'h30 | sw; // 0 -> ? in ASCII

    /* ~~ Create debouncer_fsm unit ~~ */

    logic btn_db_tick;

    debouncer_fsm #(.DB_TIME(0.05)) debouncer_fsm_unit(
        .clk(clk),
        .reset_n(reset_n),
        .sw(btn),
        .db_tick(btn_db_tick)
    );

    /* ~~ Create uart unit ~~ */

    uart uart_unit(
        .clk(clk),
        .reset_n(reset_n),
        .tx_start(btn_db_tick),
        .tx_data(tx_data),
        .tx(uart_rxd_out)
    );
endmodule
