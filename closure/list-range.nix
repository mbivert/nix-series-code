#!/usr/bin/env -S nix-instantiate --eval
with builtins;
with (import ./list.nix);
with (import ./list-lib.nix);
let
	range = n: m: let aux = acc: i:
		if i < n then
			acc
		else
			aux (cons i acc) (i - 1)
		; in aux nil m
	;
	xs = range 3 10;
	ys = range 10 3;
in
	trace(print xs)
	trace(print ys)
	"ok"
