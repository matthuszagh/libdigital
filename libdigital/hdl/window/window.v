`ifndef _WINDOW_V_
`define _WINDOW_V_

`default_nettype none
`timescale 1ns/1ps

module window #(
   parameter N           = 1024,
   parameter DATA_WIDTH  = 14,
   parameter COEFF_WIDTH = 16
) (
   input wire                         clk,
   input wire                         rst_n,
   input wire                         en,
   input wire signed [DATA_WIDTH-1:0] di,
   output reg                         dvalid,
   output reg signed [DATA_WIDTH-1:0] dout
);

   localparam INTERNAL_WIDTH = DATA_WIDTH + COEFF_WIDTH;
   localparam [$clog2(N)-1:0] N_CMP = N[$clog2(N)-1:0];

   function [INTERNAL_WIDTH-1:0] round_convergent(input [INTERNAL_WIDTH-1:0] expr);
      round_convergent = expr + {{DATA_WIDTH{1'b0}},
                                 expr[INTERNAL_WIDTH-DATA_WIDTH],
                                 {INTERNAL_WIDTH-DATA_WIDTH-1{!expr[INTERNAL_WIDTH-DATA_WIDTH]}}};
   endfunction

   function [DATA_WIDTH-1:0] trunc_to_out(input [INTERNAL_WIDTH-1:0] expr);
      trunc_to_out = expr[INTERNAL_WIDTH-1:INTERNAL_WIDTH-DATA_WIDTH];
   endfunction

   reg signed [DATA_WIDTH+COEFF_WIDTH-1:0] internal;
   reg [COEFF_WIDTH-1:0]                   coeffs [0:N-1];
   reg [$clog2(N)-1:0]                     ctr;

   initial begin
      $readmemh("/home/matt/src/libdigital/libdigital/hdl/window/roms/coeffs.hex", coeffs);
   end

   reg en_buf;
   always @(posedge clk) begin
      if (!rst_n) begin
         ctr <= {$clog2(N){1'b0}};
         {dvalid, en_buf} <= {1'b0, 1'b0};
      end else if (en) begin
         {dvalid, en_buf} <= {en_buf, en};

         internal <= di * $signed({1'b0, coeffs[ctr]});
         dout <= trunc_to_out(round_convergent(internal));
         if (ctr == N_CMP-1'b1) begin
            ctr <= {$clog2(N){1'b0}};
         end else begin
            ctr <= ctr + 1'b1;
         end
      end
   end

`ifdef COCOTB_SIM
   // integer i;
   initial begin
      $dumpfile ("cocotb/build/window.vcd");
      $dumpvars (0, window);
      // for (i=0; i<100; i=i+1)
      //   $dumpvars (0, coeffs[i]);
      #1;
   end
`endif

endmodule
`endif /* _WINDOW_V_ */
