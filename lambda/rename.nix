#!/bin/nix-instantiate
rec {
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
}
