`default_nettype none

`include "fir_poly.v"
`include "fir_poly_defines.vh"

module fir_poly_2channel #(
   `FIR_POLY_PARAMS
) (
   input wire                            clk,
   input wire                            rst_n,
   input wire                            clk_2mhz_pos_en,
   input wire signed [INPUT_WIDTH-1:0]   din_a,
   input wire signed [INPUT_WIDTH-1:0]   din_b,
   output wire signed [OUTPUT_WIDTH-1:0] dout_a,
   output wire signed [OUTPUT_WIDTH-1:0] dout_b,
   output wire                           dvalid,
   // DSPs
   // channel A
   output wire                           chan_a_dsp_acc_bank0,
   output wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank0,
   output wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank0,
   input wire signed [DSP_P_WIDTH-1:0]   chan_a_dsp_p_bank0,

   output wire                           chan_a_dsp_acc_bank1,
   output wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank1,
   output wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank1,
   input wire signed [DSP_P_WIDTH-1:0]   chan_a_dsp_p_bank1,

   output wire                           chan_a_dsp_acc_bank2,
   output wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank2,
   output wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank2,
   input wire signed [DSP_P_WIDTH-1:0]   chan_a_dsp_p_bank2,

   output wire                           chan_a_dsp_acc_bank3,
   output wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank3,
   output wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank3,
   input wire signed [DSP_P_WIDTH-1:0]   chan_a_dsp_p_bank3,

   output wire                           chan_a_dsp_acc_bank4,
   output wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank4,
   output wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank4,
   input wire signed [DSP_P_WIDTH-1:0]   chan_a_dsp_p_bank4,

   output wire                           chan_a_dsp_acc_bank5,
   output wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank5,
   output wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank5,
   input wire signed [DSP_P_WIDTH-1:0]   chan_a_dsp_p_bank5,

   output wire                           chan_a_dsp_acc_bank6,
   output wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank6,
   output wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank6,
   input wire signed [DSP_P_WIDTH-1:0]   chan_a_dsp_p_bank6,

   output wire                           chan_a_dsp_acc_bank7,
   output wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank7,
   output wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank7,
   input wire signed [DSP_P_WIDTH-1:0]   chan_a_dsp_p_bank7,

   output wire                           chan_a_dsp_acc_bank8,
   output wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank8,
   output wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank8,
   input wire signed [DSP_P_WIDTH-1:0]   chan_a_dsp_p_bank8,

   output wire                           chan_a_dsp_acc_bank9,
   output wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank9,
   output wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank9,
   input wire signed [DSP_P_WIDTH-1:0]   chan_a_dsp_p_bank9,

   output wire                           chan_a_dsp_acc_bank10,
   output wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank10,
   output wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank10,
   input wire signed [DSP_P_WIDTH-1:0]   chan_a_dsp_p_bank10,

   output wire                           chan_a_dsp_acc_bank11,
   output wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank11,
   output wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank11,
   input wire signed [DSP_P_WIDTH-1:0]   chan_a_dsp_p_bank11,

   output wire                           chan_a_dsp_acc_bank12,
   output wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank12,
   output wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank12,
   input wire signed [DSP_P_WIDTH-1:0]   chan_a_dsp_p_bank12,

   output wire                           chan_a_dsp_acc_bank13,
   output wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank13,
   output wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank13,
   input wire signed [DSP_P_WIDTH-1:0]   chan_a_dsp_p_bank13,

   output wire                           chan_a_dsp_acc_bank14,
   output wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank14,
   output wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank14,
   input wire signed [DSP_P_WIDTH-1:0]   chan_a_dsp_p_bank14,

   output wire                           chan_a_dsp_acc_bank15,
   output wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank15,
   output wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank15,
   input wire signed [DSP_P_WIDTH-1:0]   chan_a_dsp_p_bank15,

   output wire                           chan_a_dsp_acc_bank16,
   output wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank16,
   output wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank16,
   input wire signed [DSP_P_WIDTH-1:0]   chan_a_dsp_p_bank16,

   output wire                           chan_a_dsp_acc_bank17,
   output wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank17,
   output wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank17,
   input wire signed [DSP_P_WIDTH-1:0]   chan_a_dsp_p_bank17,

   output wire                           chan_a_dsp_acc_bank18,
   output wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank18,
   output wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank18,
   input wire signed [DSP_P_WIDTH-1:0]   chan_a_dsp_p_bank18,

   output wire                           chan_a_dsp_acc_bank19,
   output wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank19,
   output wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank19,
   input wire signed [DSP_P_WIDTH-1:0]   chan_a_dsp_p_bank19,

   // channel B
   output wire                           chan_b_dsp_acc_bank0,
   output wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank0,
   output wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank0,
   input wire signed [DSP_P_WIDTH-1:0]   chan_b_dsp_p_bank0,

   output wire                           chan_b_dsp_acc_bank1,
   output wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank1,
   output wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank1,
   input wire signed [DSP_P_WIDTH-1:0]   chan_b_dsp_p_bank1,

   output wire                           chan_b_dsp_acc_bank2,
   output wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank2,
   output wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank2,
   input wire signed [DSP_P_WIDTH-1:0]   chan_b_dsp_p_bank2,

   output wire                           chan_b_dsp_acc_bank3,
   output wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank3,
   output wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank3,
   input wire signed [DSP_P_WIDTH-1:0]   chan_b_dsp_p_bank3,

   output wire                           chan_b_dsp_acc_bank4,
   output wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank4,
   output wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank4,
   input wire signed [DSP_P_WIDTH-1:0]   chan_b_dsp_p_bank4,

   output wire                           chan_b_dsp_acc_bank5,
   output wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank5,
   output wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank5,
   input wire signed [DSP_P_WIDTH-1:0]   chan_b_dsp_p_bank5,

   output wire                           chan_b_dsp_acc_bank6,
   output wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank6,
   output wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank6,
   input wire signed [DSP_P_WIDTH-1:0]   chan_b_dsp_p_bank6,

   output wire                           chan_b_dsp_acc_bank7,
   output wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank7,
   output wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank7,
   input wire signed [DSP_P_WIDTH-1:0]   chan_b_dsp_p_bank7,

   output wire                           chan_b_dsp_acc_bank8,
   output wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank8,
   output wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank8,
   input wire signed [DSP_P_WIDTH-1:0]   chan_b_dsp_p_bank8,

   output wire                           chan_b_dsp_acc_bank9,
   output wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank9,
   output wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank9,
   input wire signed [DSP_P_WIDTH-1:0]   chan_b_dsp_p_bank9,

   output wire                           chan_b_dsp_acc_bank10,
   output wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank10,
   output wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank10,
   input wire signed [DSP_P_WIDTH-1:0]   chan_b_dsp_p_bank10,

   output wire                           chan_b_dsp_acc_bank11,
   output wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank11,
   output wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank11,
   input wire signed [DSP_P_WIDTH-1:0]   chan_b_dsp_p_bank11,

   output wire                           chan_b_dsp_acc_bank12,
   output wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank12,
   output wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank12,
   input wire signed [DSP_P_WIDTH-1:0]   chan_b_dsp_p_bank12,

   output wire                           chan_b_dsp_acc_bank13,
   output wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank13,
   output wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank13,
   input wire signed [DSP_P_WIDTH-1:0]   chan_b_dsp_p_bank13,

   output wire                           chan_b_dsp_acc_bank14,
   output wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank14,
   output wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank14,
   input wire signed [DSP_P_WIDTH-1:0]   chan_b_dsp_p_bank14,

   output wire                           chan_b_dsp_acc_bank15,
   output wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank15,
   output wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank15,
   input wire signed [DSP_P_WIDTH-1:0]   chan_b_dsp_p_bank15,

   output wire                           chan_b_dsp_acc_bank16,
   output wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank16,
   output wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank16,
   input wire signed [DSP_P_WIDTH-1:0]   chan_b_dsp_p_bank16,

   output wire                           chan_b_dsp_acc_bank17,
   output wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank17,
   output wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank17,
   input wire signed [DSP_P_WIDTH-1:0]   chan_b_dsp_p_bank17,

   output wire                           chan_b_dsp_acc_bank18,
   output wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank18,
   output wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank18,
   input wire signed [DSP_P_WIDTH-1:0]   chan_b_dsp_p_bank18,

   output wire                           chan_b_dsp_acc_bank19,
   output wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank19,
   output wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank19,
   input wire signed [DSP_P_WIDTH-1:0]   chan_b_dsp_p_bank19
);

   reg [M_LOG2:0]     tap_mem_addr;

   always @(posedge clk) begin
      if (!rst_n) begin
         tap_mem_addr <= {M_LOG2+1{1'b0}};
      end else begin
         tap_mem_addr <= tap_mem_addr + 1'b1;
         if (clk_2mhz_pos_en) begin
            tap_mem_addr <= {M_LOG2+1{1'b0}};
         end
      end
   end

   reg signed [TAP_WIDTH-1:0] taps0 [0:BANK_LEN-1];
   reg signed [TAP_WIDTH-1:0] taps1 [0:BANK_LEN-1];
   reg signed [TAP_WIDTH-1:0] taps2 [0:BANK_LEN-1];
   reg signed [TAP_WIDTH-1:0] taps3 [0:BANK_LEN-1];
   reg signed [TAP_WIDTH-1:0] taps4 [0:BANK_LEN-1];
   reg signed [TAP_WIDTH-1:0] taps5 [0:BANK_LEN-1];
   reg signed [TAP_WIDTH-1:0] taps6 [0:BANK_LEN-1];
   reg signed [TAP_WIDTH-1:0] taps7 [0:BANK_LEN-1];
   reg signed [TAP_WIDTH-1:0] taps8 [0:BANK_LEN-1];
   reg signed [TAP_WIDTH-1:0] taps9 [0:BANK_LEN-1];
   reg signed [TAP_WIDTH-1:0] taps10 [0:BANK_LEN-1];
   reg signed [TAP_WIDTH-1:0] taps11 [0:BANK_LEN-1];
   reg signed [TAP_WIDTH-1:0] taps12 [0:BANK_LEN-1];
   reg signed [TAP_WIDTH-1:0] taps13 [0:BANK_LEN-1];
   reg signed [TAP_WIDTH-1:0] taps14 [0:BANK_LEN-1];
   reg signed [TAP_WIDTH-1:0] taps15 [0:BANK_LEN-1];
   reg signed [TAP_WIDTH-1:0] taps16 [0:BANK_LEN-1];
   reg signed [TAP_WIDTH-1:0] taps17 [0:BANK_LEN-1];
   reg signed [TAP_WIDTH-1:0] taps18 [0:BANK_LEN-1];
   reg signed [TAP_WIDTH-1:0] taps19 [0:BANK_LEN-1];

   initial begin
      $readmemh("taps/taps0.hex", taps0);
      $readmemh("taps/taps1.hex", taps1);
      $readmemh("taps/taps2.hex", taps2);
      $readmemh("taps/taps3.hex", taps3);
      $readmemh("taps/taps4.hex", taps4);
      $readmemh("taps/taps5.hex", taps5);
      $readmemh("taps/taps6.hex", taps6);
      $readmemh("taps/taps7.hex", taps7);
      $readmemh("taps/taps8.hex", taps8);
      $readmemh("taps/taps9.hex", taps9);
      $readmemh("taps/taps10.hex", taps10);
      $readmemh("taps/taps11.hex", taps11);
      $readmemh("taps/taps12.hex", taps12);
      $readmemh("taps/taps13.hex", taps13);
      $readmemh("taps/taps14.hex", taps14);
      $readmemh("taps/taps15.hex", taps15);
      $readmemh("taps/taps16.hex", taps16);
      $readmemh("taps/taps17.hex", taps17);
      $readmemh("taps/taps18.hex", taps18);
      $readmemh("taps/taps19.hex", taps19);
   end

   fir_poly #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .M_LOG2         (M_LOG2),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .INTERNAL_WIDTH (INTERNAL_WIDTH),
      .NORM_SHIFT     (NORM_SHIFT),
      .OUTPUT_WIDTH   (OUTPUT_WIDTH),
      .DSP_A_WIDTH    (DSP_A_WIDTH),
      .DSP_B_WIDTH    (DSP_B_WIDTH),
      .DSP_P_WIDTH    (DSP_P_WIDTH)
   ) fir_poly_chan_a (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (din_a),
      .dout            (dout_a),
      .dvalid          (dvalid),
      .tap_addr        (tap_mem_addr),
      .tap0            (taps0[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap1            (taps1[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap2            (taps2[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap3            (taps3[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap4            (taps4[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap5            (taps5[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap6            (taps6[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap7            (taps7[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap8            (taps8[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap9            (taps9[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap10           (taps10[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap11           (taps11[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap12           (taps12[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap13           (taps13[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap14           (taps14[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap15           (taps15[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap16           (taps16[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap17           (taps17[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap18           (taps18[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap19           (taps19[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      // DSPs
      .dsp_acc_bank0   (chan_a_dsp_acc_bank0),
      .dsp_a_bank0     (chan_a_dsp_a_bank0),
      .dsp_b_bank0     (chan_a_dsp_b_bank0),
      .dsp_p_bank0     (chan_a_dsp_p_bank0),

      .dsp_acc_bank1   (chan_a_dsp_acc_bank1),
      .dsp_a_bank1     (chan_a_dsp_a_bank1),
      .dsp_b_bank1     (chan_a_dsp_b_bank1),
      .dsp_p_bank1     (chan_a_dsp_p_bank1),

      .dsp_acc_bank2   (chan_a_dsp_acc_bank2),
      .dsp_a_bank2     (chan_a_dsp_a_bank2),
      .dsp_b_bank2     (chan_a_dsp_b_bank2),
      .dsp_p_bank2     (chan_a_dsp_p_bank2),

      .dsp_acc_bank3   (chan_a_dsp_acc_bank3),
      .dsp_a_bank3     (chan_a_dsp_a_bank3),
      .dsp_b_bank3     (chan_a_dsp_b_bank3),
      .dsp_p_bank3     (chan_a_dsp_p_bank3),

      .dsp_acc_bank4   (chan_a_dsp_acc_bank4),
      .dsp_a_bank4     (chan_a_dsp_a_bank4),
      .dsp_b_bank4     (chan_a_dsp_b_bank4),
      .dsp_p_bank4     (chan_a_dsp_p_bank4),

      .dsp_acc_bank5   (chan_a_dsp_acc_bank5),
      .dsp_a_bank5     (chan_a_dsp_a_bank5),
      .dsp_b_bank5     (chan_a_dsp_b_bank5),
      .dsp_p_bank5     (chan_a_dsp_p_bank5),

      .dsp_acc_bank6   (chan_a_dsp_acc_bank6),
      .dsp_a_bank6     (chan_a_dsp_a_bank6),
      .dsp_b_bank6     (chan_a_dsp_b_bank6),
      .dsp_p_bank6     (chan_a_dsp_p_bank6),

      .dsp_acc_bank7   (chan_a_dsp_acc_bank7),
      .dsp_a_bank7     (chan_a_dsp_a_bank7),
      .dsp_b_bank7     (chan_a_dsp_b_bank7),
      .dsp_p_bank7     (chan_a_dsp_p_bank7),

      .dsp_acc_bank8   (chan_a_dsp_acc_bank8),
      .dsp_a_bank8     (chan_a_dsp_a_bank8),
      .dsp_b_bank8     (chan_a_dsp_b_bank8),
      .dsp_p_bank8     (chan_a_dsp_p_bank8),

      .dsp_acc_bank9   (chan_a_dsp_acc_bank9),
      .dsp_a_bank9     (chan_a_dsp_a_bank9),
      .dsp_b_bank9     (chan_a_dsp_b_bank9),
      .dsp_p_bank9     (chan_a_dsp_p_bank9),

      .dsp_acc_bank10  (chan_a_dsp_acc_bank10),
      .dsp_a_bank10    (chan_a_dsp_a_bank10),
      .dsp_b_bank10    (chan_a_dsp_b_bank10),
      .dsp_p_bank10    (chan_a_dsp_p_bank10),

      .dsp_acc_bank11  (chan_a_dsp_acc_bank11),
      .dsp_a_bank11    (chan_a_dsp_a_bank11),
      .dsp_b_bank11    (chan_a_dsp_b_bank11),
      .dsp_p_bank11    (chan_a_dsp_p_bank11),

      .dsp_acc_bank12  (chan_a_dsp_acc_bank12),
      .dsp_a_bank12    (chan_a_dsp_a_bank12),
      .dsp_b_bank12    (chan_a_dsp_b_bank12),
      .dsp_p_bank12    (chan_a_dsp_p_bank12),

      .dsp_acc_bank13  (chan_a_dsp_acc_bank13),
      .dsp_a_bank13    (chan_a_dsp_a_bank13),
      .dsp_b_bank13    (chan_a_dsp_b_bank13),
      .dsp_p_bank13    (chan_a_dsp_p_bank13),

      .dsp_acc_bank14  (chan_a_dsp_acc_bank14),
      .dsp_a_bank14    (chan_a_dsp_a_bank14),
      .dsp_b_bank14    (chan_a_dsp_b_bank14),
      .dsp_p_bank14    (chan_a_dsp_p_bank14),

      .dsp_acc_bank15  (chan_a_dsp_acc_bank15),
      .dsp_a_bank15    (chan_a_dsp_a_bank15),
      .dsp_b_bank15    (chan_a_dsp_b_bank15),
      .dsp_p_bank15    (chan_a_dsp_p_bank15),

      .dsp_acc_bank16  (chan_a_dsp_acc_bank16),
      .dsp_a_bank16    (chan_a_dsp_a_bank16),
      .dsp_b_bank16    (chan_a_dsp_b_bank16),
      .dsp_p_bank16    (chan_a_dsp_p_bank16),

      .dsp_acc_bank17  (chan_a_dsp_acc_bank17),
      .dsp_a_bank17    (chan_a_dsp_a_bank17),
      .dsp_b_bank17    (chan_a_dsp_b_bank17),
      .dsp_p_bank17    (chan_a_dsp_p_bank17),

      .dsp_acc_bank18  (chan_a_dsp_acc_bank18),
      .dsp_a_bank18    (chan_a_dsp_a_bank18),
      .dsp_b_bank18    (chan_a_dsp_b_bank18),
      .dsp_p_bank18    (chan_a_dsp_p_bank18),

      .dsp_acc_bank19  (chan_a_dsp_acc_bank19),
      .dsp_a_bank19    (chan_a_dsp_a_bank19),
      .dsp_b_bank19    (chan_a_dsp_b_bank19),
      .dsp_p_bank19    (chan_a_dsp_p_bank19)
   );

   fir_poly #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .M_LOG2         (M_LOG2),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .INTERNAL_WIDTH (INTERNAL_WIDTH),
      .NORM_SHIFT     (NORM_SHIFT),
      .OUTPUT_WIDTH   (OUTPUT_WIDTH),
      .DSP_A_WIDTH    (DSP_A_WIDTH),
      .DSP_B_WIDTH    (DSP_B_WIDTH),
      .DSP_P_WIDTH    (DSP_P_WIDTH)
   ) fir_poly_chan_b (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (din_b),
      .dout            (dout_b),
      .tap_addr        (tap_mem_addr),
      .tap0            (taps0[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap1            (taps1[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap2            (taps2[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap3            (taps3[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap4            (taps4[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap5            (taps5[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap6            (taps6[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap7            (taps7[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap8            (taps8[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap9            (taps9[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap10           (taps10[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap11           (taps11[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap12           (taps12[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap13           (taps13[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap14           (taps14[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap15           (taps15[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap16           (taps16[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap17           (taps17[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap18           (taps18[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      .tap19           (taps19[tap_mem_addr[BANK_LEN_LOG2-1:0]]),
      // DSPs
      .dsp_acc_bank0   (chan_b_dsp_acc_bank0),
      .dsp_a_bank0     (chan_b_dsp_a_bank0),
      .dsp_b_bank0     (chan_b_dsp_b_bank0),
      .dsp_p_bank0     (chan_b_dsp_p_bank0),

      .dsp_acc_bank1   (chan_b_dsp_acc_bank1),
      .dsp_a_bank1     (chan_b_dsp_a_bank1),
      .dsp_b_bank1     (chan_b_dsp_b_bank1),
      .dsp_p_bank1     (chan_b_dsp_p_bank1),

      .dsp_acc_bank2   (chan_b_dsp_acc_bank2),
      .dsp_a_bank2     (chan_b_dsp_a_bank2),
      .dsp_b_bank2     (chan_b_dsp_b_bank2),
      .dsp_p_bank2     (chan_b_dsp_p_bank2),

      .dsp_acc_bank3   (chan_b_dsp_acc_bank3),
      .dsp_a_bank3     (chan_b_dsp_a_bank3),
      .dsp_b_bank3     (chan_b_dsp_b_bank3),
      .dsp_p_bank3     (chan_b_dsp_p_bank3),

      .dsp_acc_bank4   (chan_b_dsp_acc_bank4),
      .dsp_a_bank4     (chan_b_dsp_a_bank4),
      .dsp_b_bank4     (chan_b_dsp_b_bank4),
      .dsp_p_bank4     (chan_b_dsp_p_bank4),

      .dsp_acc_bank5   (chan_b_dsp_acc_bank5),
      .dsp_a_bank5     (chan_b_dsp_a_bank5),
      .dsp_b_bank5     (chan_b_dsp_b_bank5),
      .dsp_p_bank5     (chan_b_dsp_p_bank5),

      .dsp_acc_bank6   (chan_b_dsp_acc_bank6),
      .dsp_a_bank6     (chan_b_dsp_a_bank6),
      .dsp_b_bank6     (chan_b_dsp_b_bank6),
      .dsp_p_bank6     (chan_b_dsp_p_bank6),

      .dsp_acc_bank7   (chan_b_dsp_acc_bank7),
      .dsp_a_bank7     (chan_b_dsp_a_bank7),
      .dsp_b_bank7     (chan_b_dsp_b_bank7),
      .dsp_p_bank7     (chan_b_dsp_p_bank7),

      .dsp_acc_bank8   (chan_b_dsp_acc_bank8),
      .dsp_a_bank8     (chan_b_dsp_a_bank8),
      .dsp_b_bank8     (chan_b_dsp_b_bank8),
      .dsp_p_bank8     (chan_b_dsp_p_bank8),

      .dsp_acc_bank9   (chan_b_dsp_acc_bank9),
      .dsp_a_bank9     (chan_b_dsp_a_bank9),
      .dsp_b_bank9     (chan_b_dsp_b_bank9),
      .dsp_p_bank9     (chan_b_dsp_p_bank9),

      .dsp_acc_bank10  (chan_b_dsp_acc_bank10),
      .dsp_a_bank10    (chan_b_dsp_a_bank10),
      .dsp_b_bank10    (chan_b_dsp_b_bank10),
      .dsp_p_bank10    (chan_b_dsp_p_bank10),

      .dsp_acc_bank11  (chan_b_dsp_acc_bank11),
      .dsp_a_bank11    (chan_b_dsp_a_bank11),
      .dsp_b_bank11    (chan_b_dsp_b_bank11),
      .dsp_p_bank11    (chan_b_dsp_p_bank11),

      .dsp_acc_bank12  (chan_b_dsp_acc_bank12),
      .dsp_a_bank12    (chan_b_dsp_a_bank12),
      .dsp_b_bank12    (chan_b_dsp_b_bank12),
      .dsp_p_bank12    (chan_b_dsp_p_bank12),

      .dsp_acc_bank13  (chan_b_dsp_acc_bank13),
      .dsp_a_bank13    (chan_b_dsp_a_bank13),
      .dsp_b_bank13    (chan_b_dsp_b_bank13),
      .dsp_p_bank13    (chan_b_dsp_p_bank13),

      .dsp_acc_bank14  (chan_b_dsp_acc_bank14),
      .dsp_a_bank14    (chan_b_dsp_a_bank14),
      .dsp_b_bank14    (chan_b_dsp_b_bank14),
      .dsp_p_bank14    (chan_b_dsp_p_bank14),

      .dsp_acc_bank15  (chan_b_dsp_acc_bank15),
      .dsp_a_bank15    (chan_b_dsp_a_bank15),
      .dsp_b_bank15    (chan_b_dsp_b_bank15),
      .dsp_p_bank15    (chan_b_dsp_p_bank15),

      .dsp_acc_bank16  (chan_b_dsp_acc_bank16),
      .dsp_a_bank16    (chan_b_dsp_a_bank16),
      .dsp_b_bank16    (chan_b_dsp_b_bank16),
      .dsp_p_bank16    (chan_b_dsp_p_bank16),

      .dsp_acc_bank17  (chan_b_dsp_acc_bank17),
      .dsp_a_bank17    (chan_b_dsp_a_bank17),
      .dsp_b_bank17    (chan_b_dsp_b_bank17),
      .dsp_p_bank17    (chan_b_dsp_p_bank17),

      .dsp_acc_bank18  (chan_b_dsp_acc_bank18),
      .dsp_a_bank18    (chan_b_dsp_a_bank18),
      .dsp_b_bank18    (chan_b_dsp_b_bank18),
      .dsp_p_bank18    (chan_b_dsp_p_bank18),

      .dsp_acc_bank19  (chan_b_dsp_acc_bank19),
      .dsp_a_bank19    (chan_b_dsp_a_bank19),
      .dsp_b_bank19    (chan_b_dsp_b_bank19),
      .dsp_p_bank19    (chan_b_dsp_p_bank19)
   );

endmodule

`ifdef SIMULATE

`include "DSP48E1.v"
`include "glbl.v"

`timescale 1ns/1ps
module fir_poly_2channel_tb #(
   `FIR_POLY_PARAMS
);

   localparam SAMPLE_LEN = 10000;

   reg  clk = 0;
   reg  rst_n = 0;

   always #12.5 clk = !clk;

   initial begin
      #50 rst_n = 1;
   end

   // base clock 2mhz clock enable
   reg                  clk_2mhz_pos_en = 1'b1;
   reg [4:0]            clk_2mhz_ctr    = 5'd0;

   always @(posedge clk) begin
      if (!rst_n) begin
         clk_2mhz_pos_en <= 1'b0;
         clk_2mhz_ctr    <= 5'd0;
      end else begin
         if (clk_2mhz_ctr == 5'd19) begin
            clk_2mhz_pos_en <= 1'b1;
            clk_2mhz_ctr    <= 5'd0;
         end else begin
            clk_2mhz_pos_en <= 1'b0;
            clk_2mhz_ctr    <= clk_2mhz_ctr + 1'b1;
         end
      end
   end

   reg signed [INPUT_WIDTH-1:0] samples [0:SAMPLE_LEN-1];
   wire signed [INPUT_WIDTH-1:0] sample_in = samples[ctr];
   wire signed [OUTPUT_WIDTH-1:0] dout_a;
   wire signed [OUTPUT_WIDTH-1:0] dout_b;
   wire                           dvalid;

   integer                      ctr = 0;
   reg                          ctr_delay = 1'b0;
   always @(posedge clk) begin
      if (!rst_n) begin
         ctr <= 0;
      end else begin
         if (ctr == 0) begin
            if (ctr_delay)
              ctr <= 1;
            if (clk_2mhz_pos_en)
              ctr_delay <= 1;
         end else begin
            ctr <= ctr + 1;
         end
      end
   end

   integer i, f;
   initial begin
      $dumpfile("tb/fir_poly_2channel.vcd");
      $dumpvars(0, fir_poly_2channel_tb);

      f = $fopen("tb/sample_out_verilog.txt", "w");

      $readmemh("tb/sample_in.hex", samples);

      #100000 $finish;
   end

   always @(posedge clk) begin
      if (dvalid && clk_2mhz_pos_en) begin
         $fwrite(f, "%d\n", $signed(dout_a));
      end
   end

   wire                           chan_a_dsp_acc_bank0;
   wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank0;
   wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank0;
   wire signed [DSP_P_WIDTH-1:0]  chan_a_dsp_p_bank0;

   wire                           chan_a_dsp_acc_bank1;
   wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank1;
   wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank1;
   wire signed [DSP_P_WIDTH-1:0]  chan_a_dsp_p_bank1;

   wire                           chan_a_dsp_acc_bank2;
   wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank2;
   wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank2;
   wire signed [DSP_P_WIDTH-1:0]  chan_a_dsp_p_bank2;

   wire                           chan_a_dsp_acc_bank3;
   wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank3;
   wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank3;
   wire signed [DSP_P_WIDTH-1:0]  chan_a_dsp_p_bank3;

   wire                           chan_a_dsp_acc_bank4;
   wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank4;
   wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank4;
   wire signed [DSP_P_WIDTH-1:0]  chan_a_dsp_p_bank4;

   wire                           chan_a_dsp_acc_bank5;
   wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank5;
   wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank5;
   wire signed [DSP_P_WIDTH-1:0]  chan_a_dsp_p_bank5;

   wire                           chan_a_dsp_acc_bank6;
   wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank6;
   wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank6;
   wire signed [DSP_P_WIDTH-1:0]  chan_a_dsp_p_bank6;

   wire                           chan_a_dsp_acc_bank7;
   wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank7;
   wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank7;
   wire signed [DSP_P_WIDTH-1:0]  chan_a_dsp_p_bank7;

   wire                           chan_a_dsp_acc_bank8;
   wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank8;
   wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank8;
   wire signed [DSP_P_WIDTH-1:0]  chan_a_dsp_p_bank8;

   wire                           chan_a_dsp_acc_bank9;
   wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank9;
   wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank9;
   wire signed [DSP_P_WIDTH-1:0]  chan_a_dsp_p_bank9;

   wire                           chan_a_dsp_acc_bank10;
   wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank10;
   wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank10;
   wire signed [DSP_P_WIDTH-1:0]  chan_a_dsp_p_bank10;

   wire                           chan_a_dsp_acc_bank11;
   wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank11;
   wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank11;
   wire signed [DSP_P_WIDTH-1:0]  chan_a_dsp_p_bank11;

   wire                           chan_a_dsp_acc_bank12;
   wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank12;
   wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank12;
   wire signed [DSP_P_WIDTH-1:0]  chan_a_dsp_p_bank12;

   wire                           chan_a_dsp_acc_bank13;
   wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank13;
   wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank13;
   wire signed [DSP_P_WIDTH-1:0]  chan_a_dsp_p_bank13;

   wire                           chan_a_dsp_acc_bank14;
   wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank14;
   wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank14;
   wire signed [DSP_P_WIDTH-1:0]  chan_a_dsp_p_bank14;

   wire                           chan_a_dsp_acc_bank15;
   wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank15;
   wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank15;
   wire signed [DSP_P_WIDTH-1:0]  chan_a_dsp_p_bank15;

   wire                           chan_a_dsp_acc_bank16;
   wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank16;
   wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank16;
   wire signed [DSP_P_WIDTH-1:0]  chan_a_dsp_p_bank16;

   wire                           chan_a_dsp_acc_bank17;
   wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank17;
   wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank17;
   wire signed [DSP_P_WIDTH-1:0]  chan_a_dsp_p_bank17;

   wire                           chan_a_dsp_acc_bank18;
   wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank18;
   wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank18;
   wire signed [DSP_P_WIDTH-1:0]  chan_a_dsp_p_bank18;

   wire                           chan_a_dsp_acc_bank19;
   wire signed [DSP_A_WIDTH-1:0]  chan_a_dsp_a_bank19;
   wire signed [DSP_B_WIDTH-1:0]  chan_a_dsp_b_bank19;
   wire signed [DSP_P_WIDTH-1:0]  chan_a_dsp_p_bank19;

   // channel B
   wire                           chan_b_dsp_acc_bank0;
   wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank0;
   wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank0;
   wire signed [DSP_P_WIDTH-1:0]  chan_b_dsp_p_bank0;

   wire                           chan_b_dsp_acc_bank1;
   wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank1;
   wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank1;
   wire signed [DSP_P_WIDTH-1:0]  chan_b_dsp_p_bank1;

   wire                           chan_b_dsp_acc_bank2;
   wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank2;
   wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank2;
   wire signed [DSP_P_WIDTH-1:0]  chan_b_dsp_p_bank2;

   wire                           chan_b_dsp_acc_bank3;
   wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank3;
   wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank3;
   wire signed [DSP_P_WIDTH-1:0]  chan_b_dsp_p_bank3;

   wire                           chan_b_dsp_acc_bank4;
   wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank4;
   wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank4;
   wire signed [DSP_P_WIDTH-1:0]  chan_b_dsp_p_bank4;

   wire                           chan_b_dsp_acc_bank5;
   wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank5;
   wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank5;
   wire signed [DSP_P_WIDTH-1:0]  chan_b_dsp_p_bank5;

   wire                           chan_b_dsp_acc_bank6;
   wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank6;
   wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank6;
   wire signed [DSP_P_WIDTH-1:0]  chan_b_dsp_p_bank6;

   wire                           chan_b_dsp_acc_bank7;
   wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank7;
   wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank7;
   wire signed [DSP_P_WIDTH-1:0]  chan_b_dsp_p_bank7;

   wire                           chan_b_dsp_acc_bank8;
   wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank8;
   wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank8;
   wire signed [DSP_P_WIDTH-1:0]  chan_b_dsp_p_bank8;

   wire                           chan_b_dsp_acc_bank9;
   wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank9;
   wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank9;
   wire signed [DSP_P_WIDTH-1:0]  chan_b_dsp_p_bank9;

   wire                           chan_b_dsp_acc_bank10;
   wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank10;
   wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank10;
   wire signed [DSP_P_WIDTH-1:0]  chan_b_dsp_p_bank10;

   wire                           chan_b_dsp_acc_bank11;
   wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank11;
   wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank11;
   wire signed [DSP_P_WIDTH-1:0]  chan_b_dsp_p_bank11;

   wire                           chan_b_dsp_acc_bank12;
   wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank12;
   wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank12;
   wire signed [DSP_P_WIDTH-1:0]  chan_b_dsp_p_bank12;

   wire                           chan_b_dsp_acc_bank13;
   wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank13;
   wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank13;
   wire signed [DSP_P_WIDTH-1:0]  chan_b_dsp_p_bank13;

   wire                           chan_b_dsp_acc_bank14;
   wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank14;
   wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank14;
   wire signed [DSP_P_WIDTH-1:0]  chan_b_dsp_p_bank14;

   wire                           chan_b_dsp_acc_bank15;
   wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank15;
   wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank15;
   wire signed [DSP_P_WIDTH-1:0]  chan_b_dsp_p_bank15;

   wire                           chan_b_dsp_acc_bank16;
   wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank16;
   wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank16;
   wire signed [DSP_P_WIDTH-1:0]  chan_b_dsp_p_bank16;

   wire                           chan_b_dsp_acc_bank17;
   wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank17;
   wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank17;
   wire signed [DSP_P_WIDTH-1:0]  chan_b_dsp_p_bank17;

   wire                           chan_b_dsp_acc_bank18;
   wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank18;
   wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank18;
   wire signed [DSP_P_WIDTH-1:0]  chan_b_dsp_p_bank18;

   wire                           chan_b_dsp_acc_bank19;
   wire signed [DSP_A_WIDTH-1:0]  chan_b_dsp_a_bank19;
   wire signed [DSP_B_WIDTH-1:0]  chan_b_dsp_b_bank19;
   wire signed [DSP_P_WIDTH-1:0]  chan_b_dsp_p_bank19;

   fir_poly_2channel dut (
      .clk                   (clk),
      .rst_n                 (rst_n),
      .clk_2mhz_pos_en       (clk_2mhz_pos_en),
      .din_a                 (sample_in),
      .din_b                 (sample_in),
      .dout_a                (dout_a),
      .dout_b                (dout_b),
      .dvalid                (dvalid),

      .chan_a_dsp_acc_bank0  (chan_a_dsp_acc_bank0),
      .chan_a_dsp_a_bank0    (chan_a_dsp_a_bank0),
      .chan_a_dsp_b_bank0    (chan_a_dsp_b_bank0),
      .chan_a_dsp_p_bank0    (chan_a_dsp_p_bank0),

      .chan_a_dsp_acc_bank1  (chan_a_dsp_acc_bank1),
      .chan_a_dsp_a_bank1    (chan_a_dsp_a_bank1),
      .chan_a_dsp_b_bank1    (chan_a_dsp_b_bank1),
      .chan_a_dsp_p_bank1    (chan_a_dsp_p_bank1),

      .chan_a_dsp_acc_bank2  (chan_a_dsp_acc_bank2),
      .chan_a_dsp_a_bank2    (chan_a_dsp_a_bank2),
      .chan_a_dsp_b_bank2    (chan_a_dsp_b_bank2),
      .chan_a_dsp_p_bank2    (chan_a_dsp_p_bank2),

      .chan_a_dsp_acc_bank3  (chan_a_dsp_acc_bank3),
      .chan_a_dsp_a_bank3    (chan_a_dsp_a_bank3),
      .chan_a_dsp_b_bank3    (chan_a_dsp_b_bank3),
      .chan_a_dsp_p_bank3    (chan_a_dsp_p_bank3),

      .chan_a_dsp_acc_bank4  (chan_a_dsp_acc_bank4),
      .chan_a_dsp_a_bank4    (chan_a_dsp_a_bank4),
      .chan_a_dsp_b_bank4    (chan_a_dsp_b_bank4),
      .chan_a_dsp_p_bank4    (chan_a_dsp_p_bank4),

      .chan_a_dsp_acc_bank5  (chan_a_dsp_acc_bank5),
      .chan_a_dsp_a_bank5    (chan_a_dsp_a_bank5),
      .chan_a_dsp_b_bank5    (chan_a_dsp_b_bank5),
      .chan_a_dsp_p_bank5    (chan_a_dsp_p_bank5),

      .chan_a_dsp_acc_bank6  (chan_a_dsp_acc_bank6),
      .chan_a_dsp_a_bank6    (chan_a_dsp_a_bank6),
      .chan_a_dsp_b_bank6    (chan_a_dsp_b_bank6),
      .chan_a_dsp_p_bank6    (chan_a_dsp_p_bank6),

      .chan_a_dsp_acc_bank7  (chan_a_dsp_acc_bank7),
      .chan_a_dsp_a_bank7    (chan_a_dsp_a_bank7),
      .chan_a_dsp_b_bank7    (chan_a_dsp_b_bank7),
      .chan_a_dsp_p_bank7    (chan_a_dsp_p_bank7),

      .chan_a_dsp_acc_bank8  (chan_a_dsp_acc_bank8),
      .chan_a_dsp_a_bank8    (chan_a_dsp_a_bank8),
      .chan_a_dsp_b_bank8    (chan_a_dsp_b_bank8),
      .chan_a_dsp_p_bank8    (chan_a_dsp_p_bank8),

      .chan_a_dsp_acc_bank9  (chan_a_dsp_acc_bank9),
      .chan_a_dsp_a_bank9    (chan_a_dsp_a_bank9),
      .chan_a_dsp_b_bank9    (chan_a_dsp_b_bank9),
      .chan_a_dsp_p_bank9    (chan_a_dsp_p_bank9),

      .chan_a_dsp_acc_bank10 (chan_a_dsp_acc_bank10),
      .chan_a_dsp_a_bank10   (chan_a_dsp_a_bank10),
      .chan_a_dsp_b_bank10   (chan_a_dsp_b_bank10),
      .chan_a_dsp_p_bank10   (chan_a_dsp_p_bank10),

      .chan_a_dsp_acc_bank11 (chan_a_dsp_acc_bank11),
      .chan_a_dsp_a_bank11   (chan_a_dsp_a_bank11),
      .chan_a_dsp_b_bank11   (chan_a_dsp_b_bank11),
      .chan_a_dsp_p_bank11   (chan_a_dsp_p_bank11),

      .chan_a_dsp_acc_bank12 (chan_a_dsp_acc_bank12),
      .chan_a_dsp_a_bank12   (chan_a_dsp_a_bank12),
      .chan_a_dsp_b_bank12   (chan_a_dsp_b_bank12),
      .chan_a_dsp_p_bank12   (chan_a_dsp_p_bank12),

      .chan_a_dsp_acc_bank13 (chan_a_dsp_acc_bank13),
      .chan_a_dsp_a_bank13   (chan_a_dsp_a_bank13),
      .chan_a_dsp_b_bank13   (chan_a_dsp_b_bank13),
      .chan_a_dsp_p_bank13   (chan_a_dsp_p_bank13),

      .chan_a_dsp_acc_bank14 (chan_a_dsp_acc_bank14),
      .chan_a_dsp_a_bank14   (chan_a_dsp_a_bank14),
      .chan_a_dsp_b_bank14   (chan_a_dsp_b_bank14),
      .chan_a_dsp_p_bank14   (chan_a_dsp_p_bank14),

      .chan_a_dsp_acc_bank15 (chan_a_dsp_acc_bank15),
      .chan_a_dsp_a_bank15   (chan_a_dsp_a_bank15),
      .chan_a_dsp_b_bank15   (chan_a_dsp_b_bank15),
      .chan_a_dsp_p_bank15   (chan_a_dsp_p_bank15),

      .chan_a_dsp_acc_bank16 (chan_a_dsp_acc_bank16),
      .chan_a_dsp_a_bank16   (chan_a_dsp_a_bank16),
      .chan_a_dsp_b_bank16   (chan_a_dsp_b_bank16),
      .chan_a_dsp_p_bank16   (chan_a_dsp_p_bank16),

      .chan_a_dsp_acc_bank17 (chan_a_dsp_acc_bank17),
      .chan_a_dsp_a_bank17   (chan_a_dsp_a_bank17),
      .chan_a_dsp_b_bank17   (chan_a_dsp_b_bank17),
      .chan_a_dsp_p_bank17   (chan_a_dsp_p_bank17),

      .chan_a_dsp_acc_bank18 (chan_a_dsp_acc_bank18),
      .chan_a_dsp_a_bank18   (chan_a_dsp_a_bank18),
      .chan_a_dsp_b_bank18   (chan_a_dsp_b_bank18),
      .chan_a_dsp_p_bank18   (chan_a_dsp_p_bank18),

      .chan_a_dsp_acc_bank19 (chan_a_dsp_acc_bank19),
      .chan_a_dsp_a_bank19   (chan_a_dsp_a_bank19),
      .chan_a_dsp_b_bank19   (chan_a_dsp_b_bank19),
      .chan_a_dsp_p_bank19   (chan_a_dsp_p_bank19),

         // channel B
      .chan_b_dsp_acc_bank0  (chan_b_dsp_acc_bank0),
      .chan_b_dsp_a_bank0    (chan_b_dsp_a_bank0),
      .chan_b_dsp_b_bank0    (chan_b_dsp_b_bank0),
      .chan_b_dsp_p_bank0    (chan_b_dsp_p_bank0),

      .chan_b_dsp_acc_bank1  (chan_b_dsp_acc_bank1),
      .chan_b_dsp_a_bank1    (chan_b_dsp_a_bank1),
      .chan_b_dsp_b_bank1    (chan_b_dsp_b_bank1),
      .chan_b_dsp_p_bank1    (chan_b_dsp_p_bank1),

      .chan_b_dsp_acc_bank2  (chan_b_dsp_acc_bank2),
      .chan_b_dsp_a_bank2    (chan_b_dsp_a_bank2),
      .chan_b_dsp_b_bank2    (chan_b_dsp_b_bank2),
      .chan_b_dsp_p_bank2    (chan_b_dsp_p_bank2),

      .chan_b_dsp_acc_bank3  (chan_b_dsp_acc_bank3),
      .chan_b_dsp_a_bank3    (chan_b_dsp_a_bank3),
      .chan_b_dsp_b_bank3    (chan_b_dsp_b_bank3),
      .chan_b_dsp_p_bank3    (chan_b_dsp_p_bank3),

      .chan_b_dsp_acc_bank4  (chan_b_dsp_acc_bank4),
      .chan_b_dsp_a_bank4    (chan_b_dsp_a_bank4),
      .chan_b_dsp_b_bank4    (chan_b_dsp_b_bank4),
      .chan_b_dsp_p_bank4    (chan_b_dsp_p_bank4),

      .chan_b_dsp_acc_bank5  (chan_b_dsp_acc_bank5),
      .chan_b_dsp_a_bank5    (chan_b_dsp_a_bank5),
      .chan_b_dsp_b_bank5    (chan_b_dsp_b_bank5),
      .chan_b_dsp_p_bank5    (chan_b_dsp_p_bank5),

      .chan_b_dsp_acc_bank6  (chan_b_dsp_acc_bank6),
      .chan_b_dsp_a_bank6    (chan_b_dsp_a_bank6),
      .chan_b_dsp_b_bank6    (chan_b_dsp_b_bank6),
      .chan_b_dsp_p_bank6    (chan_b_dsp_p_bank6),

      .chan_b_dsp_acc_bank7  (chan_b_dsp_acc_bank7),
      .chan_b_dsp_a_bank7    (chan_b_dsp_a_bank7),
      .chan_b_dsp_b_bank7    (chan_b_dsp_b_bank7),
      .chan_b_dsp_p_bank7    (chan_b_dsp_p_bank7),

      .chan_b_dsp_acc_bank8  (chan_b_dsp_acc_bank8),
      .chan_b_dsp_a_bank8    (chan_b_dsp_a_bank8),
      .chan_b_dsp_b_bank8    (chan_b_dsp_b_bank8),
      .chan_b_dsp_p_bank8    (chan_b_dsp_p_bank8),

      .chan_b_dsp_acc_bank9  (chan_b_dsp_acc_bank9),
      .chan_b_dsp_a_bank9    (chan_b_dsp_a_bank9),
      .chan_b_dsp_b_bank9    (chan_b_dsp_b_bank9),
      .chan_b_dsp_p_bank9    (chan_b_dsp_p_bank9),

      .chan_b_dsp_acc_bank10 (chan_b_dsp_acc_bank10),
      .chan_b_dsp_a_bank10   (chan_b_dsp_a_bank10),
      .chan_b_dsp_b_bank10   (chan_b_dsp_b_bank10),
      .chan_b_dsp_p_bank10   (chan_b_dsp_p_bank10),

      .chan_b_dsp_acc_bank11 (chan_b_dsp_acc_bank11),
      .chan_b_dsp_a_bank11   (chan_b_dsp_a_bank11),
      .chan_b_dsp_b_bank11   (chan_b_dsp_b_bank11),
      .chan_b_dsp_p_bank11   (chan_b_dsp_p_bank11),

      .chan_b_dsp_acc_bank12 (chan_b_dsp_acc_bank12),
      .chan_b_dsp_a_bank12   (chan_b_dsp_a_bank12),
      .chan_b_dsp_b_bank12   (chan_b_dsp_b_bank12),
      .chan_b_dsp_p_bank12   (chan_b_dsp_p_bank12),

      .chan_b_dsp_acc_bank13 (chan_b_dsp_acc_bank13),
      .chan_b_dsp_a_bank13   (chan_b_dsp_a_bank13),
      .chan_b_dsp_b_bank13   (chan_b_dsp_b_bank13),
      .chan_b_dsp_p_bank13   (chan_b_dsp_p_bank13),

      .chan_b_dsp_acc_bank14 (chan_b_dsp_acc_bank14),
      .chan_b_dsp_a_bank14   (chan_b_dsp_a_bank14),
      .chan_b_dsp_b_bank14   (chan_b_dsp_b_bank14),
      .chan_b_dsp_p_bank14   (chan_b_dsp_p_bank14),

      .chan_b_dsp_acc_bank15 (chan_b_dsp_acc_bank15),
      .chan_b_dsp_a_bank15   (chan_b_dsp_a_bank15),
      .chan_b_dsp_b_bank15   (chan_b_dsp_b_bank15),
      .chan_b_dsp_p_bank15   (chan_b_dsp_p_bank15),

      .chan_b_dsp_acc_bank16 (chan_b_dsp_acc_bank16),
      .chan_b_dsp_a_bank16   (chan_b_dsp_a_bank16),
      .chan_b_dsp_b_bank16   (chan_b_dsp_b_bank16),
      .chan_b_dsp_p_bank16   (chan_b_dsp_p_bank16),

      .chan_b_dsp_acc_bank17 (chan_b_dsp_acc_bank17),
      .chan_b_dsp_a_bank17   (chan_b_dsp_a_bank17),
      .chan_b_dsp_b_bank17   (chan_b_dsp_b_bank17),
      .chan_b_dsp_p_bank17   (chan_b_dsp_p_bank17),

      .chan_b_dsp_acc_bank18 (chan_b_dsp_acc_bank18),
      .chan_b_dsp_a_bank18   (chan_b_dsp_a_bank18),
      .chan_b_dsp_b_bank18   (chan_b_dsp_b_bank18),
      .chan_b_dsp_p_bank18   (chan_b_dsp_p_bank18),

      .chan_b_dsp_acc_bank19 (chan_b_dsp_acc_bank19),
      .chan_b_dsp_a_bank19   (chan_b_dsp_a_bank19),
      .chan_b_dsp_b_bank19   (chan_b_dsp_b_bank19),
      .chan_b_dsp_p_bank19   (chan_b_dsp_p_bank19)
   );

   // DSPs
   dsp dsp0 (
      .clk (clk),
      .acc (chan_a_dsp_acc_bank0),
      .a   (chan_a_dsp_a_bank0),
      .b   (chan_a_dsp_b_bank0),
      .p   (chan_a_dsp_p_bank0)
   );

   dsp dsp1 (
      .clk (clk),
      .acc (chan_a_dsp_acc_bank1),
      .a   (chan_a_dsp_a_bank1),
      .b   (chan_a_dsp_b_bank1),
      .p   (chan_a_dsp_p_bank1)
   );

   dsp dsp2 (
      .clk (clk),
      .acc (chan_a_dsp_acc_bank2),
      .a   (chan_a_dsp_a_bank2),
      .b   (chan_a_dsp_b_bank2),
      .p   (chan_a_dsp_p_bank2)
   );

   dsp dsp3 (
      .clk (clk),
      .acc (chan_a_dsp_acc_bank3),
      .a   (chan_a_dsp_a_bank3),
      .b   (chan_a_dsp_b_bank3),
      .p   (chan_a_dsp_p_bank3)
   );

   dsp dsp4 (
      .clk (clk),
      .acc (chan_a_dsp_acc_bank4),
      .a   (chan_a_dsp_a_bank4),
      .b   (chan_a_dsp_b_bank4),
      .p   (chan_a_dsp_p_bank4)
   );

   dsp dsp5 (
      .clk (clk),
      .acc (chan_a_dsp_acc_bank5),
      .a   (chan_a_dsp_a_bank5),
      .b   (chan_a_dsp_b_bank5),
      .p   (chan_a_dsp_p_bank5)
   );

   dsp dsp6 (
      .clk (clk),
      .acc (chan_a_dsp_acc_bank6),
      .a   (chan_a_dsp_a_bank6),
      .b   (chan_a_dsp_b_bank6),
      .p   (chan_a_dsp_p_bank6)
   );

   dsp dsp7 (
      .clk (clk),
      .acc (chan_a_dsp_acc_bank7),
      .a   (chan_a_dsp_a_bank7),
      .b   (chan_a_dsp_b_bank7),
      .p   (chan_a_dsp_p_bank7)
   );

   dsp dsp8 (
      .clk (clk),
      .acc (chan_a_dsp_acc_bank8),
      .a   (chan_a_dsp_a_bank8),
      .b   (chan_a_dsp_b_bank8),
      .p   (chan_a_dsp_p_bank8)
   );

   dsp dsp9 (
      .clk (clk),
      .acc (chan_a_dsp_acc_bank9),
      .a   (chan_a_dsp_a_bank9),
      .b   (chan_a_dsp_b_bank9),
      .p   (chan_a_dsp_p_bank9)
   );

   dsp dsp10 (
      .clk (clk),
      .acc (chan_a_dsp_acc_bank10),
      .a   (chan_a_dsp_a_bank10),
      .b   (chan_a_dsp_b_bank10),
      .p   (chan_a_dsp_p_bank10)
   );

   dsp dsp11 (
      .clk (clk),
      .acc (chan_a_dsp_acc_bank11),
      .a   (chan_a_dsp_a_bank11),
      .b   (chan_a_dsp_b_bank11),
      .p   (chan_a_dsp_p_bank11)
   );

   dsp dsp12 (
      .clk (clk),
      .acc (chan_a_dsp_acc_bank12),
      .a   (chan_a_dsp_a_bank12),
      .b   (chan_a_dsp_b_bank12),
      .p   (chan_a_dsp_p_bank12)
   );

   dsp dsp13 (
      .clk (clk),
      .acc (chan_a_dsp_acc_bank13),
      .a   (chan_a_dsp_a_bank13),
      .b   (chan_a_dsp_b_bank13),
      .p   (chan_a_dsp_p_bank13)
   );

   dsp dsp14 (
      .clk (clk),
      .acc (chan_a_dsp_acc_bank14),
      .a   (chan_a_dsp_a_bank14),
      .b   (chan_a_dsp_b_bank14),
      .p   (chan_a_dsp_p_bank14)
   );

   dsp dsp15 (
      .clk (clk),
      .acc (chan_a_dsp_acc_bank15),
      .a   (chan_a_dsp_a_bank15),
      .b   (chan_a_dsp_b_bank15),
      .p   (chan_a_dsp_p_bank15)
   );

   dsp dsp16 (
      .clk (clk),
      .acc (chan_a_dsp_acc_bank16),
      .a   (chan_a_dsp_a_bank16),
      .b   (chan_a_dsp_b_bank16),
      .p   (chan_a_dsp_p_bank16)
   );

   dsp dsp17 (
      .clk (clk),
      .acc (chan_a_dsp_acc_bank17),
      .a   (chan_a_dsp_a_bank17),
      .b   (chan_a_dsp_b_bank17),
      .p   (chan_a_dsp_p_bank17)
   );

   dsp dsp18 (
      .clk (clk),
      .acc (chan_a_dsp_acc_bank18),
      .a   (chan_a_dsp_a_bank18),
      .b   (chan_a_dsp_b_bank18),
      .p   (chan_a_dsp_p_bank18)
   );

   dsp dsp19 (
      .clk (clk),
      .acc (chan_a_dsp_acc_bank19),
      .a   (chan_a_dsp_a_bank19),
      .b   (chan_a_dsp_b_bank19),
      .p   (chan_a_dsp_p_bank19)
   );

   dsp dsp20 (
      .clk (clk),
      .acc (chan_b_dsp_acc_bank0),
      .a   (chan_b_dsp_a_bank0),
      .b   (chan_b_dsp_b_bank0),
      .p   (chan_b_dsp_p_bank0)
   );

   dsp dsp21 (
      .clk (clk),
      .acc (chan_b_dsp_acc_bank1),
      .a   (chan_b_dsp_a_bank1),
      .b   (chan_b_dsp_b_bank1),
      .p   (chan_b_dsp_p_bank1)
   );

   dsp dsp22 (
      .clk (clk),
      .acc (chan_b_dsp_acc_bank2),
      .a   (chan_b_dsp_a_bank2),
      .b   (chan_b_dsp_b_bank2),
      .p   (chan_b_dsp_p_bank2)
   );

   dsp dsp23 (
      .clk (clk),
      .acc (chan_b_dsp_acc_bank3),
      .a   (chan_b_dsp_a_bank3),
      .b   (chan_b_dsp_b_bank3),
      .p   (chan_b_dsp_p_bank3)
   );

   dsp dsp24 (
      .clk (clk),
      .acc (chan_b_dsp_acc_bank4),
      .a   (chan_b_dsp_a_bank4),
      .b   (chan_b_dsp_b_bank4),
      .p   (chan_b_dsp_p_bank4)
   );

   dsp dsp25 (
      .clk (clk),
      .acc (chan_b_dsp_acc_bank5),
      .a   (chan_b_dsp_a_bank5),
      .b   (chan_b_dsp_b_bank5),
      .p   (chan_b_dsp_p_bank5)
   );

   dsp dsp26 (
      .clk (clk),
      .acc (chan_b_dsp_acc_bank6),
      .a   (chan_b_dsp_a_bank6),
      .b   (chan_b_dsp_b_bank6),
      .p   (chan_b_dsp_p_bank6)
   );

   dsp dsp27 (
      .clk (clk),
      .acc (chan_b_dsp_acc_bank7),
      .a   (chan_b_dsp_a_bank7),
      .b   (chan_b_dsp_b_bank7),
      .p   (chan_b_dsp_p_bank7)
   );

   dsp dsp28 (
      .clk (clk),
      .acc (chan_b_dsp_acc_bank8),
      .a   (chan_b_dsp_a_bank8),
      .b   (chan_b_dsp_b_bank8),
      .p   (chan_b_dsp_p_bank8)
   );

   dsp dsp29 (
      .clk (clk),
      .acc (chan_b_dsp_acc_bank9),
      .a   (chan_b_dsp_a_bank9),
      .b   (chan_b_dsp_b_bank9),
      .p   (chan_b_dsp_p_bank9)
   );

   dsp dsp30 (
      .clk (clk),
      .acc (chan_b_dsp_acc_bank10),
      .a   (chan_b_dsp_a_bank10),
      .b   (chan_b_dsp_b_bank10),
      .p   (chan_b_dsp_p_bank10)
   );

   dsp dsp31 (
      .clk (clk),
      .acc (chan_b_dsp_acc_bank11),
      .a   (chan_b_dsp_a_bank11),
      .b   (chan_b_dsp_b_bank11),
      .p   (chan_b_dsp_p_bank11)
   );

   dsp dsp32 (
      .clk (clk),
      .acc (chan_b_dsp_acc_bank12),
      .a   (chan_b_dsp_a_bank12),
      .b   (chan_b_dsp_b_bank12),
      .p   (chan_b_dsp_p_bank12)
   );

   dsp dsp33 (
      .clk (clk),
      .acc (chan_b_dsp_acc_bank13),
      .a   (chan_b_dsp_a_bank13),
      .b   (chan_b_dsp_b_bank13),
      .p   (chan_b_dsp_p_bank13)
   );

   dsp dsp34 (
      .clk (clk),
      .acc (chan_b_dsp_acc_bank14),
      .a   (chan_b_dsp_a_bank14),
      .b   (chan_b_dsp_b_bank14),
      .p   (chan_b_dsp_p_bank14)
   );

   dsp dsp35 (
      .clk (clk),
      .acc (chan_b_dsp_acc_bank15),
      .a   (chan_b_dsp_a_bank15),
      .b   (chan_b_dsp_b_bank15),
      .p   (chan_b_dsp_p_bank15)
   );

   dsp dsp36 (
      .clk (clk),
      .acc (chan_b_dsp_acc_bank16),
      .a   (chan_b_dsp_a_bank16),
      .b   (chan_b_dsp_b_bank16),
      .p   (chan_b_dsp_p_bank16)
   );

   dsp dsp37 (
      .clk (clk),
      .acc (chan_b_dsp_acc_bank17),
      .a   (chan_b_dsp_a_bank17),
      .b   (chan_b_dsp_b_bank17),
      .p   (chan_b_dsp_p_bank17)
   );

   dsp dsp38 (
      .clk (clk),
      .acc (chan_b_dsp_acc_bank18),
      .a   (chan_b_dsp_a_bank18),
      .b   (chan_b_dsp_b_bank18),
      .p   (chan_b_dsp_p_bank18)
   );

   dsp dsp39 (
      .clk (clk),
      .acc (chan_b_dsp_acc_bank19),
      .a   (chan_b_dsp_a_bank19),
      .b   (chan_b_dsp_b_bank19),
      .p   (chan_b_dsp_p_bank19)
   );

endmodule

`endif
// Local Variables:
// flycheck-verilator-include-path:("/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/unimacro/"
//                                  "/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/"
//                                  "/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/unisims/")
// End:
