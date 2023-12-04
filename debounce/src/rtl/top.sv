module top
    #(
        parameter   DB_TIME = 0.100 // 100 ms
    )
    (
        input logic clk,
        input logic reset_n,
        input logic btn,
        output logic [3:0] led
    );

    /* ~~ Create debouncer_fsm unit ~~ */

    logic btn_db, btn_db_tick;

    debouncer_fsm #(.DB_TIME(DB_TIME)) debouncer_fsm_unit(
        .clk(clk),
        .reset_n(reset_n),
        .sw(btn),
        .db(btn_db),
        .db_tick(btn_db_tick)
    );

    /* ~~ Debounced button press counter ~~ */

    logic [3:0] q_reg, q_next;

    always_ff @(posedge clk, negedge reset_n) begin
        if (~reset_n)
            q_reg <= 0;
        else
            q_reg <= q_next;
    end

    assign q_next = (btn_db_tick) ? q_reg + 1 : q_reg;
    assign led = q_reg;
endmodule
