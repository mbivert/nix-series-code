#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	xs = [(1+3) "hi" ("hello"+" "+"world") 3 (x: 3)];
in
	deepSeq xs xs
