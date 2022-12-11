#!/bin/nix-instantiate
with builtins;
with (import ./string/strings.nix);
with (import ./string/ascii.nix);
rec {
	/*
	 * "Types"/constructors
	 */
	# (m n)
	mkApply  = m: n: { type = "apply";  left  = m; right = n; };
	# (λx. m)
	mkLambda = x: m: { type = "lambda"; bound = x; expr  = m; };
	# x
	mkVar    = x:    { type = "var";    name = x;             };

	/*
	 * Auxiliary
	 */

	# isPunct could have been in string/ascii.nix
	isPunct = c: hasAttr c {
		"(" = true;
		")" = true;
		"." = true;
	};

	# skipBlacks could have been in string/strings.nix
	skipBlacks = s: n: if !isWhite (charAt s n) && !isPunct(charAt s n) && charAt s n != ""
		then skipBlacks s (n + 1) else n;

	toString = m:
		if m.type == "var" then
			m.name
		else if m.type == "lambda" then
			"(λ"+m.bound+"."+" "+(toString m.expr)+")"
		else
			"("+(toString m.left)+" "+(toString m.right)+")"
	;

	# prettier toString
	pretty = m: let aux = m: inLambda: inApp:
		if m.type == "var" then
			m.name
		else if m.type == "lambda" then
			if inLambda then
				m.bound+"."+" "+(aux m.expr true false)
			else
				"(λ"+m.bound+"."+" "+(aux m.expr true false)+")"
		else if inApp then
				(aux m.left false true)+" "+(aux m.right false false)
			else
				"("+(aux m.left false true)+" "+(aux m.right false false)+")"
		; in aux m false false;

	freeVars = m:
		if m.type == "var" then { ${m.name} = true; }
		else if m.type == "apply" then
			(freeVars m.left) // (freeVars m.right)
		else
			removeAttrs (freeVars m.expr) [m.bound];

	allVars = m:
		if m.type == "var" then { ${m.name} = true; }
		else if m.type == "apply" then
			(allVars m.left) // (allVars m.right)
		else
			{ ${m.bound} = true; } // (allVars m.expr);

	# Computes a relatively fresh variable name from a set of
	# used names
	getFresh = xs:
		let aux = n:
			if hasAttr "x${builtins.toString n}" xs then
				aux (n + 1)
			else "x${builtins.toString n}"
		; in aux 0;

	isFree = m: x: hasAttr x (freeVars m);

	/*
	 * Parsing
	 */
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

	/*
	 * Interpretation/evaluation
	 */

	# α-equivalence, M{y,x} (renaming x as y in M)
	rename = m: y: x:
		if m.type == "var" then m // {
			name = if m.name == x then y else m.name;
		} else if m.type == "apply" then m // {
			left  = rename m.left  y x;
			right = rename m.right y x;
		} else m // {
			bound = if m.bound == x then y else m.bound;
			expr  = rename m.expr  y x;
		};

	# β-substitution, M[N/x] (substituing x for N in M)
	substitute = m: n: x:
		if m.type == "var" then
			if m.name == x then n else m
		else if m.type == "apply" then m // {
			left  = substitute m.left  n x;
			right = substitute m.right n x;
		} else
			if m.bound == x then m
			else if ! (isFree n m.bound) then m // {
				expr = substitute m.expr n x;
			} else let
				y = getFresh (
					(allVars m.expr) //
					(allVars n) //
					{ ${x} = true; /* ?? "${m.bound}" = true; */ }
				);
			in m // {
				bound = y;
				expr  = substitute (rename m.expr y m.bound) n x;
			};

	reduce = m: /* trace(pretty m) */ (
		if m.type == "lambda" then
			m // { expr = reduce m.expr; }
		else if m.type == "var" then
			m
		else if m.left.type == "lambda" then
			substitute m.left.expr m.right m.left.bound
		else
			m // { left = reduce m.left; right = reduce m.right; }
	);

	eval = m: let n = reduce m; in
		if n == m then n else eval n;
}
