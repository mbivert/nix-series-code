#!/usr/bin/env -S nix-instantiate --eval
with builtins;
with (import ./list.nix);
with (import ./list-lib.nix);
let
	foldl = f: s: xs: let aux = acc: xs:
			if isEmpty xs then acc
			else aux (f acc (car xs)) (cdr xs)
		;in aux s xs;

	ys = foldl (acc: x: cons (x * x) acc) nil (range 1 10);

in
	trace(print ys) "OK"
