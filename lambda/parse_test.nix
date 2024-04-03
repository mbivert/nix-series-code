#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	ftests = (import ../ftests.nix);
	L = (import ./parse.nix) // (import ./mks.nix) // (import ./toString.nix);

	T = L.mkLambda "x" (L.mkLambda "y" (L.mkVar "x"));

	tests = [		{
			descr    = ''parse ""'';
			fun      = L.parse;
			args     = "";
			expected = L.start // { err = "unexpected EOF"; };
		}
		{
			descr    = ''parse "123"'';
			fun      = L.parse;
			args     = "123";
			expected = L.start // {
				s    = "123";
				p    = 3;
				expr = { type = "var"; name = "123"; };
			};
		}
		{
			descr    = ''parse "(123)"'';
			fun      = L.parse;
			args     = "(123)";
			expected = L.start // {
				s    = "(123)";
				p    = 5;
				expr = { type = "var"; name = "123"; };
			};
		}
		{
			descr    = ''parse "((123))"'';
			fun      = L.parse;
			args     = "((123))";
			expected = L.start // {
				s    = "((123))";
				p    = 7;
				expr = { type = "var"; name = "123"; };
			};
		}
		{
			descr    = ''parse "    ( (  123) )"'';
			fun      = L.parse;
			args     = "    ( (  123) )";
			expected = L.start // {
				s    = "    ( (  123) )";
				p    = 15;
				expr = { type = "var"; name = "123"; };
			};
		}
		{
			descr    = ''parse "(λx(λy. x))"'';
			fun      = L.parse;
			args     = "(λx(λy. x))";
			expected = L.start // {
				err  = ". expected after λ";
				s    = "(λx(λy. x))";
				p    = 4;
				expr = {};
			};
		}
		{
			descr    = ''parse "x ("'';
			fun      = L.parse;
			args     = "x (";
			expected = L.start // {
				err  = "unexpected EOF";
				s    = "x (";
				p    = 3;
				# parseApply "lose" the right hand side on error;
				# this is good enough.
				expr = { };
			};
		}
		{
			descr    = ''parse "x (yy"'';
			fun      = L.parse;
			args     = "x (yy";
			expected = L.start // {
				err  = "expecting ')'";
				s    = "x (yy";
				p    = 5;
				expr = { type = "var"; name = "yy"; };
			};
		}
		{
			descr    = ''parse "(λx. )"'';
			fun      = L.parse;
			args     = "(λx. )";
			expected = L.start // {
				err  = "word expected";
				s    = "(λx. )";
				p    = 5;
				expr = {};
			};
		}

		{
			descr    = ''parse "(   λx. ( λy. x ))"'';
			fun      = L.parse;
			args     = "(   λx. ( λy. x ))";
			expected = L.start // {
				s    = "(   λx. ( λy. x ))";
				p    = 20; # 18 runes, 20 bytes
				expr = T;
			};
		}
		{
			descr    = ''parse "(   λx. λy. x) "'';
			fun      = L.parse;
			args     = "(   λx. λy. x) ";
			expected = L.start // {
				s    = "(   λx. λy. x) ";
				p    = 16; # 14 runes
				expr = T;
			};
		}
		{
			descr    = ''parse "λx.λy.x"'';
			fun      = L.parse;
			args     = "λx.λy.x";
			expected = L.start // {
				s    = "λx.λy.x";
				p    = 9; # 7 runes
				expr = T;
			};
		}
		{
			descr    = ''parse "x. one two three four five"'';
			fun      = L.parse;
			args     = "x. one two three four five";
			expected = L.start // {
				s    = "x. one two three four five";
				p    = 26;
				expr = {
					type  = "lambda";
					bound = "x";
					expr  = {
						type = "apply";
						left = {
							type  = "apply";
							left = {
								type  = "apply";
								left  = {
									type  = "apply";
									left  = { type = "var"; name = "one"; };
									right = { type = "var"; name = "two"; };
								};
								right = { type = "var"; name = "three"; };
							};
							right = { type = "var"; name = "four"; };
						};
						right = { type = "var"; name = "five"; };
					};
				};
			};
		}
		{
			descr    = ''parse "((x y) (λx. λy. y))"'';
			fun      = L.parse;
			args     = "((x y) (λx. λy. y))";
			expected = L.start // {
				s    = "((x y) (λx. λy. y))";
				p    = 21;
				expr = {
					type = "apply";
					left = {
						type = "apply";
						left  = { type = "var"; name = "x"; };
						right = { type = "var"; name = "y"; };
					};
					right = {
						type = "lambda";
						bound = "x";
						expr  = {
							type = "lambda";
							bound = "y";
							expr = {
								type = "var"; name = "y";
							};
						};
					};
				};
			};
		}
];
in ftests.run tests
