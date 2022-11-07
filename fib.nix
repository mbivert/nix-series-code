#!/bin/nix-instantiate --eval
with builtins;
let
	fib = n:
		if n == 0 || n == 1 then
			n
		else
			fib(n - 1)+fib(n - 2)
	;
	n = fib 5;
	m = fib 10;
in
	"(fib 5)=${toString n}; (fib 10)=${toString m}"

