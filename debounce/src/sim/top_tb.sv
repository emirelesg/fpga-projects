`timescale 1ns / 10ps

module top_tp;
    localparam T=10; // 100 Mhz, 10 ns
    logic clk;
    logic reset_n;
    logic btn;
    logic [3:0] led;

    top uut(
        .clk(clk),
        .reset_n(reset_n),
        .btn(btn),
        .led(led)
    );
    
    // Simulate a 100 Mhz clock signal.
    always begin
        clk = 1'b0;
        #(T/2);
        clk = 1'b1;
        #(T/2);
    end

    // Reset at the start of the simulation.
    initial begin
        btn = 1'b0;
        reset_n = 1'b0;
        #(T/2);
        reset_n = 1'b1;
        #(T);
        
        btn = 1'b1;
        #(T*5);
        btn = 1'b0;
        #(T);
        
        btn = 1'b1;
        #(T*5);
        btn = 1'b0;
        #(T);
        
        $stop;
    end
endmodule