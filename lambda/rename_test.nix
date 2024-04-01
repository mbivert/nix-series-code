#!/bin/nix-instantiate --eval
with builtins;
let
	ftests = (import ../ftests.nix);
	L = (import ./parse.nix) // (import ./rename.nix);

	G   = s: (L.parse s).expr;

	tests = [
		{
			descr    = ''rename "z" y x'';
			fun      = L.rename;
			args     = [(G "z") "y" "x"];
			expected = (G "z");
		}
		{
			descr    = ''rename "x" y x'';
			fun      = L.rename;
			args     = [(G "x") "y" "x"];
			expected = (G "y");
		}
		{
			descr    = ''rename "(x y) (y z) " y x'';
			fun      = L.rename;
			args     = [(G "(x y) (y x z) ") "y" "x"];
			expected = (G "(y y) (y y z) ");
		}
		{
			descr    = ''rename "λx. x z" y x'';
			fun      = L.rename;
			args     = [(G "λx. x z") "y" "x"];
			expected = (G "λy. y z");
		}
		{
			descr    = ''rename "λx. x z" y y'';
			fun      = L.rename;
			args     = [(G "λx. x z") "y" "y"];
			expected = (G "λx. x z");
		}
		{
			descr    = ''rename "λx. λy. y z foo bar" z x'';
			fun      = L.rename;
			args     = [(G "λx. λy. y z foo bar") "z" "x"];
			expected = (G "λz. λy. y z foo bar");
		}
		{
			descr    = ''rename "λx. λy. y z foo bar" z x'';
			fun      = L.rename;
			args     = [(G "λx. λy. y z foo bar") "z" "x"];
			expected = (G "λz. λy. y z foo bar");
		}
		{
			descr    = ''rename "λx. λy. y z foo bar" z x'';
			fun      = L.rename;
			args     = [(G "λx. λy. y z foo bar") "foo" "y"];
			expected = (G "λx. λfoo. foo z foo bar");
		}
	];
in ftests.run tests
