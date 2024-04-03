#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	mod = a: b: a - (b * (div a b));

	fizzbuzz = n: let aux = i:
		if i > n then
			"end"
		else trace(
			if (mod i 3) == 0 && (mod i 5) == 0 then
				"FizzBuzz"
			else if (mod i 3) == 0 then
				"Fizz"
			else if (mod i 5) == 0 then
				"Buzz"
			else i
		) aux (i + 1); in aux 1
	;
in
	fizzbuzz 100
