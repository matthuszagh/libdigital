`ifndef _shift_reg_v_
`define _shift_reg_v_
`default_nettype none

// Uses an 18k FIFO (via onboard block RAM) to implement a shift
// register. Note that this module only supports reading from the end
// of the shift register due to the fact that it's based on dual-port
// RAM. If you need to read from more than just the last register,
// implement the shift register with flip-flops.

module shift_reg #(
   parameter DATA_WIDTH = 25,
   parameter LEN        = 512
) (
   input wire                   clk,
   input wire                   rst_n,
   input wire [DATA_WIDTH-1:0]  di,
   output wire [DATA_WIDTH-1:0] data_o
);

   // TODO These should really be conditional on the chosen parameter
   // values. However, verilog does not allow putting these in a
   // generate block. Currently, they must be modified by hand until a
   // better solution is found.
   localparam ADDR_WIDTH = 9;
   localparam WE_REPLICATE = 4;

   localparam LEN_LOG2 = $clog2(LEN);
   localparam ADDR_PADDING = ADDR_WIDTH - LEN_LOG2;

   reg [LEN_LOG2-1:0]           addr;

   always @(posedge clk) begin
      if (!rst_n)
         addr <= {LEN_LOG2{1'b0}};
      else
         addr <= addr + 1'b1;
   end

   BRAM_SDP_MACRO #(
      .BRAM_SIZE   ("18Kb"),
      .DEVICE      ("7SERIES"),
      .DO_REG      (0),          // don't pipeline output
      .READ_WIDTH  (DATA_WIDTH),
      .WRITE_WIDTH (DATA_WIDTH),
      .WRITE_MODE  ("WRITE_FIRST")
   ) BRAM_SDP (
      .DO     (data_o),
      .DI     (di),
      .WRADDR ({{ADDR_PADDING{1'b0}}, addr}),
      .RDADDR ({{ADDR_PADDING{1'b0}}, addr+1'b1}),
      .WE     ({WE_REPLICATE{rst_n}}),
      .WREN   (rst_n),
      .RDEN   (rst_n),
      .RST    (!rst_n),
      .WRCLK  (clk),
      .RDCLK  (clk)
   );

endmodule

`ifdef SHIFT_REG_SIMULATE
`include "BRAM_SDP_MACRO.v"
`include "RAMB18E1.v"
`include "glbl.v"
`timescale 1ns/1ps
module shift_reg_tb;

   localparam DATA_WIDTH = 25;
   localparam LEN = 10;

   reg clk = 0;
   reg rst_n = 0;
   always #1 clk = !clk;
   reg [DATA_WIDTH-1:0] sample = 0;
   wire [DATA_WIDTH-1:0] data;

   always @(posedge clk) begin
      if (!dut.BRAM_SDP.bram18_sdp_bl_3.bram18_sdp_bl_3.GSR)
        rst_n <= 1;

      if (!rst_n)
        sample <= 0;
      else
        sample <= sample + 1;
   end

   initial begin
      $dumpfile("tb/shift_reg_tb.vcd");
      $dumpvars(0, shift_reg_tb);

      #10000 $finish;
   end

   shift_reg #(
      .DATA_WIDTH (DATA_WIDTH),
      .LEN        (LEN)
   ) dut (
      .clk      (clk),
      .rst_n    (rst_n),
      .di       (sample),
      .data_o   (data)
   );

endmodule
`endif
`endif
