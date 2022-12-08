with builtins;
with (import ./string/strings.nix);
rec {
	ascii = (import ./string/ascii.nix);

	ops = {
		"+" = (x: y: x + y);
		"-" = (x: y: x - y);
		"*" = (x: y: x * y);
		"/" = (x: y: x / y);
	};

	toDecimal = n: if n < 1 then n else toDecimal (n / 10);
	toFloat   = n: n + 0.1 - 0.1;

	exec = s: let e = stringLength s; aux = f: i:
		if i == e then (f) else let c = charAt s i; in
			if hasAttr c ops then
				aux (x: y: (f (ops."${c}" x y))) (i + 1)
			else if ascii.isNum c then
				let parseNum = n: i: d: aux: let c = charAt s i; in
					if c == "." && !d then
						parseNum 0 (i + 1) true (m: i:
							aux (n + toDecimal (toFloat m)) i
						)
					else if i == e || !ascii.isNum c then
						aux n i
					else
						parseNum ((10 * n) + ascii.toNum(c))(i + 1) d aux
				; in parseNum 0 i false (n: i: aux (f n) i)
			# Ignore everything else (punctuation, whites, letters, etc.)
			else aux f (i + 1)
		; in aux (x: x) 0
	;
}
