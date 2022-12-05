#!/bin/nix-instantiate
with builtins;
let
	nil    = null;
	cons   = h: t: [h t];
	car    = xs: elemAt xs 0;
	cdr    = xs: elemAt xs 1;

	# And that's exactly the code we have for the
	# previous version: just the list implementation
	# has changed.
	zeroes = cons 0 (zeroes);
	take   = n: xs: let aux = acc: xs: i:
		if i == n then
			acc
		else
			aux (cons (car xs) acc) (cdr xs) (i + 1)
		; in aux nil xs 0;
	xs = take 5 zeroes;
in
	deepSeq xs xs
