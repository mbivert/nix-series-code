#!/usr/bin/env -S nix-instantiate --eval
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

	mkNum    = n:       { type = "Num";             val  = n;            };
	mkUnary  = s: e:    { type = "Unary";  sgn = s; expr = e;            };
	mkFact   = m: o: n: { type = "Factor"; op  = o; left = m; right = n; };
	mkTerm   = m: o: n: { type = "Term";   op  = o; left = m; right = n; };

	start = {
		err  = null;
		s    = "";
		p    = 0;
		expr = {};
	};

	toDecimal = n: if n < 1 then n else toDecimal (n / 10);
	toFloat   = n: n + 0.1 - 0.1;

	atEOF  = s: s.p == (stringLength s.s);
	hasErr = s: s.err != null;
	peek1  = s: charAt s.s (skipWhites s.s s.p);
	next1  = s: s // { p = (skipWhites s.s s.p) + 1; };
	skipws = s: s // { p = (skipWhites s.s s.p); };

	# slightly adjusted from others/parseNum2.nix
	parseFloat = s: f: let
		aux = acc: i: x: f: let c = charAt s.s i; in
			if c == "." && !x then
				aux 0 (i+1) true (d: i:
					f (acc + toDecimal(toFloat(d))) i
				)
			else if atEOF s || !ascii.isNum(c) then
				f acc i
			else
				aux (acc*10+(ascii.toNum c)) (i + 1) x f
		; in aux 0 s.p false f;

	parseNum = s:
		if atEOF s then s // { err = "unexpected EOF"; }
		else let c = peek1 s; in
		if c == "(" then let
				t = parseExpr (next1 s);
			in if hasErr t then t
			else if (peek1 t) != ")" then
				t // { err = "expecting ')'"; }
			else next1 t
		else if c != "." && !(ascii.isNum c) then
			s // { err = "digit/dot expected, got '${c}'"; }
		else parseFloat (skipws s) (n: p: s // {
			p = p; expr = mkNum(n);
		})
	;

	parseUnary = s: let c = peek1 s; in
		if c == "-" then
			let t = parseUnary (next1 s); in
			if hasErr t then t else
			t // { expr = mkUnary (-1) t.expr; }
		else if c == "+" then
			parseUnary (next1 s)
		else parseNum s
	;

	parseFact = s: let t = parseUnary s; in
		if hasErr t then t
		else let aux = t:
			let c = peek1 t; in
			if c == "*" || c == "/" then
				let u = parseUnary (next1 t); in
				if hasErr u then u
				else
					aux (u // { expr = mkFact t.expr c u.expr; })
			else t
		; in aux t
	;

	parseTerm = s: let t = parseFact s; in
		if hasErr t then t
		else let aux = t:
			let c = peek1 t; in
			if c == "+" || c == "-" then
				let u = parseFact (next1 t); in
				if hasErr u then u
				else
					aux (u // { expr = mkTerm t.expr c u.expr; })
			else t
		; in aux t
	;

	parseExpr = parseTerm;

	parse = s: parseExpr (start // { s = s; });

	exec = s:
		if s.type == "Num" then s.val
		else if s.type == "Unary" then s.sgn * (exec s.expr)
		else (getAttr s.op ops) (exec s.left) (exec s.right)
	;
}
