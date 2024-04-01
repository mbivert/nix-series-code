#!/bin/nix-instantiate --eval
with builtins;
let
	cons   = h: t: [h t];
	car    = xs: elemAt xs 0;
	cdr    = xs: elemAt xs 1;

	zeroes = cons 0 (zeroes);

	tape  = b: e: a: [b e a];
	prev  = xs: elemAt xs 0;
	elem  = xs: elemAt xs 1;
	next  = xs: elemAt xs 2;

	right = t:    tape (cons (elem t) (prev t)) (car (next t)) (cdr (next t));
	left  = t:    tape (cdr (prev t)) (car (prev t)) (cons (elem t) (next t));

	# Obviously, there are other ways of altering the current cell,
	# this is good enough for us
	alter = t: n: tape (prev t) ((elem t) + n) (next t);

	start = tape zeroes 0 zeroes;
	mem   = alter (left (left (alter (right (alter start 5)) 3))) 1;
in
	trace(deepSeq mem mem)
	"ok"
