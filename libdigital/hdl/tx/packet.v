`default_nettype none

// packet.v creates packets of data for transmission. The packets
// consist of a start bit (1), followed by a parity bit, then the 6
// MSB bits of data, consecutive bytes of data (big endian and as many
// as needed), and a stop byte of all 0s. packet generates 8-bit
// words, and is therefore meant to be connected to an 8-bit bus
// interface.

// TODO this module is not properly generic. Presently, it only
// accepts data widths of 8 bytes (including 9 reserved for non-data)
// since Verilog makes it tricky to be properly generic. This should
// be generalized in a future revision.

// TODO should probably be pipelined for better fmax.

`include "parity.v"

module packet #(
   parameter INPUT_WIDTH = 54
) (
   input wire                   clk,
   // pull high to signal valid input data at `di'
   input wire                   en,
   input wire [INPUT_WIDTH-1:0] di,
   output wire [7:0]            data_o
);

   // Additional 1 start bit, 1 parity bit and 8 stop bits
   localparam NBYTES          = $clog2(INPUT_WIDTH+10);
   localparam CTR_WIDTH       = $clog2(NBYTES);
   localparam [0:0] START_BIT = 1'b1;
   localparam [0:0] STOP_BIT  = 1'b0;

   reg [CTR_WIDTH-1:0]          ctr;

   wire                         parity_bit;
   parity #(
      .DATA_WIDTH (INPUT_WIDTH)
   ) parity_gen (
      .di  (di),
      .par (parity_bit),
   );

   always @(posedge clk) begin
      if (en) begin
         if (ctr == NBYTES-1) begin
            ctr <= {CTR_WIDTH{1'b0}};
         end else begin
            ctr <= ctr + 1'b1;
         end
      end else begin
         ctr <= {CTR_WIDTH{1'b0}};
      end
   end

   always @(*) begin
      case (ctr)
      3'b000 : data_o = {1'b1, parity_bit, di[53:48]};
      3'b001 : data_o = di[47:40];
      3'b010 : data_o = di[39:32];
      3'b011 : data_o = di[31:24];
      3'b100 : data_o = di[23:16];
      3'b101 : data_o = di[15:8];
      3'b110 : data_o = di[7:0];
      3'b111 : data_o = {8{STOP_BIT}};
      endcase
   end

endmodule

`ifdef PACKET_SIMULATE
`timescale 1ns/1ps
module packet_tb;

   reg clk;

endmodule
`endif
