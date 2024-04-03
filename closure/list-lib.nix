#!/usr/bin/env -S nix-instantiate --eval
with builtins;
with (import ./list.nix);
rec {
	cadr   = xs: car (cdr xs);
	caddr  = xs: car (cdr (cdr xs));
	cadddr = xs: car (cdr (cdr (cdr xs)));
	cdar   = xs: cdr (car xs);

	isMember = e: xs:
		if isEmpty l then false
		else if e == (car xs) then true
		else isMember e (cdr xs);

	length = xs: let aux = n: xs:
		if isEmpty xs then n
		else aux (n + 1) (cdr xs)
	; in aux 0 xs;

	append = xs: ys:
		if isEmpty xs then
			ys
		else
			cons (car xs) (append (cdr xs) ys);

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

	reverse = xs: let aux = acc: xs:
			if isEmpty xs
				then acc
			else
				aux (cons (car xs) acc) (cdr xs)
		; in aux nil xs;

	range = n: m: let aux = acc: i:
		if i < n then
			acc
		else
			aux (cons i acc) (i - 1)
		; in aux nil m;

	foldl = f: s: xs: let aux = acc: xs:
			if isEmpty xs then acc
			else aux (f acc (car xs)) (cdr xs)
		; in aux s xs;

	foldr = f: s: xs: let aux = acc: xs:
			if isEmpty xs then acc
			else f (car xs) (aux acc (cdr xs))
		; in aux s xs;

	flatten = foldl (acc: x:
		if typeOf x == "lambda" then
			(append acc x)
		else
			(append acc (cons x nil))
		) nil;
	map     = f: xs: reverse (foldl (acc: x: (cons (f x) acc)) nil xs);
	take = n: xs: let aux = acc: xs: i:
		if i == n then
			acc
		else
			aux (cons (car xs) acc) (cdr xs) (i + 1)
		; in aux nil xs 0;
}
