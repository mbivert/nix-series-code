#!/bin/nix-instantiate --eval
with builtins;
with (import ../string/strings.nix);
let
	ascii = (import ../string/ascii.nix);
	toDecimal = n: if n < 1 then n else toDecimal (n / 10);
	toFloat   = n: n + 0.1 - 0.1;

	parseNum = s: let
		n   = stringLength s;
		aux = acc: i: x: let c = charAt s i; in
			if c == "." && !x then
				let d = aux 0 (i+1) true; in
				acc + toDecimal(toFloat(d))
			else if i == n || !ascii.isNum(c) then
				acc
			else
				aux (acc*10+(ascii.toNum c)) (i + 1) x
		; in aux 0 0 false;

in
	trace(parseNum "123")
	trace(parseNum "123.0")
	trace(parseNum "123.0aaa")
	trace(parseNum "123.aa")
	trace(parseNum "123.23")
	trace(parseNum ".23ei")
	trace(parseNum ".23.13")
	"ok"
