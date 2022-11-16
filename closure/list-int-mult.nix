#!/bin/nix-instantiate --eval
with builtins;
/*
 * This is the first list implementation, but things would
 * work identically either later ones, relying Church booleans/pairs.
 */
with (import ./list.nix);
with (import ./list-lib.nix);
let
	# Interestingly, we must redefine map here: importing
	# it from e.g. list-lib.nix wouldn't overide the default
	# map implementation.
	map   = f: xs: reverse (foldl (acc: x: (cons (f x) acc)) nil xs);
	mult  = xs: ys: flatten (map (_: ys) xs);
	two   = range 1 2;
	three = range 1 3;
	five  = range 1 5;
	ten   = range 1 10;
in
	# Note that we still rely on Nix's integers for printing here
	trace("${toString (length two)} * ${toString (length three)} =")
	trace(length(mult two three))
	trace("${toString (length five)} * ${toString (length ten)} =")
	trace(length(mult five ten))
	"ok"
