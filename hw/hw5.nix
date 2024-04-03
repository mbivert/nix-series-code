#!/usr/bin/env -S nix-instantiate --eval
let
	xs = [ "hello world" ("hello"+" "+"world") ];
in
	"${toString xs}"
