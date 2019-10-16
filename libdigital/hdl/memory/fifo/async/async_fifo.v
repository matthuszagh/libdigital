`default_nettype none

`include "ram.v"

/** async_fifo.v
 *
 * Asynchronous FIFO. This expects to be started in its reset state.
 */

module async_fifo #(
   parameter WIDTH = 64,
   parameter SIZE  = 1024
) (
   input wire              rst_n,
   output reg              full,
   output wire             empty,
   input wire              rdclk,
   input wire              rden,
   output wire [WIDTH-1:0] rddata,
   input wire              wrclk,
   input wire              wren,
   input wire [WIDTH-1:0]  wrdata
);

   localparam ABITS = $clog2(SIZE);

   reg [ABITS-1:0]         rdaddr;
   reg [ABITS-1:0]         wraddr;

   assign empty = (rdaddr == wraddr);

   always @(posedge rdclk) begin
      if (!rst_n) begin
         rdaddr <= {ABITS{1'b0}};
      end else if (rden && rdaddr != wraddr) begin
         rdaddr <= rdaddr + 1'b1;
      end
   end

   always @(posedge wrclk) begin
      if (!rst_n) begin
         wraddr <= {ABITS{1'b0}};
      end else begin
         if (rdaddr - wraddr == {{ABITS-1{1'b0}}, 1'b1}) begin
            full <= 1'b1;
         end else begin
            full <= 1'b0;
            if (wren)
              wraddr <= wraddr + 1'b1;
         end
      end
   end

   ram #(
      .WIDTH (WIDTH),
      .SIZE  (SIZE)
   ) ram (
      .rdclk  (rdclk),
      .rden   (rden),
      .rdaddr (rdaddr),
      .rddata (rddata),
      .wrclk  (wrclk),
      .wren   (wren),
      .wraddr (wraddr),
      .wrdata (wrdata)
   );

`ifdef FORMAL
   // TODO
`endif

endmodule

`ifdef ASYNC_FIFO_SIMULATE
`timescale 1ns/1ps
module async_fifo_tb;

   localparam DATA_WIDTH = 64;

   reg wrclk = 0;
   reg rdclk = 0;

   reg rden = 0;
   reg wren = 1;
   reg rst_n = 0;

   reg [DATA_WIDTH-1:0] data = 0;

   always #3 wrclk = !wrclk;
   always #5 rdclk = !rdclk;

   always #500 rden = ~rden;

   initial begin
      $dumpfile("tb/async_fifo_tb.vcd");
      $dumpvars(0, async_fifo_tb);

      #100 rst_n = 1;
      #10000 wren = 0;
      #20000 $finish;
   end

   always @(posedge wrclk) begin
      if (!rst_n) begin
         data <= 0;
      end else if (wren) begin
         data <= data + 1'b1;
      end
   end

   wire full;
   wire empty;
   wire [DATA_WIDTH-1:0] rd_data;

   async_fifo #(
      .WIDTH (DATA_WIDTH),
      .SIZE  (512)
   ) dut (
      .wrclk  (wrclk),
      .rdclk  (rdclk),
      .rst_n  (rst_n),
      .rden   (rden),
      .wren   (wren),
      .full   (full),
      .empty  (empty),
      .rddata (rd_data),
      .wrdata (data)
   );

endmodule
`endif
