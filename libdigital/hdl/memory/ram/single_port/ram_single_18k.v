`default_nettype none

module ram_single_18k #(
   parameter INITFILE      = "",
   parameter ADDRESS_WIDTH = 7,
   parameter DATA_WIDTH    = 16
) (
   input wire                          clk,
   input wire                          en,
   input wire                          we,
   input wire [ADDRESS_WIDTH-1:0]      addr,
   input wire signed [DATA_WIDTH-1:0]  di,
   output wire signed [DATA_WIDTH-1:0] data_o
);

   // TODO the address and write enable widths are incorrect. See the
   // Xilinx table for how to fix.
   BRAM_SINGLE_MACRO #(
      .BRAM_SIZE   ("18Kb"),
      .DEVICE      ("7SERIES"),
      .DO_REG      (0),
      .WRITE_WIDTH (DATA_WIDTH),
      .READ_WIDTH  (DATA_WIDTH),
      .INIT_FILE   (INITFILE),
      .WRITE_MODE  ("NO_CHANGE")
   ) BRAM (
      .DO   (data_o),
      .DI   (di),
      .ADDR (addr),
      .CLK  (clk),
      .EN   (en),
      .RST  (1'b0),
      .WE   (we)
   );

endmodule // rom
// Local Variables:
// flycheck-verilator-include-path:("/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/unimacro/"
//                                  "/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/"
//                                  "/home/matt/.nix-profile/opt/Vivado/2017.2/data/verilog/src/unisims/")
// End:
