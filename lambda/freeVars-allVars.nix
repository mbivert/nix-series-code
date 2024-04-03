#!/usr/bin/env -S nix-instantiate --eval
rec {
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
}
