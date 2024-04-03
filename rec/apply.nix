#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	apply = f: l: foldl' (x: y: x y) f l;
	concat = x: y: z: (x + y + z);
in
	apply concat ["hello" " " "world"]
