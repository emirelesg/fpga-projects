//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
//Date        : Sun Mar  3 15:39:54 2024
//Host        : PC-ENRIQUE running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (clk,
    reset_n,
    rx,
    tx);
  input clk;
  input reset_n;
  input rx;
  output tx;

  wire clk;
  wire reset_n;
  wire rx;
  wire tx;

  design_1 design_1_i
       (.clk(clk),
        .reset_n(reset_n),
        .rx(rx),
        .tx(tx));
endmodule
