#!/bin/nix-instantiate --eval
builtins.trace(
	"hello world"
) builtins.trace (
	"hello"+" "+"world"
) "EOF"
