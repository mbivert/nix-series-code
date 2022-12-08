#!/bin/nix-instantiate
with builtins;
with (import ../string/strings.nix);
let
	ascii = (import ../string/ascii.nix);
	parseInt = s: let
		n   = stringLength s;
		aux = acc: i: let c = charAt s i; in
			if i == n || !ascii.isNum(c) then
				acc
			else
				aux (acc*10+(ascii.toNum c)) (i + 1)
		; in aux 0 0;
in
	trace(parseInt "123")
	trace(parseInt "0")
	trace(parseInt "aaa")
	trace(parseInt "456aaa12")
	"ok"
