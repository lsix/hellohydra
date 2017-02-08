# This file is usualy kept in a separate repository.
{ pkgs ? import <nixpkgs> { } }:
let jobs = rec {
      hellohydra_version = import <hellohydra/get_version.nix> { inherit pkgs; } ;
      hellohydra = import <hellohydra> { inherit pkgs;
                                         version = hellohydra_version; };
    };
in jobs
