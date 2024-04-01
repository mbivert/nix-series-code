#!/bin/nix-instantiate --eval
with builtins;
let
	ftests = (import ../ftests.nix);
	L = (import ./toString.nix) // (import ./mks.nix);

	T = L.mkLambda "x" (L.mkLambda "y" (L.mkVar "x"));
	F = L.mkLambda "x" (L.mkLambda "y" (L.mkVar "y"));
	and = L.mkLambda "x"
		(L.mkLambda "y"
			(L.mkApply (L.mkApply (L.mkVar "x") (L.mkVar "y")) F));

	tests = [
		{
			descr    = ''toString T'';
			fun      = L.toString;
			args     = T;
			expected = "(λx. (λy. x))";
		}
		{
			descr    = ''toString F'';
			fun      = L.toString;
			args     = F;
			expected = "(λx. (λy. y))";
		}
		{
			descr    = ''toString and'';
			fun      = L.toString;
			args     = and;
			expected = "(λx. (λy. ((x y) (λx. (λy. y)))))";
		}
	];
in ftests.run tests
