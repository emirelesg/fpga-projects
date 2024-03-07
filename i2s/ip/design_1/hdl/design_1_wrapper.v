//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
//Date        : Thu Mar  7 17:36:19 2024
//Host        : PC-ENRIQUE running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (clk,
    clk_i2s,
    reset_n);
  input clk;
  output clk_i2s;
  input reset_n;

  wire clk;
  wire clk_i2s;
  wire reset_n;

  design_1 design_1_i
       (.clk(clk),
        .clk_i2s(clk_i2s),
        .reset_n(reset_n));
endmodule
