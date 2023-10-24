module debouncer
    (
        input logic clk,
        input logic reset_n,
        input logic sw,
        output logic db
    );

    // Assignment of outputs

    assign db = sw;
endmodule