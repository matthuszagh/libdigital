`default_nettype none

// TODO consider using a bandpass filter instead of lowpass filter for
// the FPGA.

`include "bank.v"
`include "rom.v"

module fir_poly #(
   parameter N_TAPS         = 1200, /* total number of taps */
   parameter M              = 20,   /* decimation factor */
   parameter BANK_LEN       = 60,   /* N_TAPS/M */
   parameter BANK_LEN_LOG2  = 6,    /* bits needed to hold a BANK_LEN counter */
   parameter INPUT_WIDTH    = 12,
   parameter TAP_WIDTH      = 16,
   parameter INTERNAL_WIDTH = 39,
   parameter NORM_SHIFT     = 4,
   parameter OUTPUT_WIDTH   = 14,
   parameter ROM_SIZE       = 128
) (
   input wire                           clk,
   input wire                           rst_n,
   input wire                           clk_3x,
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
   wire signed [TAP_WIDTH-1:0] tap_mem_dout [0:M-1];
   reg [BANK_LEN_LOG2-1:0]     tap_mem_addr;
   wire [BANK_LEN_LOG2:0]      tap_mem_addr_port1 = {1'b0, tap_mem_addr};
   wire [BANK_LEN_LOG2:0]      tap_mem_addr_port2 = {1'b1, tap_mem_addr};

   // TODO replace with below when PLL issue resolved. This should not
   // work!
   reg                         tap_mem_addr_start;
   reg                         tap_delay;
   always @(posedge clk_3x) begin
      if (!rst_n) begin
         tap_mem_addr_start <= 1'b0;
         tap_delay          <= 1'b0;
         tap_mem_addr       <= {BANK_LEN_LOG2{1'b0}};
      end else begin
         if (clk_2mhz_pos_en) begin
            tap_mem_addr_start <= 1'b1;
         end else begin
            tap_mem_addr_start <= 1'b0;
         end

         if (tap_mem_addr == {BANK_LEN_LOG2{1'b0}}) begin
            if (tap_mem_addr_start) begin
               if (tap_delay)
                 tap_mem_addr <= {{BANK_LEN_LOG2-1{1'b0}}, 1'b1};
               else
                 tap_delay <= 1'b1;
            end
         end else begin
            if (tap_mem_addr == BANK_LEN-1)
              tap_mem_addr <= {BANK_LEN_LOG2{1'b0}};
            else
              tap_mem_addr <= tap_mem_addr + 1'b1;
         end
      end
   end

   // // TODO weird behavior by PLL. This should work.
   // // ensures addresses are lined up with 2mhz clock.
   // reg                         tap_mem_addr_start;
   // always @(posedge clk_3x) begin
   //    if (!rst_n) begin
   //       tap_mem_addr_start <= 1'b0;
   //       tap_mem_addr <= {BANK_LEN_LOG2{1'b0}};
   //    end else begin
   //       if (clk_2mhz_pos_en)
   //         tap_mem_addr_start <= 1'b1;
   //       else
   //         tap_mem_addr_start <= 1'b0;

   //       if (tap_mem_addr == {BANK_LEN_LOG2{1'b0}}) begin
   //          if (tap_mem_addr_start) begin
   //             tap_mem_addr <= {{BANK_LEN_LOG2-1{1'b0}}, 1'b1};
   //          end
   //       end else begin
   //          if (tap_mem_addr == BANK_LEN-1)
   //            tap_mem_addr <= {BANK_LEN_LOG2{1'b0}};
   //          else
   //            tap_mem_addr <= tap_mem_addr + 1'b1;
   //       end
   //    end
   // end

   // Do I need to get better at Verilog or will it seriously not let
   // me wrap these in a generate statement because of the rom
   // files???
   rom #(
      .ROMFILE       ("taps/taps0_1.hex"),
      .ADDRESS_WIDTH (BANK_LEN_LOG2+1),
      .DATA_WIDTH    (TAP_WIDTH),
      .ROM_SIZE      (ROM_SIZE)
   ) taps0_1_rom (
      .clk   (clk_3x),
      .en1   (1'b1),
      .en2   (1'b1),
      .addr1 (tap_mem_addr_port1),
      .addr2 (tap_mem_addr_port2),
      .do1   (tap_mem_dout[0]),
      .do2   (tap_mem_dout[1])
   );

   rom #(
      .ROMFILE       ("taps/taps2_3.hex"),
      .ADDRESS_WIDTH (BANK_LEN_LOG2+1),
      .DATA_WIDTH    (TAP_WIDTH),
      .ROM_SIZE      (ROM_SIZE)
   ) taps2_3_rom (
      .clk   (clk_3x),
      .en1   (1'b1),
      .en2   (1'b1),
      .addr1 (tap_mem_addr_port1),
      .addr2 (tap_mem_addr_port2),
      .do1   (tap_mem_dout[2]),
      .do2   (tap_mem_dout[3])
   );

   rom #(
      .ROMFILE       ("taps/taps4_5.hex"),
      .ADDRESS_WIDTH (BANK_LEN_LOG2+1),
      .DATA_WIDTH    (TAP_WIDTH),
      .ROM_SIZE      (ROM_SIZE)
   ) taps4_5_rom (
      .clk   (clk_3x),
      .en1   (1'b1),
      .en2   (1'b1),
      .addr1 (tap_mem_addr_port1),
      .addr2 (tap_mem_addr_port2),
      .do1   (tap_mem_dout[4]),
      .do2   (tap_mem_dout[5])
   );

   rom #(
      .ROMFILE       ("taps/taps6_7.hex"),
      .ADDRESS_WIDTH (BANK_LEN_LOG2+1),
      .DATA_WIDTH    (TAP_WIDTH),
      .ROM_SIZE      (ROM_SIZE)
   ) taps6_7_rom (
      .clk   (clk_3x),
      .en1   (1'b1),
      .en2   (1'b1),
      .addr1 (tap_mem_addr_port1),
      .addr2 (tap_mem_addr_port2),
      .do1   (tap_mem_dout[6]),
      .do2   (tap_mem_dout[7])
   );

   rom #(
      .ROMFILE       ("taps/taps8_9.hex"),
      .ADDRESS_WIDTH (BANK_LEN_LOG2+1),
      .DATA_WIDTH    (TAP_WIDTH),
      .ROM_SIZE      (ROM_SIZE)
   ) taps8_9_rom (
      .clk   (clk_3x),
      .en1   (1'b1),
      .en2   (1'b1),
      .addr1 (tap_mem_addr_port1),
      .addr2 (tap_mem_addr_port2),
      .do1   (tap_mem_dout[8]),
      .do2   (tap_mem_dout[9])
   );

   rom #(
      .ROMFILE       ("taps/taps10_11.hex"),
      .ADDRESS_WIDTH (BANK_LEN_LOG2+1),
      .DATA_WIDTH    (TAP_WIDTH),
      .ROM_SIZE      (ROM_SIZE)
   ) taps10_11_rom (
      .clk   (clk_3x),
      .en1   (1'b1),
      .en2   (1'b1),
      .addr1 (tap_mem_addr_port1),
      .addr2 (tap_mem_addr_port2),
      .do1   (tap_mem_dout[10]),
      .do2   (tap_mem_dout[11])
   );

   rom #(
      .ROMFILE       ("taps/taps12_13.hex"),
      .ADDRESS_WIDTH (BANK_LEN_LOG2+1),
      .DATA_WIDTH    (TAP_WIDTH),
      .ROM_SIZE      (ROM_SIZE)
   ) taps12_13_rom (
      .clk   (clk_3x),
      .en1   (1'b1),
      .en2   (1'b1),
      .addr1 (tap_mem_addr_port1),
      .addr2 (tap_mem_addr_port2),
      .do1   (tap_mem_dout[12]),
      .do2   (tap_mem_dout[13])
   );

   rom #(
      .ROMFILE       ("taps/taps14_15.hex"),
      .ADDRESS_WIDTH (BANK_LEN_LOG2+1),
      .DATA_WIDTH    (TAP_WIDTH),
      .ROM_SIZE      (ROM_SIZE)
   ) taps14_15_rom (
      .clk   (clk_3x),
      .en1   (1'b1),
      .en2   (1'b1),
      .addr1 (tap_mem_addr_port1),
      .addr2 (tap_mem_addr_port2),
      .do1   (tap_mem_dout[14]),
      .do2   (tap_mem_dout[15])
   );

   rom #(
      .ROMFILE       ("taps/taps16_17.hex"),
      .ADDRESS_WIDTH (BANK_LEN_LOG2+1),
      .DATA_WIDTH    (TAP_WIDTH),
      .ROM_SIZE      (ROM_SIZE)
   ) taps16_17_rom (
      .clk   (clk_3x),
      .en1   (1'b1),
      .en2   (1'b1),
      .addr1 (tap_mem_addr_port1),
      .addr2 (tap_mem_addr_port2),
      .do1   (tap_mem_dout[16]),
      .do2   (tap_mem_dout[17])
   );

   rom #(
      .ROMFILE       ("taps/taps18_19.hex"),
      .ADDRESS_WIDTH (BANK_LEN_LOG2+1),
      .DATA_WIDTH    (TAP_WIDTH),
      .ROM_SIZE      (ROM_SIZE)
   ) taps18_19_rom (
      .clk   (clk_3x),
      .en1   (1'b1),
      .en2   (1'b1),
      .addr1 (tap_mem_addr_port1),
      .addr2 (tap_mem_addr_port2),
      .do1   (tap_mem_dout[18]),
      .do2   (tap_mem_dout[19])
   );

   wire signed [INTERNAL_WIDTH-1:0] bank_dout [0:M-1];

   bank #(
      .N_TAPS         (N_TAPS),
      .M              (M),
      .BANK_LEN       (BANK_LEN),
      .BANK_LEN_LOG2  (BANK_LEN_LOG2),
      .INPUT_WIDTH    (INPUT_WIDTH),
      .TAP_WIDTH      (TAP_WIDTH),
      .OUTPUT_WIDTH   (INTERNAL_WIDTH)
   ) bank (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_3x          (clk_3x),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din             (din),
      .dout            (bank_dout[0]),
      .tap_addr        (tap_mem_addr),
      .tap             (tap_mem_dout[0])
   );

   genvar                           g;
   generate
      for (g=1; g<M; g=g+1) begin
         bank #(
            .N_TAPS         (N_TAPS),
            .M              (M),
            .BANK_LEN       (BANK_LEN),
            .BANK_LEN_LOG2  (BANK_LEN_LOG2),
            .INPUT_WIDTH    (INPUT_WIDTH),
            .TAP_WIDTH      (TAP_WIDTH),
            .OUTPUT_WIDTH   (INTERNAL_WIDTH)
         ) bank (
            .clk             (clk),
            .rst_n           (rst_n),
            .clk_3x          (clk_3x),
            .clk_2mhz_pos_en (clk_2mhz_pos_en),
            .din             (shift_reg[g-1]),
            .dout            (bank_dout[g]),
            .tap_addr        (tap_mem_addr),
            .tap             (tap_mem_dout[g])
         );
      end
   endgenerate

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

   // compute the sum of all bank outputs
   always @(posedge clk) begin
      if (!rst_n) begin
         dvalid <= 1'b0;
      end else begin
         if (clk_2mhz_pos_en) begin
            dvalid <= 1'b1;
            // dout   <= out_drop_msb[INTERNAL_WIDTH-DROP_MSB_BITS-1:DROP_LSB_BITS];
            // TODO I'm not rounding well, which could give this a bit of a bias.
            dout <= {out_tmp[INTERNAL_WIDTH-1], out_tmp[DROP_LSB_BITS+OUTPUT_WIDTH-3:DROP_LSB_BITS-1]};
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
   localparam INTERNAL_WIDTH = 39;
   localparam NORM_SHIFT     = 4;
   localparam OUTPUT_WIDTH   = 14;
   localparam TAP_WIDTH      = 16;
   localparam BANK_LEN       = 60; /* number of taps in each polyphase decomposition filter bank */
   localparam BANK_LEN_LOG2  = 6;
   localparam ROM_SIZE       = 128;
   localparam ADC_DATA_WIDTH = 12;
   localparam SAMPLE_LEN     = 10000;

   wire clk_120mhz;
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
   reg                  clk_2mhz_neg_en = 1'b1;
   reg [4:0]            clk_2mhz_ctr    = 5'd0;
   reg                  clk_4mhz_pos_en = 1'b1;
   reg [3:0]            clk_4mhz_ctr    = 5'd0;

   always @(posedge clk) begin
      if (!rst_n) begin
         clk_2mhz_pos_en <= 1'b0;
         clk_2mhz_neg_en <= 1'b0;
         clk_2mhz_ctr    <= 5'd0;
         clk_4mhz_pos_en <= 1'b0;
         clk_4mhz_ctr    <= 4'd0;
      end else begin
         if (clk_4mhz_ctr == 4'd9) begin
            clk_4mhz_pos_en <= 1'b1;
            clk_4mhz_ctr    <= 4'd0;
         end else begin
            clk_4mhz_pos_en <= 1'b0;
            clk_4mhz_ctr    <= clk_4mhz_ctr + 1'b1;
         end

         if (clk_2mhz_ctr == 5'd9) begin
            clk_2mhz_neg_en <= 1'b1;
            clk_2mhz_pos_en <= 1'b0;
            clk_2mhz_ctr    <= clk_2mhz_ctr + 1'b1;
         end else if (clk_2mhz_ctr == 5'd19) begin
            clk_2mhz_neg_en <= 1'b0;
            clk_2mhz_pos_en <= 1'b1;
            clk_2mhz_ctr    <= 5'd0;
         end else begin
            clk_2mhz_neg_en <= 1'b0;
            clk_2mhz_pos_en <= 1'b0;
            clk_2mhz_ctr    <= clk_2mhz_ctr + 1'b1;
         end
      end
   end

   // 120mhz clock 2mhz clock enable
   reg                  clk_3x_2mhz_pos_en = 1'b0;
   reg [5:0]            clk_3x_2mhz_ctr    = 6'd0;

   always @(posedge clk_120mhz) begin
      if (!rst_n) begin
         clk_3x_2mhz_pos_en <= 1'b0;
         clk_3x_2mhz_ctr    <= 6'd0;
      end else begin
         if (clk_3x_2mhz_ctr == 6'd0) begin
            clk_3x_2mhz_pos_en <= 1'b0;
            clk_3x_2mhz_ctr    <= clk_3x_2mhz_ctr + 1'b1;
         end else if (clk_3x_2mhz_ctr == 6'd59) begin
            clk_3x_2mhz_pos_en <= 1'b1;
            clk_3x_2mhz_ctr    <= 6'd0;
         end else begin
            clk_3x_2mhz_pos_en <= 1'b0;
            clk_3x_2mhz_ctr    <= clk_3x_2mhz_ctr + 1'b1;
         end
      end
   end

   reg signed [INPUT_WIDTH-1:0] samples [0:SAMPLE_LEN-1];
   wire signed [INPUT_WIDTH-1:0] sample_in = samples[ctr];
   wire signed [OUTPUT_WIDTH-1:0] dout;
   wire                           dvalid;
   reg                            sample_in_start = 0;

   integer                      ctr = 0;
   always @(posedge clk) begin
      if (!rst_n) begin
         ctr <= 0;
      end else begin
         if (ctr == 0) begin
            if (clk_2mhz_pos_en)
              ctr <= 1;
         end else begin
            ctr <= ctr + 1;
         end
      end
   end

   integer i, f;
   initial begin
      $dumpfile("tb/fir_poly.vcd");
      $dumpvars(0, fir_poly_tb);
      $dumpvars(0, dut.bank.shift_reg[0]);
      $dumpvars(0, dut.bank.shift_reg[0]);

      f = $fopen("tb/sample_out_verilog.txt", "w");

      $readmemh("tb/sample_in.hex", samples);

      #100000 $finish;
   end

   reg [1:0] wr_delay = 2'd0;
   always @(posedge clk) begin
      if (rst_n && clk_2mhz_pos_en) begin
         if (wr_delay == 2'd2)
           $fwrite(f, "%d\n", $signed(dout));
         else
           wr_delay <= wr_delay + 1'b1;
      end
   end

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
      .clk_3x          (clk_120mhz),
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
