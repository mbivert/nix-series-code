#!/bin/nix-instantiate --eval
with builtins;

# This file contains the new, church boolean-based list
# implementation
with (import ./list-bool.nix);
let
	range = n: m: let aux = acc: i:
		if i < n then
			acc
		else
			aux (cons i acc) (i - 1)
		; in aux nil m;

	foldl = f: s: xs: let aux = acc: xs:
			if isEmpty xs then acc
			else aux (f acc (car xs)) (cdr xs)
		;in aux s xs;

	isMember = e: foldl (acc: x: if x == e then true else acc) false;
	length   = foldl (acc: _: acc + 1) 0;
	print    = xs: "["+(foldl (acc: x:
			let
				y = if x == nil then "[]" else if typeOf x == "lambda"
					then (print x) else "${toString x}";
			in
				acc+" ${y} "
		) "" xs)+"]";
	reverse = foldl (acc: x: (cons x acc)) nil;
	append  = xs: ys: foldl (acc: x: (cons x acc)) ys (reverse xs);
	map     = f: xs: reverse (foldl (acc: x: (cons (f x) acc)) nil xs);
	foldr3  = f: s: xs: ((foldl (acc: x: (y: acc (f x y))) (x: x) xs) s);
	map3    = f: xs: foldr3 (x: acc: cons (f x) acc) nil xs;
in
	trace(isMember 3 (range 1 10))
	trace(isMember 0 (range 4 5))
	trace(length (range 1 10))
	trace(length (range 4 5))
	trace(print (reverse (range 3 5)))
	trace(print (append (range 1 2) (range 3 4)))
	trace(print (map (x: x * x) (range 1 5)))
	trace(print (cons
			(cons (range 1 3) (cons (range 4 6) nil))
			(cons (cons 7 nil) nil)))
	trace(print(map3 (x: x+2) (range 1 5)))
	"ok"
