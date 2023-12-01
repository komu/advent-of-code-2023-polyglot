#!/usr/bin/env nix-shell
#! nix-shell -i bash --pure
#! nix-shell -p nodejs
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/293822e55ec1.tar.gz

npm install
npx tsc day1.ts
