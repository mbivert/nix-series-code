#!/bin/nix-instantiate
with builtins;
let
	foldlnseq = x: f: s: n: let aux = acc: i:
		if i > n then
			acc
		else
			aux (f acc (x i)) (i + 1)
		; in aux s 1;

	foldlnp = p: f:
		foldlnseq
			(i: if p(i) then i else null)
			(x: y: if y == null then x else f x y);

	foldln = foldlnseq (x: x);

	toFloat = n: n + 0.1 - 0.1;
	isDiv = i: j: ceil(toFloat(i) / j) * j == i;

	sieve = n: foldln (p: i:
		if i != 1 && p i then
			(j : (j <= i || !(isDiv j i)) && (p j))
		else p
	) (i: i != 1) n;

	foldlprime = f: s: n: foldlnp (sieve n) f s n;
in
	# The value is OK for for 5 and 10; I guess it's OK
	# for 100
	foldlprime (x: y: x + (y*y)) 0 100
