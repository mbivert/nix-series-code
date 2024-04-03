#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	cons = h: t: (x: if x then h else t);
in
	"ok"
