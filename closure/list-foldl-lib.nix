#!/usr/bin/env -S nix-instantiate --eval
with builtins;
with (import ./list.nix);
with (import ./list-lib.nix);
let
	isMember = e: foldl (acc: x: if x == e then true else acc) false;
	length   = foldl (acc: _: acc + 1) 0;
	print    = l: "["+(foldl (acc: x:
			let
				y = if x == nil then "[]" else if typeOf x == "lambda"
					then (print x) else "${toString x}";
			in
				acc+" ${y} "
		) "" l)+"]";

	reverse = foldl (acc: x: (cons x acc)) nil;
	append  = xs: ys: foldl (acc: x: (cons x acc)) ys (reverse xs);
	map     = f: l: reverse (foldl (acc: x: (cons (f x) acc)) nil l);
in
	trace(isMember 3 (range 1 10))
	trace(isMember 0 (range 4 5))
	trace(length (range 1 10))
	trace(length (range 4 5))
	trace(print (reverse (range 3 5)))
	trace(print (append (range 1 2) (range 3 4)))
	trace(print (map (x: x * x) (range 1 5)))
	"ok"