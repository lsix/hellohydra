{ pkgs ? import <nixpkgs> { },
  version ? import ./get_version.nix { inherit pkgs; } }:
pkgs.stdenv.mkDerivation rec {
  name = "hellohydra-${version}";
  src = ./.;

  buildInputs = with pkgs; [ autoconf automake ];
  preConfigurePhases = ''runAutoconf'';
  runAutoconf = ''
    autoreconf -if
  '';
}
