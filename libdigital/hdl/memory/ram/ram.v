`default_nettype none

`ifndef _RAM_V_
`define _RAM_V_
module ram #(
   parameter WIDTH = 64,
   parameter SIZE  = 512
) (
   input wire             rdclk,
   input wire             rden,
   input wire [ABITS-1:0] rdaddr,
   output reg [WIDTH-1:0] rddata,
   input wire             wrclk,
   input wire             wren,
   input wire [ABITS-1:0] wraddr,
   input wire [WIDTH-1:0] wrdata
);

   localparam ABITS = $clog2(SIZE);

   reg [WIDTH-1:0]        mem [0:SIZE-1];
   wire                   conflict = (rden && wren) ? (rdaddr == wraddr) : 1'b0;

   always @(posedge rdclk) begin
      if (rden) begin
         rddata <= mem[rdaddr];
      end
   end

   // Prioritize reads when read/write conflicts occur.
   always @(posedge wrclk) begin
      if (wren && !conflict) begin
         mem[wraddr] <= wrdata;
      end
   end

`ifdef FORMAL
   // TODO
`endif

endmodule
`endif
