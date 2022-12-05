#!/bin/nix-instantiate
let
	xs = [ "hello world" ("hello"+" "+"world") ];
in
	(builtins.deepSeq xs xs)

