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
  ];
}
