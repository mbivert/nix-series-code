#!/bin/nix-instantiate
let
	xs = [ "hello world" ("hello"+" "+"world") ];
in
	toString xs

