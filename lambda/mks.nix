#!/usr/bin/env -S nix-instantiate --eval
rec {
	# (m n)
	mkApply  = m: n: { type = "apply";  left  = m; right = n; };
	# (λx. m)
	mkLambda = x: m: { type = "lambda"; bound = x; expr  = m; };
	# x
	mkVar    = x:    { type = "var";    name = x;             };
}
