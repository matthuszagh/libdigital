`ifndef _PARITY_V_
`define _PARITY_V_
`default_nettype none

// Generates an even parity bit.

module parity #(
   parameter DATA_WIDTH = 8
) (
   input wire [DATA_WIDTH-1:0] di,
   output wire                 par
);

   function parity_gen (input [DATA_WIDTH-1:0] in);
      integer                  i;
      begin
         parity_gen = 0;
         for (i=0; i<DATA_WIDTH; i++) begin
            parity_gen = parity_gen^in[i];
         end
      end
   endfunction

   assign par = parity_gen(di);

endmodule

`ifdef PARITY_SIMULATE
`timescale 1ns/1ps
module parity_tb;

   localparam DATA_WIDTH = 15;

   reg signed [DATA_WIDTH-1:0] di = 0;
   reg clk = 0;
   wire par;

   always #1 clk = !clk;

   initial begin
      $dumpfile("tb/parity_tb.vcd");
      $dumpvars(0, parity_tb);

      #100 $finish;
   end

   always @(posedge clk) begin
      di <= di + 1;
   end

   parity #(
      .DATA_WIDTH (DATA_WIDTH)
   ) dut (
      .di  (di),
      .par (par)
   );

endmodule
`endif
`endif
