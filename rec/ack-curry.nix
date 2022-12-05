#!/bin/nix-instantiate
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
	a = (ack 0 1);
	b = (ack 0);
	c = (b 1);
in
	"(ack 0)=${toString b}; ((ack 0) 1)=${toString c};"
	+"(ack 0 1)=${toString a}"
