#!/bin/nix-instantiate --eval
with builtins;
with (import ./list.nix);
with (import ./list-lib.nix);
let
	apply = f: xs: foldl (acc: x: acc x) f xs;
	sum3 = apply (x: y: z: x + y + z);
in
	trace(sum3 (cons 1 (cons 2 (cons 3 nil))))
	"ok"
