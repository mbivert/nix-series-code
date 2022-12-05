#!/bin/nix-instantiate
with builtins;
with (import ./list.nix);
with (import ./list-lib.nix);
let
	zeroes = cons 0 (zeroes);
	take   = n: xs: let aux = acc: xs: i:
		if i == n then
			acc
		else
			aux (cons (car xs) acc) (cdr xs) (i + 1)
		; in aux nil xs 0;
	xs = take 5 zeroes;
in
	trace(print xs)
	"ok"


