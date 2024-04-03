#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	callFunWith = f: x: (y: f x y);
	add         = x: y: x + y;
	add3To      = callFunWith add 3;
in
	trace(add3To 7)
	trace((callFunWith add 7) 3)
	"ok"
