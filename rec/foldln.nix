#!/bin/nix-instantiate
with builtins;
let
	foldln = f: s: n: let aux = acc: i:
		if i > n then
			acc
		else
			aux (f acc i) (i + 1)
		; in aux s 1;

	sum  = n: foldln add 0 n;
	fact = foldln mul 1;

	xs = [ (sum 10) (fact 5) ];
in
	deepSeq xs xs
