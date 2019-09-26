`default_nettype none

module fft_r22sdf_wm #(
   parameter DATA_WIDTH    = 25,
   parameter TWIDDLE_WIDTH = 10,
   parameter FFT_N         = 1024,
   parameter NLOG2         = 10
) (
   input wire                            clk_i,
   input wire                            rst_n,
   input wire                            clk_3x_i,
   input wire [NLOG2-1:0]                ctr_i,
   output reg [NLOG2-1:0]                ctr_o,
   input wire signed [DATA_WIDTH-1:0]    x_re_i,
   input wire signed [DATA_WIDTH-1:0]    x_im_i,
   input wire signed [TWIDDLE_WIDTH-1:0] w_re_i,
   input wire signed [TWIDDLE_WIDTH-1:0] w_im_i,
   output reg signed [DATA_WIDTH-1:0]    z_re_o,
   output reg signed [DATA_WIDTH-1:0]    z_im_o
);

   /**
    * Use the karatsuba algorithm to use 3 multiplies instead of 4.
    *
    * R+iI = (a+ib) * (c+id)
    *
    * e = a-b
    * f = c*e
    * R = b(c-d)+f
    * I = a(c+d)-f
    */
   // compute multiplies in stages to share DSP.
   reg [1:0]                             mul_state;
   reg signed [DATA_WIDTH+TWIDDLE_WIDTH-1:0]     kar_f;
   reg signed [DATA_WIDTH+TWIDDLE_WIDTH-1:0]     kar_r;
   reg signed [DATA_WIDTH+TWIDDLE_WIDTH-1:0]     kar_i;

   reg signed [DATA_WIDTH-1:0] x_re_reg;
   reg signed [DATA_WIDTH-1:0] x_im_reg;
   always @(posedge clk_3x_i) begin
      if (!rst_n) begin
         kar_f     <= {DATA_WIDTH+TWIDDLE_WIDTH{1'b0}};
         kar_r     <= {DATA_WIDTH+TWIDDLE_WIDTH{1'b0}};
         kar_i     <= {DATA_WIDTH+TWIDDLE_WIDTH{1'b0}};
         mul_state <= 2'd0;
      end else begin
         case (mul_state)
         2'd0:
           begin
              kar_f     <= w_re_i * (x_re_reg - x_im_reg);
              kar_r     <= kar_r;
              kar_i     <= kar_i;
              mul_state <= 2'd1;
           end
         2'd1:
           begin
              kar_f     <= kar_f;
              kar_r     <= x_im_reg * (w_re_i - w_im_i) + kar_f;
              kar_i     <= kar_i;
              mul_state <= 2'd2;
           end
         2'd2:
           begin
              kar_f     <= kar_f;
              kar_r     <= kar_r;
              kar_i     <= x_re_reg * (w_re_i + w_im_i) - kar_f;
              mul_state <= 2'd0;
           end
         default:
           begin
              kar_f     <= {DATA_WIDTH+TWIDDLE_WIDTH{1'b0}};
              kar_r     <= {DATA_WIDTH+TWIDDLE_WIDTH{1'b0}};
              kar_i     <= {DATA_WIDTH+TWIDDLE_WIDTH{1'b0}};
              mul_state <= 2'd0;
           end
         endcase
      end
   end

   reg [NLOG2-1:0] ctr_reg;
   always @(posedge clk_i) begin
      if (!rst_n) begin
         ctr_o           <= {NLOG2{1'b0}};
      end else begin
         x_re_reg <= x_re_i;
         x_im_reg <= x_im_i;

         ctr_reg <= ctr_i;
         ctr_o <= ctr_reg;
         // TODO does this cause rounding error? see the zipcpu blog
         // post about rounding.

         // TODO verify that dropping msb is ok

         // safe to ignore the msb since the greatest possible
         // absolute twiddle value is 2^(TWIDDLE_WIDTH-1)
         z_re_o <= kar_r[DATA_WIDTH+TWIDDLE_WIDTH-2:TWIDDLE_WIDTH-1];
         z_im_o <= kar_i[DATA_WIDTH+TWIDDLE_WIDTH-2:TWIDDLE_WIDTH-1];
      end
   end

endmodule
