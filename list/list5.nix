#!/bin/nix-instantiate --eval
with builtins;
let
	xs = []++[1 2]++[]++[3 4]++[5];
in
	"${toString xs}"
