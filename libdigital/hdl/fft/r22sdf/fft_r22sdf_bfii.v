`default_nettype none

module fft_r22sdf_bfii #(
   parameter DW            = 25,
   parameter SHIFT_REG_LEN = 0
) (
   input wire                 clk_i,
   input wire                 rst_n,
   input wire                 sel_i,
   input wire                 tsel_i,
   input wire signed [DW-1:0] x_re_i,
   input wire signed [DW-1:0] x_im_i,
   output reg signed [DW-1:0] z_re_o = {DW{1'b0}},
   output reg signed [DW-1:0] z_im_o = {DW{1'b0}}
);

   reg signed [DW-1:0]        sr_re [0:SHIFT_REG_LEN-1];
   reg signed [DW-1:0]        sr_im [0:SHIFT_REG_LEN-1];

   wire signed [DW-1:0]       xsr_re;
   wire signed [DW-1:0]       xsr_im;
   reg signed [DW-1:0]        zsr_re = {DW{1'b0}};
   reg signed [DW-1:0]        zsr_im = {DW{1'b0}};

   assign xsr_re = sr_re[SHIFT_REG_LEN-1];
   assign xsr_im = sr_im[SHIFT_REG_LEN-1];

   always @(*) begin
      case ({sel_i, tsel_i})
      2'b10:
        begin
           z_re_o  = xsr_re + x_im_i;
           z_im_o  = xsr_im - x_re_i;
           zsr_re = xsr_re - x_im_i;
           zsr_im = xsr_im + x_re_i;
        end
      2'b11:
        begin
           z_re_o  = xsr_re + x_re_i;
           z_im_o  = xsr_im + x_im_i;
           zsr_re = xsr_re - x_re_i;
           zsr_im = xsr_im - x_im_i;
        end
      default:
        begin
           z_re_o  = xsr_re;
           z_im_o  = xsr_im;
           zsr_re = x_re_i;
           zsr_im = x_im_i;
        end
      endcase
   end

   integer                     i;
   always @(posedge clk_i) begin
      if (!rst_n) begin
         for (i=0; i<SHIFT_REG_LEN; i=i+1) begin
            sr_re[i] = {DW{1'b0}};
            sr_im[i] = {DW{1'b0}};
         end
      end else begin
         sr_re[0] <= zsr_re;
         sr_im[0] <= zsr_im;
         for (i=1; i<SHIFT_REG_LEN; i=i+1) begin
            sr_re[i] <= sr_re[i-1];
            sr_im[i] <= sr_im[i-1];
         end
      end
   end

endmodule
// Local Variables:
// flycheck-verilator-include-path:("/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/unimacro/"
//                                  "/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/"
//                                  "/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/unisims/")
// End:
