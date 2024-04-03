#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	odd = n:
		if n < 0 then
			odd (- n)
		else if n == 0 then
			false
		else
			even (n - 1)
	;
	even = n:
		if n < 0 then
			even (- n)
		else if n == 0 then
			true
		else
			odd (n - 1)
	;
	# toString by default for boolean make an empty
	# string for false and 1 for true. Interestingly,
	# we can override the existing definition seamlessly.
	toString = b: if b then "true" else "false";
	a = even 10;
	b = even 5;
	c = odd  10;
	d = odd  5;
	e = odd (- 5);
in
	"(even 10)=${toString a}; (even 5)=${toString b} (odd 10)=${toString c}"
	+"; (odd 5)=${toString d} (odd -5)=${toString e}"
