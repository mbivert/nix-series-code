#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	nil = null;
	isEmpty = xs: xs == nil;
	cons = x: xs: {
		car = x;
		cdr = xs;
	};
	car = xs: xs.car;
	cdr = xs: xs.cdr;

	zeroes = cons 0 (zeroes);

	# Actually we would need to reverse the output, or to use
	# append instead of cons (more expensive), but it's good
	# enough to demonstrate our point.
	take = n: xs: let aux = acc: xs: i:
		if i == n then
			acc
		else
			aux (cons (car xs) acc) (cdr xs) (i + 1)
		; in aux nil xs 0;
	xs = take 5 zeroes;
in
	deepSeq xs xs

