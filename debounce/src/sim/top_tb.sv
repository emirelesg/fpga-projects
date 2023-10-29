`timescale 1ns / 10ps

module top_tp;
    localparam T=10; // 100 Mhz, 10 ns
    localparam DB_TIME=0.000005; // 5 us
    logic clk;
    logic reset_n;
    logic btn;
    logic [3:0] led;

    top #(.DB_TIME(DB_TIME)) uut(
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
        reset_n = 1'b0;
        #(T/2);
        reset_n = 1'b1;
        #(T);
    end
 
    initial begin
        btn = 1'b0;
        @(posedge reset_n); // Wait for the reset.
        @(negedge clk);
        
        repeat(10) begin
            btn = 1'b1;
            #(T*2); // 20 ns
            btn = 1'b0;
            #(T*2); // 20 ns
        end
        
        btn = 1'b1;
        wait(led == 1); // ~10 us 
        btn = 1'b0;
        
        $stop;
    end
endmodule