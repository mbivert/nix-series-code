#!/bin/nix-instantiate
with builtins;
with (import ./list.nix);
with (import ./list-lib.nix);
let
	append = xs: ys:
		if isEmpty xs then
			ys
		else
			cons (car xs) (append (cdr xs) ys)
	;

	append2 = xs: ys: let
		sx = reverse xs;
		# Interestingly, this auxiliary function is exactly
		# the same that we've used to implement reverse.
		aux = acc: sx:
			if isEmpty sx then
				acc
			else
				aux (cons (car sx) acc) (cdr sx)
		; in aux ys sx
	;

	xs = range 1 3;
	ys = range 4 6;
in
	trace (print (append2 xs ys)) (cadddr (append xs ys))
