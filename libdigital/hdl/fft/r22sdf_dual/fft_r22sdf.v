`default_nettype none

`include "fft_r22sdf_bf.v"
`include "fft_r22sdf_wm.v"

/** Radix-2^2 SDF FFT implementation.
 *
 * N must be a power of 4. Currently, any power of 4 <= 1024 is
 * supported, but this could easily be extended to greater lengths.
 */

module fft_r22sdf #(
   parameter N              = 1024, /* FFT length */
   parameter INPUT_WIDTH    = 14,
   parameter TWIDDLE_WIDTH  = 10,
   // +1 comes from complex multiply, which is really 2 multiplies.
   parameter OUTPUT_WIDTH   = 25   /* ceil(log_2(N)) + INPUT_WIDTH + 1 */
) (
   input wire                            clk_i,
   input wire                            clk_3x_i,
   input wire                            rst_n,
   output reg                            sync_o, // output data ready
   // freq bin index of output data. only valid if `sync_o == 1'b1'
   output wire [N_LOG2-1:0]              data_ctr_o,
   input wire signed [INPUT_WIDTH-1:0]   data_re_i,
   input wire signed [INPUT_WIDTH-1:0]   data_im_i,
   output reg signed [OUTPUT_WIDTH-1:0]  data_re_o,
   output reg signed [OUTPUT_WIDTH-1:0]  data_im_o,
   // twiddle factors
   input wire signed [TWIDDLE_WIDTH-1:0] w_s0_re,
   input wire signed [TWIDDLE_WIDTH-1:0] w_s0_im,
   input wire signed [TWIDDLE_WIDTH-1:0] w_s1_re,
   input wire signed [TWIDDLE_WIDTH-1:0] w_s1_im,
   input wire signed [TWIDDLE_WIDTH-1:0] w_s2_re,
   input wire signed [TWIDDLE_WIDTH-1:0] w_s2_im,
   input wire signed [TWIDDLE_WIDTH-1:0] w_s3_re,
   input wire signed [TWIDDLE_WIDTH-1:0] w_s3_im,
   // stage counters
   output wire signed [N_LOG2-1:0]       stage1_ctr_wm,
   output wire signed [N_LOG2-1:0]       stage2_ctr_wm,
   output wire signed [N_LOG2-1:0]       stage3_ctr_wm,
   output wire signed [N_LOG2-1:0]       stage4_ctr_wm
);

   localparam N_LOG2 = $clog2(N);
   localparam N_STAGES = N_LOG2/2;

   // non bit-reversed output data count
   reg [N_LOG2-1:0]                     data_ctr_bit_nrml;

   // stage counters
   // provide control logic to each stage
   reg [N_LOG2-1:0]                     stage0_ctr;
   wire [N_LOG2-1:0]                    stage1_ctr;
   wire [N_LOG2-1:0]                    stage2_ctr;
   wire [N_LOG2-1:0]                    stage3_ctr;
   wire [N_LOG2-1:0]                    stage4_ctr;

   // output data comes out in bit-reversed order
   genvar k;
   generate
      for (k=0; k<N_LOG2; k=k+1) begin
         assign data_ctr_o[k] = data_ctr_bit_nrml[N_LOG2-1-k];
      end
   endgenerate

   // stage 0
   wire signed [OUTPUT_WIDTH-1:0] bf0_re;
   wire signed [OUTPUT_WIDTH-1:0] bf0_im;
   wire signed [OUTPUT_WIDTH-1:0] w0_re;
   wire signed [OUTPUT_WIDTH-1:0] w0_im;

   fft_r22sdf_bf #(
      .DATA_WIDTH (OUTPUT_WIDTH),
      .FFT_N      (N),
      .FFT_NLOG2  (N_LOG2),
      .STAGE      (0),
      .STAGES     (N_STAGES)
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
   wire signed [OUTPUT_WIDTH-1:0] bf1_re;
   wire signed [OUTPUT_WIDTH-1:0] bf1_im;
   wire signed [OUTPUT_WIDTH-1:0] w1_re;
   wire signed [OUTPUT_WIDTH-1:0] w1_im;

   generate
      if (N_STAGES > 1) begin
         fft_r22sdf_wm #(
            .DATA_WIDTH    (OUTPUT_WIDTH),
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
            .DATA_WIDTH (OUTPUT_WIDTH),
            .FFT_N      (N),
            .FFT_NLOG2  (N_LOG2),
            .STAGE      (1),
            .STAGES     (N_STAGES)
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
   wire signed [OUTPUT_WIDTH-1:0] bf2_re;
   wire signed [OUTPUT_WIDTH-1:0] bf2_im;
   wire signed [OUTPUT_WIDTH-1:0] w2_re;
   wire signed [OUTPUT_WIDTH-1:0] w2_im;

   generate
      if (N_STAGES > 2) begin
         fft_r22sdf_wm #(
            .DATA_WIDTH    (OUTPUT_WIDTH),
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
            .DATA_WIDTH (OUTPUT_WIDTH),
            .FFT_N      (N),
            .FFT_NLOG2  (N_LOG2),
            .STAGE      (2),
            .STAGES     (N_STAGES)
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
   wire signed [OUTPUT_WIDTH-1:0] bf3_re;
   wire signed [OUTPUT_WIDTH-1:0] bf3_im;
   wire signed [OUTPUT_WIDTH-1:0] w3_re;
   wire signed [OUTPUT_WIDTH-1:0] w3_im;

   generate
      if (N_STAGES > 3) begin
         fft_r22sdf_wm #(
            .DATA_WIDTH    (OUTPUT_WIDTH),
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
            .DATA_WIDTH (OUTPUT_WIDTH),
            .FFT_N      (N),
            .FFT_NLOG2  (N_LOG2),
            .STAGE      (3),
            .STAGES     (N_STAGES)
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
   wire signed [OUTPUT_WIDTH-1:0] bf4_re;
   wire signed [OUTPUT_WIDTH-1:0] bf4_im;

   generate
      if (N_STAGES > 4) begin
         fft_r22sdf_wm #(
            .DATA_WIDTH    (OUTPUT_WIDTH),
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
            .DATA_WIDTH (OUTPUT_WIDTH),
            .FFT_N      (N),
            .FFT_NLOG2  (N_LOG2),
            .STAGE      (4),
            .STAGES     (N_STAGES)
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

   wire signed [OUTPUT_WIDTH-1:0] data_bf_last_re;
   wire signed [OUTPUT_WIDTH-1:0] data_bf_last_im;

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
// Local Variables:
// flycheck-verilator-include-path:("/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/unimacro/"
//                                  "/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/"
//                                  "/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/unisims/"
//                                  "/home/matt/src/libdigital/libdigital/hdl/memory/ram/"
//                                  "/home/matt/src/libdigital/libdigital/hdl/memory/shift_reg/"
//                                  "/home/matt/src/libdigital/libdigital/hdl/dsp/multiply_add/")
// End:
