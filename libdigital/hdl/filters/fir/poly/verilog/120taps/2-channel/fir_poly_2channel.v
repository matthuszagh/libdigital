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
   output wire                           dvalid
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
      .OUTPUT_WIDTH   (OUTPUT_WIDTH)
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
      .tap19           (taps19[tap_mem_addr[BANK_LEN_LOG2-1:0]])
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
      .OUTPUT_WIDTH   (OUTPUT_WIDTH)
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
      .tap19           (taps19[tap_mem_addr[BANK_LEN_LOG2-1:0]])
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

   fir_poly_2channel dut (
      .clk             (clk),
      .rst_n           (rst_n),
      .clk_2mhz_pos_en (clk_2mhz_pos_en),
      .din_a           (sample_in),
      .din_b           (sample_in),
      .dout_a          (dout_a),
      .dout_b          (dout_b),
      .dvalid          (dvalid)
   );

endmodule

`endif
// Local Variables:
// flycheck-verilator-include-path:("/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/unimacro/"
//                                  "/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/"
//                                  "/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/unisims/")
// End:
