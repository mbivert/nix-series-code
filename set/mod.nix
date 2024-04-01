#!/bin/nix-instantiate --eval
with builtins;
let
	m = (import ./mod-fib.nix);
	f = (import ./mod-fib.nix).fib;
	xs = [ (m.fib 10) (f 10) ];
in
	deepSeq xs xs
