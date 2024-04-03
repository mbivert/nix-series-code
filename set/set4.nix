#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	x = {
		n = 3;
		m = 4;
		set = (this: f: v: {
			"${f}" = v;
			m      = this.m;
		});
	};
	y = (x.set x "n" 42);
in
	deepSeq y y

