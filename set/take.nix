#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	take = n: xs: (foldl' (acc: x:
		if acc.m >= n then acc
		else { m = (acc.m + 1); r = acc.r ++ [x]; }
	) { m = 0; r = []; } xs).r;

	xs = take 5 [1 2];
	ys = take 9 [1 2 3 4 5];
in
	trace(deepSeq xs xs)
	trace(deepSeq ys ys)
	"ok"

