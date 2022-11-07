#!/bin/nix-instantiate --eval
let
	xs = [ "hello world" ("hello"+" "+"world") ];
in
	(builtins.deepSeq xs xs)

