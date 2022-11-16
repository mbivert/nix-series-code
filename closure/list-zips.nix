#!/bin/nix-instantiate --eval
with builtins;
with (import ./list.nix);
with (import ./list-lib.nix);
let
	zipWith = f: xs: ys:
		if isEmpty xs then nil
		else if isEmpty ys then nil
		else cons (f (car xs) (car ys)) (zipWith f (cdr xs) (cdr ys));

	zip = zipWith (x: y: (cons x (cons y nil)));
in
	trace(print(range 1 3))
	trace(print(zipWith (x: y: x + y) (range 1 3) (range 4 6)))
	trace(print(zip (range 1 3) (range 4 6)))
	"ok"
