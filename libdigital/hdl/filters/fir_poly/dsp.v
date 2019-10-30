`ifndef _DSP_V_
`define _DSP_V_
`default_nettype none

module dsp #(
   // The default parameter values specify the maximum bit widths for
   // these ports.
   parameter A_DATA_WIDTH = 25,
   parameter B_DATA_WIDTH = 18,
   parameter P_DATA_WIDTH = 48
) (
   input wire                           clk,
   // whether to add new product to old product. 1'b0 is no, 1'b1 is
   // yes.
   input wire                           acc,
   input wire signed [A_DATA_WIDTH-1:0] a, // 25-bit multiply input
   input wire signed [B_DATA_WIDTH-1:0] b, // 18-bit multiply input
   output reg signed [P_DATA_WIDTH-1:0] p  // multiply(-accumulate) output
);

   always @(posedge clk) begin
      if (acc) begin
         p <= (a * b) + p;
      end else begin
         p <= a * b;
      end
   end

endmodule

`ifdef SIMULATION
`include "DSP48E1.v"
`include "glbl.v"

`timescale 1ns/1ps
module dsp_tb;

   localparam A_DATA_WIDTH = 25;
   localparam B_DATA_WIDTH = 18;
   localparam P_DATA_WIDTH = 48;

   reg clk = 1'b0;
   reg acc = 1'b0;

   // wait for POR to go low.
   always #1 clk = !clk;

   initial begin
      $dumpfile("dsp.vcd");
      $dumpvars(0, dsp_tb);
      // wait for POR
      #100 acc = 1'b0;
      #25 acc = 1'b1;
      #100 $finish;
   end

   reg signed [A_DATA_WIDTH-1:0] a = {A_DATA_WIDTH{1'b0}};
   reg signed [B_DATA_WIDTH-1:0] b = {1'b1, {B_DATA_WIDTH-1{1'b0}}};
   wire signed [P_DATA_WIDTH-1:0] p;

   always @(posedge clk) begin
      if (!dut.DSP48E1.gsr_in) begin
         a <= a + 1'b1;
         b <= b + 1'b1;
      end
   end

   dsp dut (
      .clk (clk),
      .acc   (acc),
      .a     (a),
      .b     (b),
      .p     (p)
   );

endmodule // dsp_tb
`endif
`endif
