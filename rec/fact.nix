#!/usr/bin/env -S nix-instantiate --eval
let
	fact = n: if n == 0 then 1 else n*fact(n - 1);
in
	fact 5
