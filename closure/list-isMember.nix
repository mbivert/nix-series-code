#!/bin/nix-instantiate
with builtins;
with (import ./list.nix);
let
	isMember = e: xs:
		if isEmpty l then false
		else if e == (car xs) then true
		else isMember e (cdr xs);

	xs = cons 1 (cons 2 (cons 3 null));
in
	trace(isMember 2 xs) (isMember (- 5) xs)
