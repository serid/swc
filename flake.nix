# WIP Flake for SWC

{
  description = "SWC";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-22.11";
    };
  };

  outputs = { self, nixpkgs }:
    let system = "x86_64-linux"; in {
      packages."${system}" = {
        # TODO: make build pure
        denopkgs = nixpkgs.legacyPackages."${system}".stdenv.mkDerivation {
          name = "swc";
          deno = nixpkgs.legacyPackages."${system}".deno;

          shellHook = ''echo 10'';

          inherit system;
        };

        default = nixpkgs.legacyPackages."${system}".mkShell {
          name = "swc-shell";

          shellHook = ''
          git submodule update --init --recursive
          rustup target add wasm32-wasi
          echo 10
          '';

          inherit system;
        };

        myPlainDerivation = derivation {
          name = "swc";
          builder = "${nixpkgs.legacyPackages."${system}".bash}/bin/bash";
          args = [ ./x.sh ];

          inherit system;
        };
      };
    };
}
