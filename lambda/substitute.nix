#!/bin/nix-instantiate --eval
with builtins;
with (import ./freeVars-allVars.nix);
with (import ./rename.nix);
rec {
	# Computes a relatively fresh variable name from a set of
	# used names
	getFresh = xs:
		let aux = n:
			if hasAttr "x${builtins.toString n}" xs then
				aux (n + 1)
			else "x${builtins.toString n}"
		; in aux 0;

	isFree = m: x: hasAttr x (freeVars m);

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
}