`timescale 1ns / 1ps

module sw_btn_led
    (
     input logic [3:0] sw, btn,
     output logic [3:0] led
    );
    
    assign led = sw ^ btn;
endmodule
