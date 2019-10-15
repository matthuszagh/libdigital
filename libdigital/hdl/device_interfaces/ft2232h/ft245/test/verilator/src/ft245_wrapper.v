`default_nettype none

`include "ft245.v"
`include "ft2232h.v"

`timescale 1ps/1ps
module ft245_wrapper (
   input wire        tb_rst_n,
   input wire        tb_ftclk,
   input wire        tb_slow_ftclk,
   input wire        clk_40mhz,
   // FPGA/ASIC side
   input wire        wren,
   input wire [63:0] wrdata,
   output wire       wrfifo_full,
   input wire        rden,
   output wire [7:0] rddata,
   output wire       rdfifo_full,
   output wire       rdfifo_empty,
   // pc side
   inout wire [7:0]  usb_data,
   input wire        usb_wr,
   input wire        usb_rd
);

   wire             ftclk;
   wire             rxf_n;
   wire             txe_n;
   wire             rd_n;
   wire             wr_n;
   wire             oe_n;
   wire             suspend_n;
   wire             siwua_n;
   // TODO why does this get an unused warning?
   /* verilator lint_off UNUSED */
   wire [7:0]       data;
   /* verilator lint_on UNUSED */

   ft2232h ft2232h (
      .tb_rst_n  (tb_rst_n),
      .tb_clk    (tb_ftclk),
      .usb_data  (usb_data),
      .usb_wr    (usb_wr),
      .usb_rd    (usb_rd),
      .clk       (ftclk),
      .rxf_n     (rxf_n),
      .txe_n     (txe_n),
      .rd_n      (rd_n),
      .wr_n      (wr_n),
      .oe_n      (oe_n),
      .suspend_n (suspend_n),
      .siwua_n   (siwua_n),
      .data      (data)
   );

   ft245 #(
      .WRITE_DEPTH  (1024),
      .READ_DEPTH   (512),
      .DATA_WIDTH   (64),
      .DUPLICATE_TX (1)
   ) ft245 (
      .rst_n        (tb_rst_n),
      .clk          (clk_40mhz),
      .wren         (wren),
      .wrdata       (wrdata),
      .wrfifo_full  (wrfifo_full),
      .rden         (rden),
      .rddata       (rddata),
      .rdfifo_full  (rdfifo_full),
      .rdfifo_empty (rdfifo_empty),
      .ft_clk       (ftclk),
      .slow_ft_clk  (tb_slow_ftclk),
      .rxf_n        (rxf_n),
      .txe_n        (txe_n),
      .rd_n         (rd_n),
      .wr_n         (wr_n),
      .oe_n         (oe_n),
      .suspend_n    (suspend_n),
      .ft_siwua_n   (siwua_n),
      .ft_data      (data)
   );

endmodule
