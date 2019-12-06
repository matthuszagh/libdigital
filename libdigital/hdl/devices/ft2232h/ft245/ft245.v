`ifndef _FT245_V_
`define _FT245_V_

`default_nettype none
`timescale 1ns/1ps

/** ft245.v
 *
 * An interface for using the FT2232H chip in FT245 synchronous FIFO
 * mode.
 */

`include "async_fifo.v"
`include "pll_sync_ctr.v"

module ft245 #(
   // The FIFO is used to buffer write data when the FT2232H's
   // internal buffer is full. It also prevents CDC issues since `clk'
   // and `ft_clk' are asynchronous.
   parameter WRITE_DEPTH  = 1024,
   // A FIFO used to buffer read data from FT2232H to FPGA.
   parameter READ_DEPTH   = 512,
   // The number of bits a payload (does not include header/tail and
   // other bits).
   parameter DATA_WIDTH   = 47,
   // Duplicate all transmission bytes as a form of error
   // detection. Although inefficient, this is effective at avoiding
   // data errors caused by the host PC missing bytes while reading.
   parameter DUPLICATE_TX = 1
) (
   // ======================== FPGA interface ========================

   // A reset signal is required to start the FIFO in a known state.
   input wire                  rst_n,
   // Synchronizes reads and writes between the FT245 and FPGA. This
   // clock does not require any known phase relation to `ft_clk'.
   input wire                  clk,
   // Pull high to write data from FPGA to FT2232H for transmission to
   // host PC.
   input wire                  wren,
   // Write data.
   input wire [DATA_WIDTH-1:0] wrdata,
   output wire                 wrfifo_full,
   output wire                 wrfifo_empty,
   // Pull high to read data from internal read FIFO. It only makes
   // sense to read data when !rdfifo_empty.
   input wire                  rden,
   output wire [7:0]           rddata,
   output wire                 rdfifo_full,
   output wire                 rdfifo_empty,

   // ========================= PC interface =========================

   // Most of these ports should be connected directly to the
   // corresponding IO ports on the FPGA.

   // Clock generated by the FT2232H and used to synchronize data
   // transfers.
   input wire                  ft_clk,
   // Synchronizes write word changes. `slow_ft_clk' * `DATA_WIDTH' /
   // 8 = `ft_clk'.
   input wire                  slow_ft_clk,
   // Low indicates there is data available to be read from the FIFO.
   input wire                  rxf_n,
   // Low indicates data can be written to the FIFO.
   input wire                  txe_n,
   // 0 makes read data from the FIFO available at the data pins.
   output reg                  rd_n,
   // Pull low to register write data from the data pins into the
   // FIFO.
   output reg                  wr_n,
   // Drive low to read data from FIFO. Must be deasserted at least 1
   // clock period (`ft_clk') before driving `rd_n' low.
   output reg                  oe_n,
   // Low when USB in suspend mode.
   /* verilator lint_off UNUSED */
   input wire                  suspend_n,
   /* verilator lint_on UNUSED */
   // Strobing low (min 250ns) sends FIFO data immediately to the host
   // PC.
   output reg                  ft_siwua_n,
   inout wire [7:0]            ft_data
);

   // number of bits in full transmission, including header/tail/meta
   // data.
   localparam FULL_WIDTH = 64;
   localparam NBYTES = FULL_WIDTH/8;
   // TODO this should be parameterized to work with different word
   // sizes.
`ifndef __ICARUS__
   if (NBYTES != 8) $error();
`endif

   localparam CTR_WIDTH = $clog2(NBYTES);

   assign ft_data = oe_n ? ft_data_reg : 8'bzzzz_zzzz;

   wire [DATA_WIDTH-1:0]        wrfifo_rddata;
   wire                         wr_fifo_rd_en;
   // Write FIFO
   /* verilator lint_off PINMISSING */
   async_fifo #(
      .WIDTH (DATA_WIDTH  ),
      .SIZE  (WRITE_DEPTH )
   ) fifo_write (
      .rst_n  (rst_n                           ),
      .full   (wrfifo_full                     ),
      .empty  (wrfifo_empty                    ),
      .rdclk  (slow_ft_clk                     ),
      /* txe_n is a guard against writes to a full buffer, since
      /* FT2232H can take up to 7.15ns to report a full buffer. */
      .rden   (oe_n && wr_fifo_rd_en && !txe_n ),
      .rddata (wrfifo_rddata                   ),
      .wrclk  (clk                             ),
      .wren   (wren && !wrfifo_full            ),
      .wrdata (wrdata                          )
   );
   /* verilator lint_on PINMISSING */

   wire [CTR_WIDTH-1:0]         ctr;
   pll_sync_ctr #(
      .RATIO (NBYTES)
   ) pll_sync_ctr (
      .fst_clk (ft_clk      ),
      .slw_clk (slow_ft_clk ),
      .rst_n   (rst_n       ),
      .ctr     (ctr         )
   );

   reg [7:0]                    ft_data_reg;
   wire [FULL_WIDTH-1:0]        wrfifo_rddata_full;

   assign wrfifo_rddata_full = {8'h80, 5'd0, wrfifo_rddata, 4'h0};

   always @(*) begin
      case (ctr)
      3'b000 : ft_data_reg = wrfifo_rddata_full[63:56];
      3'b001 : ft_data_reg = wrfifo_rddata_full[55:48];
      3'b010 : ft_data_reg = wrfifo_rddata_full[47:40];
      3'b011 : ft_data_reg = wrfifo_rddata_full[39:32];
      3'b100 : ft_data_reg = wrfifo_rddata_full[31:24];
      3'b101 : ft_data_reg = wrfifo_rddata_full[23:16];
      3'b110 : ft_data_reg = wrfifo_rddata_full[15:8];
      3'b111 : ft_data_reg = wrfifo_rddata_full[7:0];
      endcase
   end

   // Read FIFO
   async_fifo #(
     .WIDTH (8          ),
     .SIZE  (READ_DEPTH )
   ) fifo_read (
      .rst_n  (rst_n        ),
      .full   (rdfifo_full  ),
      .empty  (rdfifo_empty ),
      .rdclk  (clk          ),
      .rden   (rden         ),
      .rddata (rddata       ),
      .wrclk  (ft_clk       ),
      .wren   (!rd_n        ),
      .wrdata (ft_data      )
   );

   generate
      if (DUPLICATE_TX == 1) begin
         reg duplicate;
         always @(posedge slow_ft_clk) begin
            if (!rst_n) begin
               duplicate <= 1'b0;
            end else begin
               duplicate <= ~duplicate;
            end
         end

         assign wr_fifo_rd_en = ~duplicate;
         always @(posedge ft_clk) begin
            if (!rst_n) begin
               rd_n <= 1'b1;
               wr_n <= 1'b1;
               oe_n <= 1'b1;
               ft_siwua_n <= 1'b1;
            // favor reads
            end else if (!rxf_n) begin
               oe_n <= 1'b0;
               wr_n <= 1'b1;
               if (!oe_n) begin
                  rd_n <= 1'b0;
               end
            end else if (!txe_n) begin
               oe_n <= 1'b1;
               rd_n <= 1'b1;
               if (oe_n)
                 wr_n <= 1'b0;
            end else begin
               oe_n <= 1'b1;
               rd_n <= 1'b1;
               wr_n <= 1'b1;
            end
         end
      end else begin
         assign wr_fifo_rd_en = 1'b1;
         always @(posedge ft_clk) begin
            if (!rst_n) begin
               rd_n <= 1'b1;
               wr_n <= 1'b1;
               oe_n <= 1'b1;
               ft_siwua_n <= 1'b1;
            end else if (!rxf_n) begin
               oe_n <= 1'b0;
               wr_n <= 1'b1;
               if (!oe_n) begin
                  rd_n <= 1'b0;
               end
            end else if (!txe_n) begin
               oe_n <= 1'b1;
               rd_n <= 1'b1;
               if (oe_n)
                 wr_n <= 1'b0;
            end else begin
               oe_n <= 1'b1;
               rd_n <= 1'b1;
               wr_n <= 1'b1;
            end
         end
      end
   endgenerate

`ifdef COCOTB_SIM
   initial begin
      $dumpfile ("cocotb/build/ft245.vcd");
      $dumpvars (0, ft245);
      #1;
   end
`endif

endmodule
`endif
