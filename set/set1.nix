#!/bin/nix-instantiate
with builtins;
let
	x = {
		n = 3;
		m = n+2;
	};
in deepSeq x x
