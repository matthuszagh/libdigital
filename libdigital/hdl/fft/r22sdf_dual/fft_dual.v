`default_nettype none

// `fft_dual.v' is a simple wrapper around fft_r22sdf.v, which allows
// us to share the twiddle factor ROMs between 2 FFTs that process
// independent data streams but run at the same time.

`include "fft_r22sdf.v"
`include "ram_single_18k.v"

module fft_dual #(
   parameter N              = 1024, /* FFT length */
   parameter INPUT_WIDTH    = 14,
   parameter TWIDDLE_WIDTH  = 10,
   // +1 comes from complex multiply, which is really 2 multiplies.
   parameter OUTPUT_WIDTH   = 25   /* ceil(log_2(N)) + INPUT_WIDTH + 1 */
) (
   input wire                            clk_i,
   input wire                            clk_3x_i,
   input wire                            rst_n,
   output wire                           sync_o, // output data ready
   // freq bin index of output data. only valid if `sync_o == 1'b1'
   output wire [N_LOG2-1:0]              data_ctr_o,
   // channel 1
   input wire signed [INPUT_WIDTH-1:0]   data1_re_i,
   input wire signed [INPUT_WIDTH-1:0]   data1_im_i,
   output wire signed [OUTPUT_WIDTH-1:0] data1_re_o,
   output wire signed [OUTPUT_WIDTH-1:0] data1_im_o,
   // channel 2
   input wire signed [INPUT_WIDTH-1:0]   data2_re_i,
   input wire signed [INPUT_WIDTH-1:0]   data2_im_i,
   output wire signed [OUTPUT_WIDTH-1:0] data2_re_o,
   output wire signed [OUTPUT_WIDTH-1:0] data2_im_o
);

   localparam N_LOG2 = $clog2(N);
   localparam N_STAGES = N_LOG2/2;

   wire [N_LOG2-1:0]                    stage1_ctr_wm;
   wire [N_LOG2-1:0]                    stage2_ctr_wm;
   wire [N_LOG2-1:0]                    stage3_ctr_wm;
   wire [N_LOG2-1:0]                    stage4_ctr_wm;

   wire signed [TWIDDLE_WIDTH-1:0]      w_s0_re;
   ram_single_18k #(
      .INITFILE      ("roms/fft_r22sdf_rom_s0_re.hex"),
      .ADDRESS_WIDTH (N_LOG2),
      .DATA_WIDTH    (TWIDDLE_WIDTH)
   ) rom_w_s0_re (
      .clk    (clk_i),
      .en     (1'b1),
      .we     (1'b0),
      .addr   (stage1_ctr_wm),
      .data_o (w_s0_re)
   );

   wire signed [TWIDDLE_WIDTH-1:0]      w_s0_im;
   ram_single_18k #(
      .INITFILE      ("roms/fft_r22sdf_rom_s0_im.hex"),
      .ADDRESS_WIDTH (N_LOG2),
      .DATA_WIDTH    (TWIDDLE_WIDTH)
   ) rom_w_s0_im (
      .clk    (clk_i),
      .en     (1'b1),
      .we     (1'b0),
      .addr   (stage1_ctr_wm),
      .data_o (w_s0_im)
   );

   wire signed [TWIDDLE_WIDTH-1:0]      w_s1_re;
   ram_single_18k #(
      .INITFILE      ("roms/fft_r22sdf_rom_s1_re.hex"),
      .ADDRESS_WIDTH (N_LOG2-1),
      .DATA_WIDTH    (TWIDDLE_WIDTH)
   ) rom_w_s1_re (
      .clk    (clk_i),
      .en     (1'b1),
      .we     (1'b0),
      .addr   (stage2_ctr_wm[N_LOG2-3:0]),
      .data_o (w_s1_re)
   );

   wire signed [TWIDDLE_WIDTH-1:0]      w_s1_im;
   ram_single_18k #(
      .INITFILE      ("roms/fft_r22sdf_rom_s1_im.hex"),
      .ADDRESS_WIDTH (N_LOG2-1),
      .DATA_WIDTH    (TWIDDLE_WIDTH)
   ) rom_w_s1_im (
      .clk    (clk_i),
      .en     (1'b1),
      .we     (1'b0),
      .addr   (stage2_ctr_wm[N_LOG2-3:0]),
      .data_o (w_s1_im)
   );

   wire signed [TWIDDLE_WIDTH-1:0]      w_s2_re;
   ram_single_18k #(
      .INITFILE      ("roms/fft_r22sdf_rom_s2_re.hex"),
      .ADDRESS_WIDTH (N_LOG2-2),
      .DATA_WIDTH    (TWIDDLE_WIDTH)
   ) rom_w_s2_re (
      .clk    (clk_i),
      .en     (1'b1),
      .we     (1'b0),
      .addr   (stage3_ctr_wm[N_LOG2-5:0]),
      .data_o (w_s2_re)
   );

   wire signed [TWIDDLE_WIDTH-1:0]      w_s2_im;
   ram_single_18k #(
      .INITFILE      ("roms/fft_r22sdf_rom_s2_im.hex"),
      .ADDRESS_WIDTH (N_LOG2-2),
      .DATA_WIDTH    (TWIDDLE_WIDTH)
   ) rom_w_s2_im (
      .clk    (clk_i),
      .en     (1'b1),
      .we     (1'b0),
      .addr   (stage3_ctr_wm[N_LOG2-5:0]),
      .data_o (w_s2_im)
   );

   wire signed [TWIDDLE_WIDTH-1:0]      w_s3_re;
   ram_single_18k #(
      .INITFILE      ("roms/fft_r22sdf_rom_s3_re.hex"),
      .ADDRESS_WIDTH (N_LOG2-3),
      .DATA_WIDTH    (TWIDDLE_WIDTH)
   ) rom_w_s3_re (
      .clk    (clk_i),
      .en     (1'b1),
      .we     (1'b0),
      .addr   (stage4_ctr_wm[N_LOG2-7:0]),
      .data_o (w_s3_re)
   );

   wire signed [TWIDDLE_WIDTH-1:0]      w_s3_im;
   ram_single_18k #(
      .INITFILE      ("roms/fft_r22sdf_rom_s3_im.hex"),
      .ADDRESS_WIDTH (N_LOG2-3),
      .DATA_WIDTH    (TWIDDLE_WIDTH)
   ) rom_w_s3_im (
      .clk    (clk_i),
      .en     (1'b1),
      .we     (1'b0),
      .addr   (stage4_ctr_wm[N_LOG2-7:0]),
      .data_o (w_s3_im)
   );

   fft_r22sdf #(
      .N             (N),
      .INPUT_WIDTH   (INPUT_WIDTH),
      .TWIDDLE_WIDTH (TWIDDLE_WIDTH),
      .OUTPUT_WIDTH  (OUTPUT_WIDTH)
   ) fft1 (
      .clk_i         (clk_i),
      .clk_3x_i      (clk_3x_i),
      .rst_n         (rst_n),
      .sync_o        (sync_o),
      .data_ctr_o    (data_ctr_o),
      .data_re_i     (data1_re_i),
      .data_im_i     (data1_im_i),
      .data_re_o     (data1_re_o),
      .data_im_o     (data1_im_o),
      .w_s0_re       (w_s0_re),
      .w_s0_im       (w_s0_im),
      .w_s1_re       (w_s1_re),
      .w_s1_im       (w_s1_im),
      .w_s2_re       (w_s2_re),
      .w_s2_im       (w_s2_im),
      .w_s3_re       (w_s3_re),
      .w_s3_im       (w_s3_im),
      .stage1_ctr_wm (stage1_ctr_wm),
      .stage2_ctr_wm (stage2_ctr_wm),
      .stage3_ctr_wm (stage3_ctr_wm),
      .stage4_ctr_wm (stage4_ctr_wm)
   );

   fft_r22sdf #(
      .N             (N),
      .INPUT_WIDTH   (INPUT_WIDTH),
      .TWIDDLE_WIDTH (TWIDDLE_WIDTH),
      .OUTPUT_WIDTH  (OUTPUT_WIDTH)
   ) fft2 (
      .clk_i         (clk_i),
      .clk_3x_i      (clk_3x_i),
      .rst_n         (rst_n),
      .data_re_i     (data2_re_i),
      .data_im_i     (data2_im_i),
      .data_re_o     (data2_re_o),
      .data_im_o     (data2_im_o),
      .w_s0_re       (w_s0_re),
      .w_s0_im       (w_s0_im),
      .w_s1_re       (w_s1_re),
      .w_s1_im       (w_s1_im),
      .w_s2_re       (w_s2_re),
      .w_s2_im       (w_s2_im),
      .w_s3_re       (w_s3_re),
      .w_s3_im       (w_s3_im)
   );

endmodule

`ifdef FFT_SIMULATE

`include "fft_r22sdf_defines.vh"
`include "PLLE2_BASE.v"
`include "PLLE2_ADV.v"
`include "BRAM_SINGLE_MACRO.v"
`include "BRAM_SDP_MACRO.v"
`include "RAMB18E1.v"
`include "DSP48E1.v"
`include "glbl.v"

`timescale 1ns/1ps
module fft_dual_tb #( `FFT_PARAMS );

   reg                             clk = 0;
   reg [INPUT_WIDTH-1:0]           samples [0:N-1];
   wire [INPUT_WIDTH-1:0]          data_i;
   wire                            sync;
   wire [N_LOG2-1:0]               data_cnt;
   wire [OUTPUT_WIDTH-1:0]         data1_re_o;
   wire [OUTPUT_WIDTH-1:0]         data1_im_o;
   wire [OUTPUT_WIDTH-1:0]         data2_re_o;
   wire [OUTPUT_WIDTH-1:0]         data2_im_o;
   reg [N_LOG2-1:0]                cnt;

   assign data_i = samples[cnt];

   integer                         idx;
   initial begin
      $dumpfile("tb/fft_dual_tb.vcd");
      $dumpvars(0, fft_dual_tb);

      $readmemh("tb/fft_samples_1024.hex", samples);
      cnt = 0;

      #120000 $finish;
   end

   always #12.5 clk = !clk;

   always @(posedge clk) begin
      if (pll_lock) begin
         if (cnt == N) begin
            cnt <= cnt;
         end
         else begin
            cnt <= cnt + 1;
         end
      end else begin
         cnt <= 0;
      end
   end

   wire clk_120mhz;
   wire pll_lock;
   wire clk_fb;

   PLLE2_BASE #(
      .CLKFBOUT_MULT  (24),
      .DIVCLK_DIVIDE  (1),
      .CLKOUT0_DIVIDE (8),
      .CLKIN1_PERIOD  (25)
   ) PLLE2_BASE_120mhz (
      .CLKOUT0  (clk_120mhz),
      .LOCKED   (pll_lock),
      .CLKIN1   (clk),
      .RST      (1'b0),
      .CLKFBOUT (clk_fb),
      .CLKFBIN  (clk_fb)
   );

   fft_dual #(
      .N              (N),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TWIDDLE_WIDTH  (TWIDDLE_WIDTH),
      .OUTPUT_WIDTH   (OUTPUT_WIDTH)
   ) dut (
      .clk_i      (clk),
      .clk_3x_i   (clk_120mhz),
      .rst_n      (pll_lock),
      .sync_o     (sync),
      .data_ctr_o (data_cnt),
      .data1_re_i ($signed(data_i)),
      .data1_im_i ({INPUT_WIDTH{1'b0}}),
      .data1_re_o (data1_re_o),
      .data1_im_o (data1_im_o),
      .data2_re_i ($signed(data_i)),
      .data2_im_i ({INPUT_WIDTH{1'b0}}),
      .data2_re_o (data2_re_o),
      .data2_im_o (data2_im_o)
   );

endmodule
`endif
// flycheck-verilator-include-path:("/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/unimacro/"
//                                  "/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/"
//                                  "/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/unisims/"
//                                  "/home/matt/src/libdigital/libdigital/hdl/memory/ram/"
//                                  "/home/matt/src/libdigital/libdigital/hdl/memory/shift_reg/"
//                                  "/home/matt/src/libdigital/libdigital/hdl/dsp/multiply_add/")
// End:
