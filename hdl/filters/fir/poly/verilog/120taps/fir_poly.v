`default_nettype none

// TODO consider using a bandpass filter instead of lowpass filter for
// the FPGA.

`include "bank.v"
`include "ram.v"

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
   input wire                           clk_12mhz,
   input wire                           clk_2mhz_pos_en,
   input wire signed [INPUT_WIDTH-1:0]  din,
   output reg signed [OUTPUT_WIDTH-1:0] dout,
   output reg                           dvalid
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

   // instantiate tap ROMs
   reg [M_LOG2:0]     tap_mem_addr;

   always @(posedge clk) begin
      if (!rst_n) begin
         tap_mem_addr <= {M_LOG2{1'b0}};
      end else begin
         tap_mem_addr <= tap_mem_addr + 1'b1;
         if (clk_2mhz_pos_en) begin
            tap_mem_addr <= {M_LOG2{1'b0}};
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

   wire signed [INTERNAL_WIDTH-1:0] bank_dout [0:M-1];

   // TODO add M_LOG2
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
      .clk_3x          (clk_12mhz),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (din),
      .dout            (bank_dout[0]),
      .tap_addr        (tap_mem_addr),
      .tap             (taps0[tap_mem_addr])
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
      .clk_3x          (clk_12mhz),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[0]),
      .dout            (bank_dout[1]),
      .tap_addr        (tap_mem_addr),
      .tap             (taps1[tap_mem_addr])
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
      .clk_3x          (clk_12mhz),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[1]),
      .dout            (bank_dout[2]),
      .tap_addr        (tap_mem_addr),
      .tap             (taps2[tap_mem_addr])
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
      .clk_3x          (clk_12mhz),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[2]),
      .dout            (bank_dout[3]),
      .tap_addr        (tap_mem_addr),
      .tap             (taps3[tap_mem_addr])
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
      .clk_3x          (clk_12mhz),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[3]),
      .dout            (bank_dout[4]),
      .tap_addr        (tap_mem_addr),
      .tap             (taps4[tap_mem_addr])
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
      .clk_3x          (clk_12mhz),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[4]),
      .dout            (bank_dout[5]),
      .tap_addr        (tap_mem_addr),
      .tap             (taps5[tap_mem_addr])
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
      .clk_3x          (clk_12mhz),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[5]),
      .dout            (bank_dout[6]),
      .tap_addr        (tap_mem_addr),
      .tap             (taps6[tap_mem_addr])
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
      .clk_3x          (clk_12mhz),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[6]),
      .dout            (bank_dout[7]),
      .tap_addr        (tap_mem_addr),
      .tap             (taps7[tap_mem_addr])
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
      .clk_3x          (clk_12mhz),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[7]),
      .dout            (bank_dout[8]),
      .tap_addr        (tap_mem_addr),
      .tap             (taps8[tap_mem_addr])
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
      .clk_3x          (clk_12mhz),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[8]),
      .dout            (bank_dout[9]),
      .tap_addr        (tap_mem_addr),
      .tap             (taps9[tap_mem_addr])
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
      .clk_3x          (clk_12mhz),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[9]),
      .dout            (bank_dout[10]),
      .tap_addr        (tap_mem_addr),
      .tap             (taps10[tap_mem_addr])
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
      .clk_3x          (clk_12mhz),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[10]),
      .dout            (bank_dout[11]),
      .tap_addr        (tap_mem_addr),
      .tap             (taps11[tap_mem_addr])
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
      .clk_3x          (clk_12mhz),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[11]),
      .dout            (bank_dout[12]),
      .tap_addr        (tap_mem_addr),
      .tap             (taps12[tap_mem_addr])
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
      .clk_3x          (clk_12mhz),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[12]),
      .dout            (bank_dout[13]),
      .tap_addr        (tap_mem_addr),
      .tap             (taps13[tap_mem_addr])
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
      .clk_3x          (clk_12mhz),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[13]),
      .dout            (bank_dout[14]),
      .tap_addr        (tap_mem_addr),
      .tap             (taps14[tap_mem_addr])
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
      .clk_3x          (clk_12mhz),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[14]),
      .dout            (bank_dout[15]),
      .tap_addr        (tap_mem_addr),
      .tap             (taps15[tap_mem_addr])
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
      .clk_3x          (clk_12mhz),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[15]),
      .dout            (bank_dout[16]),
      .tap_addr        (tap_mem_addr),
      .tap             (taps16[tap_mem_addr])
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
      .clk_3x          (clk_12mhz),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[16]),
      .dout            (bank_dout[17]),
      .tap_addr        (tap_mem_addr),
      .tap             (taps17[tap_mem_addr])
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
      .clk_3x          (clk_12mhz),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[17]),
      .dout            (bank_dout[18]),
      .tap_addr        (tap_mem_addr),
      .tap             (taps18[tap_mem_addr])
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
      .clk_3x          (clk_12mhz),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (shift_reg[18]),
      .dout            (bank_dout[19]),
      .tap_addr        (tap_mem_addr),
      .tap             (taps19[tap_mem_addr])
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

`ifdef SIMULATE

`include "DSP48E1.v"
`include "BRAM_TDP_MACRO.v"
`include "RAMB18E1.v"
`include "PLLE2_BASE.v"
`include "PLLE2_ADV.v"
`include "glbl.v"

`timescale 1ns/1ps
module fir_poly_tb;

   localparam M              = 20; /* downsampling factor */
   localparam M_WIDTH        = 5;
   localparam INPUT_WIDTH    = 12;
   localparam INTERNAL_WIDTH = 35;
   localparam NORM_SHIFT     = 4;
   localparam OUTPUT_WIDTH   = 14;
   localparam TAP_WIDTH      = 16;
   localparam BANK_LEN       = 6; /* number of taps in each polyphase decomposition filter bank */
   localparam BANK_LEN_LOG2  = 3;
   localparam ADC_DATA_WIDTH = 12;
   localparam SAMPLE_LEN     = 10000;

   wire clk_12mhz;
   wire pll_lock;
   reg  clk = 0;
   wire clk_fb;
   reg  rst_n = 0;

   always #12.5 clk = !clk;

   always @(posedge clk) begin
      if (pll_lock)
        rst_n <= 1;
      else
        rst_n <= 0;
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
   wire signed [OUTPUT_WIDTH-1:0] dout;
   wire                           dvalid;
   reg                            sample_in_start = 0;

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
      $dumpfile("tb/fir_poly.vcd");
      $dumpvars(0, fir_poly_tb);
      $dumpvars(0, dut.bank0.shift_reg[0]);

      f = $fopen("tb/sample_out_verilog.txt", "w");

      $readmemh("tb/sample_in.hex", samples);

      #100000 $finish;
   end

   always @(posedge clk) begin
      if (dvalid && clk_2mhz_pos_en) begin
         $fwrite(f, "%d\n", $signed(dout));
      end
   end

   PLLE2_BASE #(
      .CLKFBOUT_MULT  (24),
      .DIVCLK_DIVIDE  (1),
      .CLKOUT0_DIVIDE (80),
      .CLKIN1_PERIOD  (25)
   ) PLLE2_BASE_120mhz (
      .CLKOUT0  (clk_12mhz),
      .LOCKED   (pll_lock),
      .CLKIN1   (clk),
      .RST      (1'b0),
      .CLKFBOUT (clk_fb),
      .CLKFBIN  (clk_fb)
   );

   fir_poly #(
      .M              (M),
      .INPUT_WIDTH    (ADC_DATA_WIDTH),
      .INTERNAL_WIDTH (INTERNAL_WIDTH),
      .NORM_SHIFT     (NORM_SHIFT),
      .OUTPUT_WIDTH   (OUTPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .ROM_SIZE       (ROM_SIZE)
   ) dut (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_12mhz       (clk_12mhz),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (sample_in),
      .dout            (dout),
      .dvalid          (dvalid)
   );

endmodule

`endif
// Local Variables:
// flycheck-verilator-include-path:("/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/unimacro/"
//                                  "/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/"
//                                  "/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/unisims/")
// End:
