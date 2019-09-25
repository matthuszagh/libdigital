`default_nettype none

`include "fft_r22sdf_defines.vh"
`include "fft_r22sdf_bf.v"
`include "fft_r22sdf_wm.v"
`include "ram_single_18k.v"

/** Radix-2^2 SDF FFT implementation.
 *
 * N must be a power of 4. Currently, any power of 4 <= 1024 is
 * supported, but this could easily be extended to greater lengths.
 */

module fft_r22sdf #(
   `FFT_PARAMS
   // parameter N              = 1024, /* FFT length */
   // parameter N_LOG2         = 10,
   // parameter N_STAGES       = 5,    /* log_4(N) */
   // parameter INPUT_WIDTH    = 14,
   // parameter TWIDDLE_WIDTH  = 10,
   // // +1 comes from complex multiply, which is really 2 multiplies.
   // parameter INTERNAL_WIDTH = 25,   /* ceil(log_2(N)) + INPUT_WIDTH + 1 */
   // // output width is the same as internal width because we shift by
   // // the twiddle bit width as we go.
   // parameter OUTPUT_WIDTH   = 25
) (
   input wire                           clk_i,
   input wire                           clk_3x_i,
   input wire                           rst_n,
   output reg                           sync_o, // output data ready
   // freq bin index of output data. only valid if `sync_o == 1'b1'
   output wire [N_LOG2-1:0]             data_ctr_o,
   input wire signed [INPUT_WIDTH-1:0]  data_re_i,
   input wire signed [INPUT_WIDTH-1:0]  data_im_i,
   output reg signed [OUTPUT_WIDTH-1:0] data_re_o,
   output reg signed [OUTPUT_WIDTH-1:0] data_im_o
   );

   // non bit-reversed output data count
   reg [N_LOG2-1:0]                     data_ctr_bit_nrml;

   // twiddle factors
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

   // stage counters
   // provide control logic to each stage
   reg [N_LOG2-1:0]                     stage0_ctr = {N_LOG2{1'b0}};
   wire [N_LOG2-1:0]                    stage1_ctr_wm;
   wire [N_LOG2-1:0]                    stage1_ctr;
   wire [N_LOG2-1:0]                    stage2_ctr_wm;
   wire [N_LOG2-1:0]                    stage2_ctr;
   wire [N_LOG2-1:0]                    stage3_ctr_wm;
   wire [N_LOG2-1:0]                    stage3_ctr;
   wire [N_LOG2-1:0]                    stage4_ctr_wm;
   wire [N_LOG2-1:0]                    stage4_ctr;

   // output data comes out in bit-reversed order
   genvar k;
   generate
      for (k=0; k<N_LOG2; k=k+1) begin
         assign data_ctr_o[k] = data_ctr_bit_nrml[N_LOG2-1-k];
      end
   endgenerate

   // stage 0
   wire signed [INTERNAL_WIDTH-1:0] bf0_re;
   wire signed [INTERNAL_WIDTH-1:0] bf0_im;
   wire signed [INTERNAL_WIDTH-1:0] w0_re;
   wire signed [INTERNAL_WIDTH-1:0] w0_im;

   fft_r22sdf_bf #(
      .DW        (INTERNAL_WIDTH),
      .FFT_N     (N),
      .FFT_NLOG2 (N_LOG2),
      .STAGE     (0),
      .STAGES    (N_STAGES)
   ) stage0_bf (
      .clk_i  (clk_i),
      .rst_n  (rst_n),
      .cnt_i  (stage0_ctr),
      .cnt_o  (stage1_ctr_wm),
      .x_re_i (data_re_i),
      .x_im_i (data_im_i),
      .z_re_o (bf0_re),
      .z_im_o (bf0_im)
   );

   // stage 1
   wire signed [INTERNAL_WIDTH-1:0] bf1_re;
   wire signed [INTERNAL_WIDTH-1:0] bf1_im;
   wire signed [INTERNAL_WIDTH-1:0] w1_re;
   wire signed [INTERNAL_WIDTH-1:0] w1_im;

   generate
      if (N_STAGES > 1) begin
         fft_r22sdf_wm #(
            .DW            (INTERNAL_WIDTH),
            .TWIDDLE_WIDTH (TWIDDLE_WIDTH),
            .FFT_N         (N),
            .NLOG2         (N_LOG2)
         ) stage0_wm (
            .clk_i    (clk_i),
            .clk_3x_i (clk_3x_i),
            .ctr_i    (stage1_ctr_wm),
            .ctr_o    (stage1_ctr),
            .rst_n    (rst_n),
            .x_re_i   (bf0_re),
            .x_im_i   (bf0_im),
            .w_re_i   (w_s0_re),
            .w_im_i   (w_s0_im),
            .z_re_o   (w0_re),
            .z_im_o   (w0_im)
         );

         fft_r22sdf_bf #(
            .DW        (INTERNAL_WIDTH),
            .FFT_N     (N),
            .FFT_NLOG2 (N_LOG2),
            .STAGE     (1),
            .STAGES    (N_STAGES)
         ) stage1_bf (
            .clk_i  (clk_i),
            .rst_n  (rst_n),
            .cnt_i  (stage1_ctr),
            .cnt_o  (stage2_ctr_wm),
            .x_re_i (w0_re),
            .x_im_i (w0_im),
            .z_re_o (bf1_re),
            .z_im_o (bf1_im)
         );
      end // if (N > 1)
   endgenerate

   // stage 2
   wire signed [INTERNAL_WIDTH-1:0] bf2_re;
   wire signed [INTERNAL_WIDTH-1:0] bf2_im;
   wire signed [INTERNAL_WIDTH-1:0] w2_re;
   wire signed [INTERNAL_WIDTH-1:0] w2_im;

   generate
      if (N_STAGES > 2) begin
         fft_r22sdf_wm #(
            .DW            (INTERNAL_WIDTH),
            .TWIDDLE_WIDTH (TWIDDLE_WIDTH),
            .FFT_N         (N),
            .NLOG2         (N_LOG2)
         ) stage1_wm (
            .clk_i    (clk_i),
            .clk_3x_i (clk_3x_i),
            .ctr_i    (stage2_ctr_wm),
            .ctr_o    (stage2_ctr),
            .rst_n    (rst_n),
            .x_re_i   (bf1_re),
            .x_im_i   (bf1_im),
            .w_re_i   (w_s1_re),
            .w_im_i   (w_s1_im),
            .z_re_o   (w1_re),
            .z_im_o   (w1_im)
         );

         fft_r22sdf_bf #(
            .DW        (INTERNAL_WIDTH),
            .FFT_N     (N),
            .FFT_NLOG2 (N_LOG2),
            .STAGE     (2),
            .STAGES    (N_STAGES)
         ) stage2_bf (
            .clk_i  (clk_i),
            .rst_n  (rst_n),
            .cnt_i  (stage2_ctr),
            .cnt_o  (stage3_ctr_wm),
            .x_re_i (w1_re),
            .x_im_i (w1_im),
            .z_re_o (bf2_re),
            .z_im_o (bf2_im)
         );
      end // if (N > 2)
   endgenerate

   // stage 3
   wire signed [INTERNAL_WIDTH-1:0] bf3_re;
   wire signed [INTERNAL_WIDTH-1:0] bf3_im;
   wire signed [INTERNAL_WIDTH-1:0] w3_re;
   wire signed [INTERNAL_WIDTH-1:0] w3_im;

   generate
      if (N_STAGES > 3) begin
         fft_r22sdf_wm #(
            .DW            (INTERNAL_WIDTH),
            .TWIDDLE_WIDTH (TWIDDLE_WIDTH),
            .FFT_N         (N),
            .NLOG2         (N_LOG2)
         ) stage2_wm (
            .clk_i    (clk_i),
            .clk_3x_i (clk_3x_i),
            .ctr_i    (stage3_ctr_wm),
            .ctr_o    (stage3_ctr),
            .rst_n    (rst_n),
            .x_re_i   (bf2_re),
            .x_im_i   (bf2_im),
            .w_re_i   (w_s2_re),
            .w_im_i   (w_s2_im),
            .z_re_o   (w2_re),
            .z_im_o   (w2_im)
         );

         fft_r22sdf_bf #(
            .DW        (INTERNAL_WIDTH),
            .FFT_N     (N),
            .FFT_NLOG2 (N_LOG2),
            .STAGE     (3),
            .STAGES    (N_STAGES)
         ) stage3_bf (
            .clk_i  (clk_i),
            .rst_n  (rst_n),
            .cnt_i  (stage3_ctr),
            .cnt_o  (stage4_ctr_wm),
            .x_re_i (w2_re),
            .x_im_i (w2_im),
            .z_re_o (bf3_re),
            .z_im_o (bf3_im)
         );
      end // if (N > 3)
   endgenerate

   // stage 4
   wire signed [INTERNAL_WIDTH-1:0] bf4_re;
   wire signed [INTERNAL_WIDTH-1:0] bf4_im;

   generate
      if (N_STAGES > 4) begin
         fft_r22sdf_wm #(
            .DW            (INTERNAL_WIDTH),
            .TWIDDLE_WIDTH (TWIDDLE_WIDTH),
            .FFT_N         (N),
            .NLOG2         (N_LOG2)
         ) stage3_wm (
            .clk_i    (clk_i),
            .clk_3x_i (clk_3x_i),
            .ctr_i    (stage4_ctr_wm),
            .ctr_o    (stage4_ctr),
            .rst_n    (rst_n),
            .x_re_i   (bf3_re),
            .x_im_i   (bf3_im),
            .w_re_i   (w_s3_re),
            .w_im_i   (w_s3_im),
            .z_re_o   (w3_re),
            .z_im_o   (w3_im)
         );

         fft_r22sdf_bf #(
            .DW        (INTERNAL_WIDTH),
            .FFT_N     (N),
            .FFT_NLOG2 (N_LOG2),
            .STAGE     (4),
            .STAGES    (N_STAGES)
         ) stage4_bf (
            .clk_i  (clk_i),
            .rst_n  (rst_n),
            .cnt_i  (stage4_ctr),
            .x_re_i (w3_re),
            .x_im_i (w3_im),
            .z_re_o (bf4_re),
            .z_im_o (bf4_im)
         );
      end // if (N > 4)
   endgenerate

   wire signed [INTERNAL_WIDTH-1:0] data_bf_last_re;
   wire signed [INTERNAL_WIDTH-1:0] data_bf_last_im;

   generate
      case (N_STAGES)
      5:
        begin
           assign data_bf_last_re = bf4_re;
           assign data_bf_last_im = bf4_im;
        end
      4:
        begin
           assign data_bf_last_re = bf3_re;
           assign data_bf_last_im = bf3_im;
        end
      3:
        begin
           assign data_bf_last_re = bf2_re;
           assign data_bf_last_im = bf2_im;
        end
      2:
        begin
           assign data_bf_last_re = bf1_re;
           assign data_bf_last_im = bf1_im;
        end
      1:
        begin
           assign data_bf_last_re = bf0_re;
           assign data_bf_last_im = bf0_im;
        end
      endcase
   endgenerate

   always @(posedge clk_i) begin
      if (!rst_n) begin
         sync_o            <= 1'b0;
         data_ctr_bit_nrml <= {N_LOG2{1'b0}};
         stage0_ctr        <= {N_LOG2{1'b0}};
      end else begin
         data_re_o  <= data_bf_last_re;
         data_im_o  <= data_bf_last_im;
         stage0_ctr <= stage0_ctr + 1'b1;

         if (sync_o == 1'b1) begin
            data_ctr_bit_nrml <= data_ctr_bit_nrml + 1'b1;
         end else begin
            data_ctr_bit_nrml <= {N_LOG2{1'b0}};
         end

         if (stage4_ctr == N_STAGES-2 || sync_o == 1'b1) begin
            sync_o <= 1'b1;
         end else begin
            sync_o <= 1'b0;
         end
      end
   end

endmodule // fft_r22sdf

`ifdef SIMULATE

`include "fft_r22sdf_defines.vh"
`include "PLLE2_BASE.v"
`include "PLLE2_ADV.v"
`include "BRAM_SINGLE_MACRO.v"
`include "RAMB18E1.v"
`include "glbl.v"

`timescale 1ns/1ps
module fft_r22sdf_tb #( `FFT_PARAMS );

   reg                             clk = 0;
   reg [INPUT_WIDTH-1:0]           samples [0:N-1];
   wire [INPUT_WIDTH-1:0]          data_i;
   wire                            sync;
   wire [N_LOG2-1:0]               data_cnt;
   wire [OUTPUT_WIDTH-1:0]         data_re_o;
   wire [OUTPUT_WIDTH-1:0]         data_im_o;
   reg [N_LOG2-1:0]                cnt;

   assign data_i = samples[cnt];

   integer                         idx;
   initial begin
      $dumpfile("tb/fft_r22sdf_tb.vcd");
      $dumpvars(0, fft_r22sdf_tb);

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


   fft_r22sdf #(
      .N              (N),
      .N_LOG2         (N_LOG2),
      .N_STAGES       (N_STAGES),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TWIDDLE_WIDTH  (TWIDDLE_WIDTH),
      .INTERNAL_WIDTH (INTERNAL_WIDTH),
      .OUTPUT_WIDTH   (OUTPUT_WIDTH)
   ) dut (
      .clk_i      (clk),
      .clk_3x_i   (clk_120mhz),
      .rst_n      (pll_lock),
      .sync_o     (sync),
      .data_ctr_o (data_cnt),
      .data_re_i  ($signed(data_i)),
      .data_im_i  ({INPUT_WIDTH{1'b0}}),
      .data_re_o  (data_re_o),
      .data_im_o  (data_im_o)
   );

endmodule

`endif
// Local Variables:
// flycheck-verilator-include-path:("/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/unimacro/"
//                                  "/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/"
//                                  "/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/unisims/"
//                                  "/home/matt/src/libdigital/libdigital/hdl/ram/")
// End:
