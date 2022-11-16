#!/bin/nix-instantiate --eval
with builtins;
with (import ./list.nix);
with (import ./list-lib.nix);
let
	/* Hopefully, I got them right... */

	# With an auxiliary function and an acculumator
	foldr = f: s: xs: let aux = acc: xs:
		if isEmpty xs then
			acc
		else
			f (car xs) (aux acc (cdr xs))
		; in aux s xs;

	# Direct recursive formulation
	foldr2 = f: s: xs:
		if isEmpty xs then
			s
		else
			f (car xs) (foldr2 f s (cdr xs));

	# Via foldl
	foldr3 = f: s: xs: ((foldl (acc: x: (y: acc (f x y))) (x: x) xs) s);

	# And here's map, with our foldl-based implementation, for comparison
#	map = f: l: reverse (foldl (acc: x: (cons (f x) acc)) nil l);
	map = f: l: foldr (x: acc: cons (f x) acc) nil l;

	# For tests
	map2 = f: l: foldr2 (x: acc: cons (f x) acc) nil l;
	map3 = f: l: foldr3 (x: acc: cons (f x) acc) nil l;
in
	trace(foldl  sub 0  (range 1 5))
	trace(foldr  sub 0  (range 1 5))
	trace(print(map  (x: x+2) (range 1 5)))
	trace(print(map2 (x: x+2) (range 1 5)))
	trace(print(map3 (x: x+2) (range 1 5)))
	"ok"

