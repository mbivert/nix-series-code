#!/bin/nix-instantiate
with builtins;
let
	cons = h: t: (x: if x then h else t);
in
	"ok"
