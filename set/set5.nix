#!/bin/nix-instantiate --eval
with builtins;
let
	x = {
		n = 3;
		m = 4;
		set = (this: f: v: this // {
			"${f}" = v;
		});
	};
	y = (x.set x "n" 42);
in
	deepSeq y y
