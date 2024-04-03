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
	s = ''${typeOf (ack 0)};
${typeOf 1};
${typeOf "hi"};
${typeOf typeOf};
${typeOf foldl'}'';
	l = [
		s
		(typeOf (ack 0))
		(typeOf 1)
		(typeOf "hi")
		(typeOf typeOf)
		(typeOf builtins.foldl')
	];
in
	deepSeq l l
