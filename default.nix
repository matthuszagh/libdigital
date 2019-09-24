{}:
let
  python = import ./requirements.nix { inherit pkgs; };
in python.mkDerivation {
  name = "libdigital-0.1.0";
  src = ./.;
  propagatedBuildInputs = builtins.attrValues python.packages;
}
