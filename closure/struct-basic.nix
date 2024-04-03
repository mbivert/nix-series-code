#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	mkUser = name: age: (x: if x then name else age);
	u = mkUser "Bob" 42;
in
	trace (u true)
	trace (u false)
	"ok"
