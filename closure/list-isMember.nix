#!/bin/nix-instantiate
with builtins;
with (import ./list.nix);
let
	isMember = e: xs:
		if  isEmpty xs        then false
		else if e == (car xs) then true
		else                       isMember e (cdr xs);

	xs = cons 1 (cons 2 (cons 3 nil));
in
	trace(isMember 2 xs)
	trace(isMember (- 5) xs)
	"ok"

