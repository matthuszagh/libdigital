{ pkgs ? (import <nixpkgs> {} // import <custompkgs> {}) }:

let
  libdigital = pkgs.libdigital;
  mh-python = pkgs.python3Full.withPackages (ps: with ps; [
    libdigital
    cocotb
  ]);

in
pkgs.mkShell {
  buildInputs = with pkgs; [
    python3Full # necessary to get PYTHONPATH set
    mh-python
    yosys
    symbiyosys
    verilator
    verilog
    nextpnr
    trellis
    icestorm
    gtkwave
    openocd
    libftdi1
    # python3Packages.xdot # TODO needed?
    graphviz
  ];
}
