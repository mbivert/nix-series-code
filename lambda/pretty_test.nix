#!/bin/nix-instantiate --eval
with builtins;
let
	ftests = (import ../ftests.nix);
	L = (import ./pretty.nix) // (import ./mks.nix);

	T = L.mkLambda "x" (L.mkLambda "y" (L.mkVar "x"));
	F = L.mkLambda "x" (L.mkLambda "y" (L.mkVar "y"));
	and = L.mkLambda "x"
		(L.mkLambda "y"
			(L.mkApply (L.mkApply (L.mkVar "x") (L.mkVar "y")) F));

	tests = [
		{
			descr    = ''pretty and'';
			fun      = L.pretty;
			args     = and;
			expected = "(λx. y. (x y (λx. y. y)))";
		}
		{
			descr    = ''pretty (((x y) q) (z p))'';
			fun      = L.pretty;
			args     =
				L.mkApply
					(L.mkApply
						(L.mkApply (L.mkVar "x") (L.mkVar "y"))
						(L.mkVar "q"))
					(L.mkApply (L.mkVar "z") (L.mkVar "p"));
			expected = "(x y q (z p))";
		}
	];
in ftests.run tests
