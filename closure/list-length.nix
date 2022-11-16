#!/bin/nix-instantiate --eval
with builtins;
with (import ./list.nix);
let
	length = xs: let aux = n: xs:
		if isEmpty xs then n
		else aux (n + 1) (cdr xs)
	; in aux 0 xs;

	length2 = xs:
		if isEmpty xs then 0
		else 1 + (length2 (cdr xs))
	;

	xs = cons 1 (cons 2 (cons 3 null));
in
	trace(length xs) (length2 xs)

