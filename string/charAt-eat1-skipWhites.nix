#!/bin/nix-instantiate
with builtins;
with (import ./strings.nix);
let
	s = "hello\t\t  world";
in
	trace(charAt "hello" 4)
	trace(charAt "hello" 5)
	trace(eat1   "hhello")
	# Raises an error; that's fine though
#	trace(charAt "hello" (-1))
	trace(substring (skipWhites s 5) 5 s)
"ok"
