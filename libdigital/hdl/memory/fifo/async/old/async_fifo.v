`default_nettype none

/** async_fifo.v
 *
 * Implements an asynchronous FIFO of user-specified data width up to
 * 72 bits. The FIFO depth is fixed at 512 words. When collisions
 * between a read and write occur, the read is prioritized.
 */

module async_fifo #(
   parameter DATA_WIDTH = 64
) (
   // Read clock.
   input wire                   clk_rd,
   // Write clock.
   input wire                   clk_wr,
   input wire                   rst_n,
   // Read enable. Pull high to read from the FIFO.
   input wire                   rd_en,
   // Write enable. Pull high to write to the FIFO. This only has an
   // effect if it would not cause a collision and `full' is
   // deasserted.
   input wire                   wr_en,
   // 1 indicates FIFO is full.
   output reg                   full,
   // Write data.
   input wire [DATA_WIDTH-1:0]  d_wr,
   // Read data.
   output wire [DATA_WIDTH-1:0] d_rd
);

   localparam ADDR_WIDTH = 9;

   reg [ADDR_WIDTH-1:0]         addr_rd;
   reg [ADDR_WIDTH-1:0]         addr_wr;

   wire                         we = ((wr_en && rd_en && (addr_rd == addr_wr)) || full) ? 1'b0 : wr_en;

   BRAM_SDP_MACRO #(
      .BRAM_SIZE   ("36Kb"),
      .DEVICE      ("7SERIES"),
      .DO_REG      (0),
      .READ_WIDTH  (DATA_WIDTH),
      .WRITE_WIDTH (DATA_WIDTH),
      .WRITE_MODE  ("WRITE_FIRST")
   ) BRAM_SDP (
      .DI     (d_wr),
      .DO     (d_rd),
      .WRADDR (addr_wr),
      .RDADDR (addr_rd),
      .WE     (8'hff),
      .WREN   (we),
      .RDEN   (rd_en),
      .RST    (1'b0),
      .WRCLK  (clk_wr),
      .RDCLK  (clk_rd)
   );

   always @(posedge clk_wr) begin
      if (!rst_n) begin
         addr_wr <= {ADDR_WIDTH{1'b0}};
         full <= 1'b0;
      end else if (we) begin
         if (addr_wr - addr_rd == 511) begin
            full <= 1'b1;
         end else begin
            full <= 1'b0;
            addr_wr <= addr_wr + 1'b1;
         end
      end
   end

   always @(posedge clk_rd) begin
      if (!rst_n) begin
         addr_rd <= {ADDR_WIDTH{1'b0}};
      end else if (rd_en) begin
         addr_rd <= addr_rd + 1'b1;
      end
   end

endmodule

`ifdef ASYNC_FIFO_SIMULATE
`include "BRAM_SDP_MACRO.v"
`include "RAMB36E1.v"
`include "glbl.v"

`timescale 1ns/1ps
module async_fifo_tb;

   localparam DATA_WIDTH = 64;

   reg clk_wr = 0;
   reg clk_rd = 0;

   reg rd_en = 0;
   reg wr_en = 1;
   reg rst_n = 0;

   reg [DATA_WIDTH-1:0] data = 0;

   always #3 clk_wr = !clk_wr;
   always #5 clk_rd = !clk_rd;

   initial begin
      $dumpfile("tb/async_fifo_tb.vcd");
      $dumpvars(0, async_fifo_tb);

      #100 rst_n = 1;

      #300 rd_en = 1;
      #500 wr_en = 0;

      #10000 $finish;
   end

   always @(posedge clk_wr) begin
      if (!rst_n) begin
         data <= 0;
      end else if (wr_en) begin
         data <= data + 1'b1;
      end
   end

   wire full;
   wire [DATA_WIDTH-1:0] rd_data;

   async_fifo #(
      .DATA_WIDTH (DATA_WIDTH)
   ) dut (
      .clk_wr (clk_wr),
      .clk_rd (clk_rd),
      .rst_n  (rst_n),
      .rd_en  (rd_en),
      .wr_en  (wr_en),
      .full   (full),
      .d_wr   (data),
      .d_rd   (rd_data)
   );

endmodule
`endif
