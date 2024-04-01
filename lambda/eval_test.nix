#!/bin/nix-instantiate --eval
with builtins;
let
	ftests = (import ../ftests.nix);
	L = (import ./parse.nix) // (import ./eval.nix) //
		(import ./mks.nix) // (import ./pretty.nix);

	G   = s: (L.parse s).expr;
	P   = m: L.pretty m;
	S   = P;

	T = L.mkLambda "x" (L.mkLambda "y" (L.mkVar "x"));
	F = L.mkLambda "x" (L.mkLambda "y" (L.mkVar "y"));
	and = L.mkLambda "x"
		(L.mkLambda "y"
			(L.mkApply (L.mkApply (L.mkVar "x") (L.mkVar "y")) F));

	ifelse = (G "(λp. λx. λy. p x y)");

	xor    = (G ''
		(λx. λy.
			(${S ifelse} x
				(${S ifelse} y ${S F} ${S T})
				(${S ifelse} y ${S T} ${S F})))
		'');
	zero  = (G "(λf. λx. x)");
	one   = (G "(λf. λx. f x)");
	two   = (G "(λf. λx. f (f x))");
	three = (G "(λf. λx. f (f (f x)))");
	four  = (G "(λf. λx. f (f (f (f x))))");

	succ  = (G "(λn. λf. λx. f (n f x))");
	add   = (G "(λn. λm. λf. λx. n f (m f x))");
	mult  = (G "(λn. λm. λf. n (m f))");

	iszero = (G "(λn. λx. λy. n (λz.y) x)");

	pred   = (G "λn.λf.λx. n (λg.λh. h (g f)) (λu.x) (λu.u)");
#	pred   = (G "n.f.x. n (g.h. h (g f)) (u.x) (u.u)");

	/*
	 * Turing fixed point, recursion
	 */
	A   = (G "(λx. λy. y (x x y))");
	TFP = (G "((${S A}) (${S A}))");

	Ffact    = (G ''
		λf.λn.
			(${S ifelse}) (${S iszero} n)
				(${S one})
				(${S mult} n (f (${S pred} n)))

	'');
	fact = (G "(${S TFP}) (${S Ffact})");

	tests = [
		{
			descr    = ''eval: variable'';
			fun      = L.eval;
			args     = (G "x");
			expected = (G "x");
		}
		{
			descr    = ''eval: unreductible apply'';
			fun      = L.eval;
			args     = (G "x y");
			expected = (G "x y");
		}
		{
			descr    = ''eval: unreductible applies'';
			fun      = L.eval;
			args     = (G "x y z");
			expected = (G "x y z");
		}
		{
			descr    = ''eval: function call, single arg'';
			fun      = L.eval;
			args     = (G "(λx. x y) z");
			expected = (G "z y");
		}
		{
			descr    = ''eval: let ... in ... -like (or T T)'';
			fun      = L.eval;
			args     = (G ''
				(
					(λ ifelse.
					(λ F.
					(λ T.
					(λ or.
					(
						(or T) T
					)
					) (λx. (λy. (((ifelse x) T) (((ifelse y) T) F))))
					) (λx. (λy. x))
					) (λx. (λy. y))
					) (λp. (λx. (λy. ((p x) y))))
				)
			'');
			expected = T;
		}
		{
			descr    = ''eval: xor T T == F (3)'';
			fun      = L.eval;
			args     = (G "((${S xor} ${S T}) ${S T})");
			expected = F;
		}
		{
			descr    = ''eval: iszero three == F'';
			fun      = L.eval;
			args     = (G "${S iszero} ${S three}");
			expected = F;
		}
		{
			descr    = ''eval: pred (pred three) == one'';
			fun      = L.eval;
			args     = (G "${S pred} (${S pred} ${S three})");
			expected = one;
		}
		{
			descr    = ''eval: fact three == three * two * one = six'';
			fun      = L.eval;
			args     = (G "${S fact} ${S three}");
			expected =
				L.eval (G "${S mult} ${S three} ${S two}");
		}
	];
in ftests.run tests
