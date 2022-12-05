#!/bin/nix-instantiate --eval
with builtins;
let
	foldln = g: s: n: let aux = acc: i:
		if i > n then
			acc
		else
			aux (g acc i) (i + 1)
		; in aux s 1;

	sumsquare = foldln (s: i: s + (i * i)) 0;

	# 1*1 + 2*2                               = 5;
	# ... + 3*3 + 4*4 + 5*5 = 5 + 9 + 16 + 25 = 55
	# ... + 6*6 + 7*7 + 8*8 +9*9 + 10*10      = 385
	xs = [ (sumsquare 2) (sumsquare 5) (sumsquare 10) ];
in
	deepSeq xs xs
