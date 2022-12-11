#!/bin/nix-instantiate
rec {
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
}
