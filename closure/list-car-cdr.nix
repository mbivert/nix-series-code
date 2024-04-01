#!/bin/nix-instantiate --eval
with builtins;
let
	nil     = null;
	isEmpty = l: l == nil;
	cons    = h: t: (x: if x then h else t);

	access = x: l: if isEmpty l
		then throw "list is empty"
		else l x
	;
	car = access true;
	cdr = access false;

	l = cons 3 nil;
in
	trace(car l)
	trace(cdr l)
	trace(car nil)
	"ok"
