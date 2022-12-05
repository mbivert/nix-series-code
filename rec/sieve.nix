#!/bin/nix-instantiate
with builtins;
let
	foldlnseq = x: f: s: n: let aux = acc: i:
		if i > n then
			acc
		else
			aux (f acc (x i)) (i + 1)
		; in aux s 1;

	# foldln is now a special case of foldlnseq
	foldln = foldlnseq (x: x);

	toFloat = n: n + 0.1 - 0.1;
	isDiv = i: j: ceil(toFloat(i) / j) * j == i;

	sieve = n: foldln (p: i:
		if p i then
			trace("${toString i} is prime!")
			(j : !(isDiv j i) && (p j))
		else
			trace("${toString i} is not prime")
			p
	) (i: i != 1) n;
in
	sieve 50
