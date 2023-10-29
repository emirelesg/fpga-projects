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
 
    // ~~ Create debouncer_fsm unit ~~ //

    logic btn_db;

    debouncer_fsm #(.DB_TIME(DB_TIME)) debouncer_fsm_unit(
        .clk(clk),
        .reset_n(reset_n),
        .sw(btn),
        .db(btn_db)
    );
    
    // ~~ Debounced button press counter ~~ //

    logic [3:0] q_reg, q_next;
    logic btn_reg, btn_next;

    always_ff @(posedge clk, negedge reset_n)
    begin
        if (~reset_n) begin
            q_reg <= 0;
            btn_reg <= 0;
        end
        else begin
            q_reg <= q_next;
            btn_reg <= btn_next;
        end
    end
 
    assign btn_next = btn_db;
    assign btn_tick = ~btn_reg && btn_next;
    assign q_next = (btn_tick) ? q_reg + 1 : q_reg;
    
    // ~~ Assignment of outputs ~~ //
 
    assign led = q_reg;
endmodule