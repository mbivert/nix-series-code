#!/bin/nix-instantiate --eval
rec {
	toString = m:
		if m.type == "var" then
			m.name
		else if m.type == "lambda" then
			"(λ"+m.bound+"."+" "+(toString m.expr)+")"
		else
			"("+(toString m.left)+" "+(toString m.right)+")"
	;
}
