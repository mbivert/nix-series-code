#!/bin/nix-instantiate --eval
let
	# toString can't coerce a function (e.g. (x: 3)) to a
	# string, hence why we're applying it here
	xs = [(1+3) "hi" ("hello"+" "+"world") 3 ((x: 3) 2)];
in
	"${toString xs}"
