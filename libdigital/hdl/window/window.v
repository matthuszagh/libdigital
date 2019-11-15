`ifndef _WINDOW_V_
`define _WINDOW_V_

`default_nettype none
`timescale 1ns/1ps

module window #(
   parameter N           = 1024,
   parameter DATA_WIDTH  = 14,
   parameter COEFF_WIDTH = 10
) (
   input wire                         clk,
   input wire                         en,
   input wire signed [DATA_WIDTH-1:0] di,
   output reg signed [DATA_WIDTH-1:0] dout
);

   localparam INTERNAL_WIDTH = DATA_WIDTH + COEFF_WIDTH;

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

   always @(posedge clk) begin
      if (en) begin
         internal <= di * coeffs[ctr];
         dout     <= trunc_to_out(round_convergent(internal));
         if (ctr == N-1) begin
            ctr <= {$clog2(N){1'b0}};
         end else begin
            ctr   <= ctr + 1'b1;
         end
      end else begin
         ctr <= {$clog2(N){1'b0}};
      end
   end

endmodule
`endif /* _WINDOW_V_ */