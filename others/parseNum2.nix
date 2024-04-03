#!/usr/bin/env -S nix-instantiate --eval
with builtins;
with (import ../string/strings.nix);
let
	ascii = (import ../string/ascii.nix);
	toDecimal = n: if n < 1 then n else toDecimal (n / 10);
	toFloat   = n: n + 0.1 - 0.1;

	parseNum = s: f: let
		n   = stringLength s;
		aux = acc: i: x: f: let c = charAt s i; in
			if c == "." && !x then
				aux 0 (i+1) true (d: i:
					f (acc + toDecimal(toFloat(d))) i
				)
			else if i == n || !ascii.isNum(c) then
				f acc i
			else
				aux (acc*10+(ascii.toNum c)) (i + 1) x f
		; in aux 0 0 false f;

	# Dumb function retrieving the two "returned" values
	f = n: i: "i=${toString i}; n=${toString n}";
in
	trace(parseNum "123" f)
	trace(parseNum "123.0" f)
	trace(parseNum "123.0aaa" f)
	trace(parseNum "123.aa" f)
	trace(parseNum "123.23" f)
	trace(parseNum ".23ei" f)
	trace(parseNum ".23.12" f)
	"ok"
