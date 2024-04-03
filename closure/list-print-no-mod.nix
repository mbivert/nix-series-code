#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	cons    = h: t: (x: if x then h else t);
	nil     = null;
	isEmpty = l: l == nil;
	access  = x: l: if isEmpty l
		then throw "list is empty"
		else l x
	;
	car = access true;
	cdr = access false;

	# ------------------------------------------------
	print = l: let aux = acc: l:
			let
				h = car l;
				t = cdr l;
				s = if h == nil then "[]" else if typeOf h == "lambda"
					then (print h) else "${toString h}";
			in if isEmpty t then
				acc+"${s}"
			else
				aux (acc+"${s}, ") t
		; in if isEmpty l then "[]" else
		(aux "[" l) + "]";

	xs = cons
		(cons
			(cons 1 (cons 2 (cons 3 nil)))
			(cons (cons 4 (cons 5 (cons 6 nil))) nil))
		(cons (cons 7 nil) nil);
in
	trace (print xs)
	"OK"
