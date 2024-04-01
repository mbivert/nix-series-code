#!/bin/nix-instantiate --eval
with builtins;
with (import ../string/strings.nix);
with (import ../string/ascii.nix);
with (import ./mks.nix);
rec {
	# isPunct could have been in string/ascii.nix
	isPunct = c: hasAttr c {
		"(" = true;
		")" = true;
		"." = true;
	};

	# skipBlacks could have been in string/strings.nix
	skipBlacks = s: n: if !isWhite (charAt s n) && !isPunct(charAt s n) && charAt s n != ""
		then skipBlacks s (n + 1) else n;

	start = {
		# input buffer
		s = "";

		# pointer to input buffer
		p = 0;

		err = null;

		# parsed expression
		expr = {};
	};

	atEOF  = s: s.p == (stringLength s.s);
	hasErr = s: s.err != null;

	peek1 = s: charAt s.s (skipWhites s.s s.p);
	next1 = s: s // { p = (skipWhites s.s s.p) + 1; };

	peekw = s: let q = skipWhites s.s s.p; in
		substring q ((skipBlacks s.s q) - q) s.s;

	nextw = s: s // {
		p = skipBlacks s.s (skipWhites s.s s.p);
	};

	parseUnary  = s:
		if atEOF s then s // { err = "unexpected EOF"; }
		else if (peek1 s) == "(" then let
				t = parseExpr (next1 s);
			in if hasErr t then t
			else if (peek1 t) != ")" then
				t // { err = "expecting ')'"; }
			else
				next1 t
		else let w = peekw s; in
			if w == "" then s // { err = "word expected"; }
			else nextw s // { expr = mkVar w; }
	;

	# no utf-8 support; "λ" is two bytes long
	hasLambda  = s: p: substring (skipWhites s p) 2 s == "λ";
	skipLambda = s: next1 (next1 s);

	# the lambda is optional, i.e (f. x) <=> (λf. x)
	parseLambda = s:
		let
			b = hasLambda s.s s.p;
			t = if b then skipLambda s else s;
		in let
			w = peekw t;
			u = nextw t;
		in if peek1 u == "." then let v = parseExpr (next1 u); in
			if hasErr v then v
			else v // { expr = mkLambda w v.expr; }
		else if b then
			u // { err = ". expected after λ"; }
		else parseUnary s;

	hasMore = s:
		let
			q = skipWhites s.s s.p;
			c = charAt s.s q;
		in q != stringLength s.s &&
			(c == "(" || (hasLambda s.s q) || !(isPunct c));

	parseApply = s:
		let aux = acc: s: let t = parseLambda s; in
			if hasErr t then t
			else let
				a = if acc == {} then t.expr else mkApply acc t.expr;
			in if hasMore t then aux a (t // { expr = {}; })
			else                 t // { expr = a; }
		; in aux {} (s // { expr = {}; });

	parseExpr = s: parseApply s;
	parse     = s: parseExpr (start // { s = s; });
}
