#!/bin/nix-instantiate
with builtins;
let
	iterate = f: n: [f n]++(iterate f (f n));
	take = n: xs:
		if n == 0 then
			[]
		else
			[(head xs)]++(take (n - 1) (tail xs))
	;
	xs = take 5 (iterate (x: 2*x) 1);
in
	deepSeq xs xs
