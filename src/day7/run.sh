#!/usr/bin/env nix-shell
#! nix-shell -i bash --pure
#! nix-shell -p ocaml
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/293822e55ec1.tar.gz

ocaml day7.ml
