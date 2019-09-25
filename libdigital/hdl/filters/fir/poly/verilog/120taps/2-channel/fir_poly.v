`default_nettype none

// TODO consider using a bandpass filter instead of lowpass filter for
// the FPGA.

`include "bank.v"

module fir_poly #(
   parameter N_TAPS         = 120, /* total number of taps */
   parameter M              = 20,  /* decimation factor */
   parameter M_LOG2         = 5,
   parameter BANK_LEN       = 6,   /* N_TAPS/M */
   parameter BANK_LEN_LOG2  = 3,   /* bits needed to hold a BANK_LEN counter */
   parameter INPUT_WIDTH    = 12,
   parameter TAP_WIDTH      = 16,
   parameter INTERNAL_WIDTH = 35,
   parameter NORM_SHIFT     = 4,
   parameter OUTPUT_WIDTH   = 14
) (
   input wire                           clk,
   input wire                           rst_n,
   input wire                           clk_2mhz_pos_en,
   input wire signed [INPUT_WIDTH-1:0]  din,
   output reg signed [OUTPUT_WIDTH-1:0] dout,
   output reg                           dvalid,
   input wire signed [M_LOG2:0]         tap_addr,
   input wire signed [TAP_WIDTH-1:0]    tap0,
   input wire signed [TAP_WIDTH-1:0]    tap1,
   input wire signed [TAP_WIDTH-1:0]    tap2,
   input wire signed [TAP_WIDTH-1:0]    tap3,
   input wire signed [TAP_WIDTH-1:0]    tap4,
   input wire signed [TAP_WIDTH-1:0]    tap5,
   input wire signed [TAP_WIDTH-1:0]    tap6,
   input wire signed [TAP_WIDTH-1:0]    tap7,
   input wire signed [TAP_WIDTH-1:0]    tap8,
   input wire signed [TAP_WIDTH-1:0]    tap9,
   input wire signed [TAP_WIDTH-1:0]    tap10,
   input wire signed [TAP_WIDTH-1:0]    tap11,
   input wire signed [TAP_WIDTH-1:0]    tap12,
   input wire signed [TAP_WIDTH-1:0]    tap13,
   input wire signed [TAP_WIDTH-1:0]    tap14,
   input wire signed [TAP_WIDTH-1:0]    tap15,
   input wire signed [TAP_WIDTH-1:0]    tap16,
   input wire signed [TAP_WIDTH-1:0]    tap17,
   input wire signed [TAP_WIDTH-1:0]    tap18,
   input wire signed [TAP_WIDTH-1:0]    tap19
);

   // Data is first passed through a shift register at the base clock
   // rate. The first polyphase bank gets its data directly from the
   // input and therefore doesn't need a shift register.
   reg signed [INPUT_WIDTH-1:0]         shift_reg [0:M-2];

   integer                              i;
   always @(posedge clk) begin
      if (!rst_n) begin
         for (i=0; i<M-1; i=i+1)
           shift_reg[i] <= {INPUT_WIDTH{1'b0}};
      end else begin
         shift_reg[0] <= din;
         for (i=1; i<M-1; i=i+1)
           shift_reg[i] <= shift_reg[i-1];
      end
   end

   wire signed [INTERNAL_WIDTH-1:0] bank_dout [0:M-1];

   bank #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .M_LOG2         (M_LOG2),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .OUTPUT_WIDTH   (INTERNAL_WIDTH)
   ) bank0 (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (din),
      .dout            (bank_dout[0]),
      .tap_addr        (tap_addr),
      .tap             (tap0)
   );

   bank #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .M_LOG2         (M_LOG2),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .OUTPUT_WIDTH   (INTERNAL_WIDTH)
   ) bank1 (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[0]),
      .dout            (bank_dout[1]),
      .tap_addr        (tap_addr),
      .tap             (tap1)
   );

   bank #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .M_LOG2         (M_LOG2),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .OUTPUT_WIDTH   (INTERNAL_WIDTH)
   ) bank2 (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[1]),
      .dout            (bank_dout[2]),
      .tap_addr        (tap_addr),
      .tap             (tap2)
   );

   bank #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .M_LOG2         (M_LOG2),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .OUTPUT_WIDTH   (INTERNAL_WIDTH)
   ) bank3 (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[2]),
      .dout            (bank_dout[3]),
      .tap_addr        (tap_addr),
      .tap             (tap3)
   );

   bank #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .M_LOG2         (M_LOG2),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .OUTPUT_WIDTH   (INTERNAL_WIDTH)
   ) bank4 (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[3]),
      .dout            (bank_dout[4]),
      .tap_addr        (tap_addr),
      .tap             (tap4)
   );

   bank #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .M_LOG2         (M_LOG2),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .OUTPUT_WIDTH   (INTERNAL_WIDTH)
   ) bank5 (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[4]),
      .dout            (bank_dout[5]),
      .tap_addr        (tap_addr),
      .tap             (tap5)
   );

   bank #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .M_LOG2         (M_LOG2),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .OUTPUT_WIDTH   (INTERNAL_WIDTH)
   ) bank6 (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[5]),
      .dout            (bank_dout[6]),
      .tap_addr        (tap_addr),
      .tap             (tap6)
   );

   bank #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .M_LOG2         (M_LOG2),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .OUTPUT_WIDTH   (INTERNAL_WIDTH)
   ) bank7 (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[6]),
      .dout            (bank_dout[7]),
      .tap_addr        (tap_addr),
      .tap             (tap7)
   );

   bank #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .M_LOG2         (M_LOG2),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .OUTPUT_WIDTH   (INTERNAL_WIDTH)
   ) bank8 (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[7]),
      .dout            (bank_dout[8]),
      .tap_addr        (tap_addr),
      .tap             (tap8)
   );

   bank #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .M_LOG2         (M_LOG2),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .OUTPUT_WIDTH   (INTERNAL_WIDTH)
   ) bank9 (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[8]),
      .dout            (bank_dout[9]),
      .tap_addr        (tap_addr),
      .tap             (tap9)
   );

   bank #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .M_LOG2         (M_LOG2),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .OUTPUT_WIDTH   (INTERNAL_WIDTH)
   ) bank10 (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[9]),
      .dout            (bank_dout[10]),
      .tap_addr        (tap_addr),
      .tap             (tap10)
   );

   bank #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .M_LOG2         (M_LOG2),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .OUTPUT_WIDTH   (INTERNAL_WIDTH)
   ) bank11 (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[10]),
      .dout            (bank_dout[11]),
      .tap_addr        (tap_addr),
      .tap             (tap11)
   );

   bank #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .M_LOG2         (M_LOG2),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .OUTPUT_WIDTH   (INTERNAL_WIDTH)
   ) bank12 (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[11]),
      .dout            (bank_dout[12]),
      .tap_addr        (tap_addr),
      .tap             (tap12)
   );

   bank #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .M_LOG2         (M_LOG2),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .OUTPUT_WIDTH   (INTERNAL_WIDTH)
   ) bank13 (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[12]),
      .dout            (bank_dout[13]),
      .tap_addr        (tap_addr),
      .tap             (tap13)
   );

   bank #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .M_LOG2         (M_LOG2),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .OUTPUT_WIDTH   (INTERNAL_WIDTH)
   ) bank14 (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[13]),
      .dout            (bank_dout[14]),
      .tap_addr        (tap_addr),
      .tap             (tap14)
   );

   bank #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .M_LOG2         (M_LOG2),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .OUTPUT_WIDTH   (INTERNAL_WIDTH)
   ) bank15 (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[14]),
      .dout            (bank_dout[15]),
      .tap_addr        (tap_addr),
      .tap             (tap15)
   );

   bank #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .M_LOG2         (M_LOG2),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .OUTPUT_WIDTH   (INTERNAL_WIDTH)
   ) bank16 (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[15]),
      .dout            (bank_dout[16]),
      .tap_addr        (tap_addr),
      .tap             (tap16)
   );

   bank #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .M_LOG2         (M_LOG2),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .OUTPUT_WIDTH   (INTERNAL_WIDTH)
   ) bank17 (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[16]),
      .dout            (bank_dout[17]),
      .tap_addr        (tap_addr),
      .tap             (tap17)
   );

   bank #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .M_LOG2         (M_LOG2),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .OUTPUT_WIDTH   (INTERNAL_WIDTH)
   ) bank18 (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[17]),
      .dout            (bank_dout[18]),
      .tap_addr        (tap_addr),
      .tap             (tap18)
   );

   bank #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .M_LOG2         (M_LOG2),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .OUTPUT_WIDTH   (INTERNAL_WIDTH)
   ) bank19 (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[18]),
      .dout            (bank_dout[19]),
      .tap_addr        (tap_addr),
      .tap             (tap19)
   );

   wire signed [INTERNAL_WIDTH-1:0] out_tmp = bank_dout[0]
        + bank_dout[1]
        + bank_dout[2]
        + bank_dout[3]
        + bank_dout[4]
        + bank_dout[5]
        + bank_dout[6]
        + bank_dout[7]
        + bank_dout[8]
        + bank_dout[9]
        + bank_dout[10]
        + bank_dout[11]
        + bank_dout[12]
        + bank_dout[13]
        + bank_dout[14]
        + bank_dout[15]
        + bank_dout[16]
        + bank_dout[17]
        + bank_dout[18]
        + bank_dout[19];

   localparam DROP_LSB_BITS = TAP_WIDTH+NORM_SHIFT;
   localparam DROP_MSB_BITS = INTERNAL_WIDTH-DROP_LSB_BITS-OUTPUT_WIDTH;
   // convergent rounding
   wire signed [INTERNAL_WIDTH-1:0] out_rounded = out_tmp
        + {{DROP_LSB_BITS{1'b0}},
           out_tmp[INTERNAL_WIDTH-DROP_LSB_BITS],
           {INTERNAL_WIDTH-DROP_LSB_BITS-1{!out_tmp[INTERNAL_WIDTH-DROP_LSB_BITS]}}};

   wire signed [INTERNAL_WIDTH-DROP_MSB_BITS-1:0] out_drop_msb = out_rounded[INTERNAL_WIDTH-DROP_MSB_BITS-1:0];

   reg                                            dvalid_delay;

   // compute the sum of all bank outputs
   always @(posedge clk) begin
      if (!rst_n) begin
         dvalid <= 1'b0;
         dvalid_delay <= 1'b0;
      end else begin
         if (clk_2mhz_pos_en) begin
            if (dvalid_delay)
              dvalid <= 1'b1;
            else
              dvalid_delay <= 1'b1;

            // dout   <= out_drop_msb[INTERNAL_WIDTH-DROP_MSB_BITS-1:DROP_LSB_BITS];
            // TODO I'm not rounding well, which could give this a bit of a bias.
            dout     <= {out_tmp[INTERNAL_WIDTH-1], out_tmp[DROP_LSB_BITS+OUTPUT_WIDTH-3:DROP_LSB_BITS-1]};
         end
      end
   end

endmodule
// Local Variables:
// flycheck-verilator-include-path:("/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/unimacro/"
//                                  "/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/"
//                                  "/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/unisims/")
// End:
