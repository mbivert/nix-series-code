#!/bin/nix-instantiate --eval
with builtins;
let
	foldln = g: s: n: let aux = acc: i:
		if i > n then
			acc
		else
			aux (g acc i) (i + 1)
		; in aux s 1;

	foldrn = g: s: n: let aux = acc: i:
		if i == 0 then
			acc
		else
			aux (g i acc) (i - 1)
		; in aux s n;

	# (sub (sub (sub (sub (sub 0 1) 2) 3) 4) 5)
	#	= -1-2-3-4-5
	# (sub 1 (sub 2 (sub 3 (sub 4 (sub 5 0)))))
	#	= 1-(2-(3-(4-5)))
	#	= 1-(2-(3-4+5))
	#	= 1-(2-3+4-5)
	#	= 1-2+3-4+5

	xs = [
		(foldln sub 0 5)
		(foldrn sub 0 5)
	];
in
	deepSeq xs xs
