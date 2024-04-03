#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	z = {
		greet = w: "hello, "+w;
		add   = a: b: a + b;
	};
	a = 3;
	x = {
		inherit a;
		inherit (z) greet add;
		n = 3;
		m = 4;
		set = (this: f: v: this //{
			"${f}" = v;
		});
	};
	y = (x.set x "n" 42);
in
	deepSeq y y
