#!/bin/nix-instantiate --eval
with builtins;
let
	mk = f: x: (y: f x y);
	g  = x: y: x + y;
in
	(mk g 3) 2
