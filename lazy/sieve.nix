#!/bin/nix-instantiate --eval
with builtins;
let
	# Any lazy list implementation would do, as
	# long as it respect our "API".
	nil     = null;
	isEmpty = xs: xs == nil;
	cons    = h: t: [h t];
	car     = xs: elemAt xs 0;
	cdr     = xs: elemAt xs 1;

	take   = n: xs: let aux = acc: xs: i:
		if i == n then
			acc
		else
			aux (cons (car xs) acc) (cdr xs) (i + 1)
		; in aux nil xs 0;

	reverse = xs: let aux = acc: xs:
		if isEmpty xs then acc
		else aux (cons (car xs) acc) (cdr xs)
		; in aux nil xs
	;

	toFloat = n: n + 0.1 - 0.1;
	isDiv = i: j: ceil(toFloat(i) / j) * j == i;

	sieve = let aux = p: i:
		if i != 1 && p i then
			# This is the most "correct" variant for the accumulated
			# closure; but both would work OK in this context.
			cons i (aux (j : (j <= i || !(isDiv j i)) && (p j)) (i + 1))
		else
			aux p (i + 1)
		; in aux (i: i != 1) 1;

	xs = reverse (take 10 sieve);
in
	deepSeq xs xs

