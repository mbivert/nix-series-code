#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	x = rec {
		n = 3;
		m = n+2;
	};
in deepSeq x x

