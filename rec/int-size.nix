#!/bin/nix-instantiate --eval
let
	f = n: m:
		if n * 2 == 0 || n * 2 <= 0
			then m
		else
			f (n * 2) (m+1)
	;
in
	f 1 1

