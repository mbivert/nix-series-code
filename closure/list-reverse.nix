#!/usr/bin/env -S nix-instantiate --eval
with builtins;
with (import ./list.nix);
with (import ./list-lib.nix);
let
	reverse = xs: let aux = acc: xs:
		if isEmpty xs then acc
		else aux (cons (car xs) acc) (cdr xs)
		; in aux nil xs
	;
	xs = range 1 4;
in
	trace(print (reverse xs)) "ok"
