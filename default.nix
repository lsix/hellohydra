{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation rec {
  name = "hellohydra-${version}";
  version = import ./get_version.nix { inherit pkgs; };
  src = ./.;

  buildInputs = with pkgs; [ autoconf automake ];
  preConfigurePhases = ''runAutoconf'';
  runAutoconf = ''
    autoreconf -if
  '';
}
