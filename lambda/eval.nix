#!/bin/nix-instantiate
with builtins;
with (import ./substitute.nix);
rec {
	reduce = m: /* trace(pretty m) */ (
		if m.type == "lambda" then
			m // { expr = reduce m.expr; }
		else if m.type == "var" then
			m
		else if m.left.type == "lambda" then
			substitute m.left.expr m.right m.left.bound
		else
			m // { left = reduce m.left; right = reduce m.right; }
	);

	eval = m: let n = reduce m; in
		if n == m then n else eval n;
}