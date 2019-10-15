{ pkgs ? (import <nixpkgs> {} // import <custompkgs> {}) }:

let
  libdigital = pkgs.libdigital;
  mh-python = pkgs.python3.withPackages (ps: with ps; [
    libdigital
  ]);

in
pkgs.mkShell {
  buildInputs = with pkgs; [
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
    python3Packages.xdot
    graphviz
  ];
}
