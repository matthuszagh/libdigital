`default_nettype none

`include "dsp.v"

module bank #(
   parameter N_TAPS         = 120, /* total number of taps */
   parameter M              = 20,  /* decimation factor */
   parameter M_LOG2         = 5,
   parameter BANK_LEN       = 6,   /* N_TAPS/M */
   parameter BANK_LEN_LOG2  = 3,   /* num bits needed to hold a BANK_LEN counter */
   parameter INPUT_WIDTH    = 12,
   parameter TAP_WIDTH      = 16,
   parameter OUTPUT_WIDTH   = 35    /* same as internal width in fir_poly */
) (
   input wire                            clk,
   input wire                            rst_n,
   input wire                            clk_3x,
   input wire                            clk_2mhz_pos_en,
   input wire signed [INPUT_WIDTH-1:0]   din,
   output wire signed [OUTPUT_WIDTH-1:0] dout,
   input wire [M_LOG2-1:0]               tap_addr,
   input wire signed [TAP_WIDTH-1:0]     tap
);

   localparam DSP_A_WIDTH = 25;
   localparam DSP_B_WIDTH = 18;
   localparam DSP_P_WIDTH = 48;

   function [DSP_A_WIDTH-1:0] sign_extend_a(input [TAP_WIDTH-1:0] expr);
      sign_extend_a = (expr[TAP_WIDTH-1] == 1'b1) ? {{DSP_A_WIDTH-TAP_WIDTH{1'b1}}, expr}
                      : {{DSP_A_WIDTH-TAP_WIDTH{1'b0}}, expr};
   endfunction
   function [DSP_B_WIDTH-1:0] sign_extend_b(input [INPUT_WIDTH-1:0] expr);
      sign_extend_b = (expr[INPUT_WIDTH-1] == 1'b1) ? {{DSP_B_WIDTH-INPUT_WIDTH{1'b1}}, expr}
                      : {{DSP_B_WIDTH-INPUT_WIDTH{1'b0}}, expr};
   endfunction

   reg signed [INPUT_WIDTH-1:0]         shift_reg [0:BANK_LEN-2];

   wire signed [OUTPUT_WIDTH-1:0]       dsp_out;

   integer i;
   always @(posedge clk) begin
      if (!rst_n) begin
         for (i=0; i<BANK_LEN-1; i=i+1)
           shift_reg[i] <= 0;
      end else begin
         if (tap_addr == {M_LOG2{1'b0}}) begin
            shift_reg[0] <= din;
            for (i=1; i<BANK_LEN-1; i=i+1)
              shift_reg[i] <= shift_reg[i-1];
         end
      end
   end

   wire dsp_acc = (tap_addr != {BANK_LEN_LOG2{1'b0}});
   wire [DSP_P_WIDTH-OUTPUT_WIDTH-1:0] p_msbs_drop;

   reg signed [INPUT_WIDTH-1:0]       dsp_din;

   always @(*) begin
      case (dsp_acc)
      0: dsp_din       = din;
      default: dsp_din = shift_reg[tap_addr[BANK_LEN_LOG2-1:0]];
      endcase
   end

   // always @(*) begin
   //    case (tap_addr)
   //    {BANK_LEN_LOG2{1'b0}}: dsp_din = din;
   //    default: dsp_din = shift_reg[tap_addr-{{BANK_LEN_LOG2-1{1'b0}},1'b1}];
   //    endcase
   // end

   // TODO parameterize
   dsp dsp (
      .clk (clk),
      .acc (dsp_acc),
      .a   (sign_extend_a(tap_addr < 5'd5 ? tap : {DSP_A_WIDTH{1'b0}})),
      .b   (sign_extend_b(tap_addr < 5'd5 ? dsp_din : {DSP_B_WIDTH{1'b0}})),
      .p   ({p_msbs_drop, dsp_out})
   );

   assign dout = dsp_out;

endmodule
// Local Variables:
// flycheck-verilator-include-path:("/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/unimacro/"
//                                  "/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/"
//                                  "/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/unisims/")
// End:
