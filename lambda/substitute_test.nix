#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	ftests = (import ../ftests.nix);
	L = (import ./parse.nix) // (import ./substitute.nix);

	G   = s: (L.parse s).expr;

	tests = [
		{
			descr    = ''substitute: matching variable is substituted'';
			fun      = L.substitute;
			args     = [(G "x") (G "λx. λy. x y") "x"];
			expected = (G "λx. λy. x y");
		}
		{
			descr    = ''substitute: un-matching variable name'';
			fun      = L.substitute;
			args     = [(G "y") (G "λx. λy. x y") "x"];
			expected = (G "y");
		}
		{
			descr    = ''substitute: variable substituted in both parts of an apply'';
			fun      = L.substitute;
			args     = [(G "(x (x y))") (G "λx. λy. x y") "x"];
			expected = (G "((λx. λy. x y) ((λx. λy. x y) y))");
		}
		{
			descr    = ''substitute: bound variable not substituted'';
			fun      = L.substitute;
			args     = [(G "λx. λy. x y") (G "λx. λy. x y") "x"];
			expected = (G "λx. λy. x y");
		}
		{
			descr    = ''substitute: unbound, unused variable'';
			fun      = L.substitute;
			args     = [(G "λx. λz. x z") (G "λx. λy. x y") "z"];
			expected = (G "λx. λz. x z");
		}
		{
			descr    = ''substitute: replacing a free variable, no conflict'';
			fun      = L.substitute;
			args     = [(G "λx. λy. x z") (G "λx. λy. x y") "z"];
			expected = (G "λx. λy. x (λx. λy. x y)");
		}
		{
			descr    = ''substitute: replacing a free variable, renaming'';
			fun      = L.substitute;
			args     = [(G "λx. λy. x z y") (G "λx. λz. x y z") "z"];
			expected = (G "λx. λx0. x (λx. λz. x y z) x0");
		}
		{
			descr    = ''substitute: replacing a free variable, renaming (bis)'';
			fun      = L.substitute;
			args     = [(G "λx. λy. x (z x0) y") (G "λx. λz. x y z") "z"];
			expected = (G "λx. λx1. x ((λx. λz. x y z) x0) x1");
		}
		{
			descr    = ''substitute: Selinger's example'';
			fun      = L.substitute;
			args     = [(G "λx. y x") (G "λz. x z") "y"];
			expected = (G "λx0. (λz. x z) x0");
		}
		# TODO: choose a better example.
		{
			descr    = ''substitute: replacing bound variable by the variable to rename'';
			fun      = L.substitute;
			args     = [(G ''
				(λf. n.
					((λy.
						(
							(λn. x. y. (n (λz. y) x))
							n
							(λf. x. (f x)) y))
					(λx0.
						(n (f (λf. x. (n (λg. h. (h (g f))) (λu. x) (λu. u))) x0)))))
			'') (G "f") "x0"];
			expected = (G ''
				(λx1. n.
					((λy.
						(
							(λn. x. y. (n (λz. y) x))
							n
							(λx1. x. (x1 x)) y))
					(λx0.
						(n (x1 (λx1. x. (n (λg. h. (h (g x1))) (λu. x) (λu. u))) x0)))))
			'');
		}
		{
			descr    = ''substitute: don't re-use a name already used below'';
			fun      = L.substitute;
			args     = [
				(G "(λn. x0. y. (n (λz. y) x0))")
				(G "(λx0. (n (x1 (λx1. x0. (n (λg. h. (h (g x1))) (λu. x0) (λu. u))) x0)))")
				"y"
			];
			expected = (G "(λx2. x0. y. (x2 (λz. y) x0))");
		}
		{
			descr    = ''substitute: "complex" substitute'';
			fun      = L.substitute;
			args     = [(G ''
				(λy.
					(λp. λx. λy. p x y)
					x
					(λx. λy. x)
					(
						(λp. λx. λy. p x y)
						y
						(λx. λy. x)
						(λx. λy. y)))'') (G "(λx. λy. x)") "x"];
			expected = (G ''
				(λy.
					(λp. λx. λy. p x y)
					(λx. λy. x)
					(λx. λy. x)
					(
						(λp. λx. λy. p x y)
						y
						(λx. λy. x)
						(λx. λy. y)))'');
		}
	];
in ftests.run tests