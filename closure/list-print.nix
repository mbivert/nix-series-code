#!/bin/nix-instantiate
with builtins;
with (import ./list.nix);
let
	x = nil;
	y = cons 3 nil;
	# This list is now invalid
#	z = cons "hello" (cons 3 (cons (x: x) nil));
	# But we can now construct lists of lists:
	w = cons nil (cons nil nil);
	t = cons
		(cons
			(cons 1 (cons 2 (cons 3 nil)))
			(cons (cons 4 (cons 5 (cons 6 nil))) nil))
		(cons (cons 7 nil) nil);

	print = xs: let aux = acc: xs:
			let
				h = car xs;
				t = cdr xs;
				s = if h == nil then "[]" else if typeOf h == "lambda"
					then (print h) else "${toString h}";
			in if isEmpty t then
				acc+"${s}"
			else
				aux (acc+"${s}, ") t
		; in if isEmpty xs then "[]" else
		(aux "[" xs) + "]";
in
	trace (print x)
	trace (print y)
#	trace (print z)
	trace (print w)
	trace (print t)
	"OK"

