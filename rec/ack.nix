#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	ack = m: n:
		if m == 0 then
			n + 1
		else if n == 0 then
			ack (m - 1) 1
		else
			ack (m - 1) (ack m (n - 1))
	;
	a = ack 1 1;
	b = ack 2 2;
	c = ack 3 3;
	d = ack 4 1;
	e = ack 5 5;
in
	"(ack 1 1)=${toString a}; (ack 2 2)=${toString b} (ack 3 3)=${toString c}"
#	+"(ack 4 1)=${toString d}; (ack 5 5)=${toString e}"
