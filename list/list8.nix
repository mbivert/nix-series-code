#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	map = f: xs: let n = length xs; aux = acc: i:
		if i >= n then
			acc
		else
			aux (acc++[(f (elemAt xs i))]) (i + 1)
		; in aux [] 0;

	map2 = f: xs: if xs == [] then xs
		else [(f (head xs))] ++ (map2 f (tail xs));

	xs = map  (x: 2*x) [1 2 3];
	ys = map2 (y: 2*y) [1 2 3];
in
	trace(deepSeq xs xs)
	trace(deepSeq ys ys)
	"ok"
