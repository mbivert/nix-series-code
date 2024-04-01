#!/bin/nix-instantiate --eval
with builtins;
with (import ./list.nix);
with (import ./list-lib.nix);
let
	map = f: xs:
		if isEmpty xs then xs
		else cons (f (car xs)) (map f (cdr xs))
	;

	# Again, I'm not sure this can be implemented with
	# an accumulator, without using reverse. Though,
	# we may use append instead of cons within our
	# implementation.
	map2 = f: xs: let aux = acc: xs:
			if isEmpty xs then
				acc
			else
				aux (cons (f (car xs)) acc) (cdr xs)
		; in reverse (aux nil xs)
	;
in
	# You may want to take a moment to appreciate how
	# much we're stacking on top of our bare-bone,
	# closure-based list implementation.
	#
	# It's really functions all the way down.
	trace(print (map  (x: x * x) (range 12 21)))
	trace(print (map2 (x: x * x) (range 12 21)))
	"ok"
