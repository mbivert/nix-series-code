#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	x = {
		n = 3;
		m = 2;
		k = 1;
		l = 3;

		# There are a few equivalent ways to access the values
		# corresponding to a given attribute in a set.
		f = (this: let s = "l"; in
			this."n" + (getAttr "m" this) + this.k + this."${s}"
		);
	};
in x.f(x)
