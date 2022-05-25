{ sources ? import ./sources.nix, pkgs ? import sources.nixpkgs { } }:

with pkgs;

buildEnv {
  name = "elixir-env";
  paths = [ elixir nodejs-16_x postgresql_12 ];
}
