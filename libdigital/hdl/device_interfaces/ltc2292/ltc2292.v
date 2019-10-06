`default_nettype none

// Simple interface for the LTC2292 ADC.

// TODO this module currently only supports a multiplexed output bus
// in full-range 2s complement mode. See the datasheet for details and
// other modes.

module ltc2292 #(
   parameter MUX = "TRUE"
) (
   input wire                clk,
   input wire signed [11:0]  di,
   output wire signed [11:0] dao,
   output wire signed [11:0] dbo
);

   // When the ADC outputs are multiplexed, channel A should be
   // sampled on the clock's falling edge and channel B sampled on the
   // clock's rising edge.

   reg signed [11:0]         abuf;

   always @(posedge clk) begin
      dao <= abuf;
      dbo <= di;
   end

   always @(negedge clk) begin
      abuf <= dao;
   end

endmodule
