`default_nettype none

/** ft2232h.v
 *
 * This module simulates the interface behavior of a FT2232H. It is
 * meant for testbenching interfacing modules and is therefore not
 * intended to replicate the internal implementation of the device.
 *
 * TODO this currently only emulates FT245 synchronous FIFO mode.
 */

`include "sync_fifo.v"

module ft2232h (
   // Abstracted host PC interface
   // Use reset to initialize FIFO.
   input wire       tb_rst_n,
   // Must generate externally since verilator can't simulate a clock
   // in verilog.
   input wire       tb_clk,
   inout wire [7:0] usb_data,
   // PC pulls high to write to FT2232H. When a conflict between a
   // read and write occurs, the write is prioritized.
   input wire       usb_wr,
   // PC pulls high to read
   input wire       usb_rd,

   // actual ports
   output wire      clk,
   output wire      rxf_n,
   output wire      txe_n,
   input wire       rd_n,
   input wire       wr_n,
   input wire       oe_n,
   output wire      suspend_n,
   // TODO implement
   /* verilator lint_off UNUSED */
   input wire       siwua_n,
   /* verilator lint_on UNUSED */
   inout wire [7:0] data
);

   assign clk = tb_clk;
   // TODO implement.
   assign suspend_n = 1'b1;

   wire             tx_fifo_full;
   wire [7:0]       tx_fifo_data;

   wire             usb_rden = !usb_wr && usb_rd;

   assign usb_data = usb_rden ? tx_fifo_data : {8{1'bz}};
   assign txe_n    = !tx_fifo_full ? 1'b0 : 1'b1;

   // Data bound for transmission to host PC
   /* verilator lint_off PINMISSING */
   sync_fifo #(
      .WIDTH (8),
      .SIZE  (4000)
   ) tx_fifo (
      .rst_n  (tb_rst_n),
      .full   (tx_fifo_full),
      .clk    (clk),
      .rden   (usb_rd),
      .rddata (tx_fifo_data),
      // Don't provide safeguards against reading/writing from/to FIFO
      // simultaneously. Assume FT2232H will honor this and leave it
      // to interface module to detect simultaneous read/write
      // conflicts.
      .wren   (!wr_n),
      .wrdata (data)
   );
   /* verilator lint_on PINMISSING */

   wire             rx_fifo_empty;
   wire [7:0]       rx_fifo_data;

   assign data = !oe_n ? rx_fifo_data : {8{1'bz}};
   assign rxf_n = !rx_fifo_empty ? 1'b0 : 1'b1;

   // Data from PC bound for FPGA/ASIC
   /* verilator lint_off PINMISSING */
   sync_fifo #(
      .WIDTH (8),
      .SIZE  (4000)
   ) rx_fifo (
      .rst_n  (tb_rst_n),
      .empty  (rx_fifo_empty),
      .clk    (clk),
      .rden   (!rd_n && !usb_wr),
      .rddata (rx_fifo_data),
      .wren   (usb_wr),
      .wrdata (usb_data)
   );
   /* verilator lint_on PINMISSING */

endmodule
