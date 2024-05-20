`ifndef _I2S_MAP_INCLUDED
`define _I2S_MAP_INCLUDED

`define MCLK_LRCLK_RATIO 128
`define SCLK_LRCLK_RATIO 64
`define DATA_BIT 16

function signed [15:0] clamp_16(input logic [16:0] x);
    unique case (x[16:15])
        2'b10:    clamp_16 = -32768;
        2'b01:    clamp_16 =  32767;
        default:  clamp_16 =  x[15:0];
    endcase
endfunction

function signed [15:0] trim_mul_16(input logic signed [31:0] x);
    trim_mul_16 = x[29:14];
endfunction

`endif
