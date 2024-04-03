#!/usr/bin/env -S nix-instantiate --eval
with builtins;
with (import ./list.nix);
with (import ./list-lib.nix);
let
	flatten = foldl (acc: x:
		if typeOf x == "lambda" then
			(append acc x)
		else
			(append acc (cons x nil))
		) nil;

	flatten2 = foldr(x: acc:
		if typeOf x == "lambda" then
			(append x acc)
		else
			cons x acc
		) nil;

	deepFlatten = foldl (acc: x:
		if typeOf x == "lambda" then
			(append acc (deepFlatten x))
		else
			(append acc (cons x nil))
		) nil;
in
	trace(print (flatten  (cons (range 1 3) (cons (range 4 6) (cons 7 nil)))))
	trace(print (flatten2 (cons (range 1 3) (cons (range 4 6) (cons 7 nil)))))
	# deepFlatten should work as flatten on list of lists
	trace(print (deepFlatten (cons (range 1 3) (cons (range 4 6) (cons 7 nil)))))
	# [ [[1 2 3] [4 5 6]] [7] ]
	trace(print (deepFlatten (
		cons
			(cons (range 1 3) (cons (range 4 6) nil))
			(cons (cons 7 nil) nil))))
	"ok"
