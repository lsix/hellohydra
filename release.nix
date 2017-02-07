# This file is usualy kept in a separate repository.
{ pkgs ? import <nixpkgs> { } }:
let jobs = rec {
      hellohydra = import <hellohydra> { inherit pkgs; };
    };
in jobs
