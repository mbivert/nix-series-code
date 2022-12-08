#!/bin/nix-instantiate
with builtins;
let
	ftests = (import ./ftests.nix);
	exprs  = (import ./exprs.nix);
	tests = [
		{
			descr    = ''parse ""'';
			fun      = exprs.parse;
			args     = "";
			expected = {
				err  = "unexpected EOF";
				s    = "";
				p    = 0;
				expr = {};
			};
		}
		{
			descr    = ''parse "3"'';
			fun      = exprs.parse;
			args     = "3";
			expected = {
				err  = null;
				s    = "3";
				p    = 1;
				expr = { type = "Num"; val = 3; };
			};
		}
		{
			descr    = ''parse "3.42"'';
			fun      = exprs.parse;
			args     = "3.42";
			expected = {
				err  = null;
				s    = "3.42";
				p    = 4;
				expr = { type = "Num"; val = 3.42; };
			};
		}
		{
			descr    = ''parse "((3.42))"'';
			fun      = exprs.parse;
			args     = "((3.42))";
			expected = {
				err  = null;
				s    = "((3.42))";
				p    = 8;
				expr = { type = "Num"; val = 3.42; };
			};
		}
		{
			descr    = ''parse "((3.42"'';
			fun      = exprs.parse;
			args     = "((3.42";
			expected = {
				err  = "expecting ')'";
				s    = "((3.42";
				p    = 6;
				expr = { type = "Num"; val = 3.42; };
			};
		}
		{
			descr    = ''parse "(		(  3.42"'';
			fun      = exprs.parse;
			args     = "(		(  3.42";
			expected = {
				err  = "expecting ')'";
				s    = "(		(  3.42";
				p    = 10;
				expr = { type = "Num"; val = 3.42; };
			};
		}
		{
			descr    = ''parse "aa12"'';
			fun      = exprs.parse;
			args     = "aa12";
			expected = {
				err  = "digit/dot expected, got 'a'";
				s    = "aa12";
				p    = 0;
				expr = {};
			};
		}
		# Not so great I guess?
		{
			descr    = ''parse "12aa"'';
			fun      = exprs.parse;
			args     = "12aa";
			expected = {
				err  = null;
				s    = "12aa";
				p    = 2;
				expr = { type = "Num"; val = 12; };
			};
		}
		{
			descr    = ''parse "-3"'';
			fun      = exprs.parse;
			args     = "-3";
			expected = {
				err  = null;
				s    = "-3";
				p    = 2;
				expr = {
					type = "Unary";
					sgn  = -1;
					expr = { type = "Num"; val = 3; };
				};
			};
		}
		{
			descr    = ''parse "-(3)"'';
			fun      = exprs.parse;
			args     = "-(3)";
			expected = {
				err  = null;
				s    = "-(3)";
				p    = 4;
				expr = { type = "Unary"; sgn = -1; expr = { type = "Num"; val = 3; }; };
			};
		}
		{
			descr    = ''parse "-(-(3.42  ))"'';
			fun      = exprs.parse;
			args     = "-(-(3.42  ))";
			expected = {
				err  = null;
				s    = "-(-(3.42  ))";
				p    = 12;
				expr = {
					type = "Unary";
					sgn  = -1;
					expr = {
						type = "Unary";
						sgn  = -1;
						expr = { type = "Num"; val = 3.42; };
					};
				};
			};
		}
		{
			descr    = ''parse "-   - 3.42"'';
			fun      = exprs.parse;
			args     = "-   - 3.42";
			expected = {
				err  = null;
				s    = "-   - 3.42";
				p    = 10;
				expr = {
					type = "Unary";
					sgn  = -1;
					expr = {
						type = "Unary";
						sgn  = -1;
						expr = { type = "Num"; val = 3.42; };
					};
				};
			};
		}
		{
			descr    = ''parse "+(+(3.42  ))"'';
			fun      = exprs.parse;
			args     = "+(+(3.42  ))";
			expected = {
				err  = null;
				s    = "+(+(3.42  ))";
				p    = 12;
				expr = { type = "Num"; val = 3.42; };
			};
		}
		{
			descr    = ''parse "+   +3.42"'';
			fun      = exprs.parse;
			args     = "+   +3.42";
			expected = {
				err  = null;
				s    = "+   +3.42";
				p    = 9;
				expr = { type = "Num"; val = 3.42; };
			};
		}
		{
			descr    = ''parse "1 +   +3.42"'';
			fun      = exprs.parse;
			args     = "1 +   +3.42";
			expected = {
				err  = null;
				s    = "1 +   +3.42";
				p    = 11;
				expr = {
					type  = "Term";
					op    = "+";
					left  = { type = "Num"; val = 1; };
					right = { type = "Num"; val = 3.42; };
				};
			};
		}
		{
			descr    = ''parse "+   +3.42 + -2.25"'';
			fun      = exprs.parse;
			args     = "+   +3.42 + -2.25";
			expected = {
				err  = null;
				s    = "+   +3.42 + -2.25";
				p    = 17;
				expr = {
					type  = "Term";
					op    = "+";
					left  = { type = "Num"; val = 3.42; };
					right = {
						type = "Unary";
						sgn  = -1;
						expr = { type = "Num"; val = 2.25; };
					};
				};
			};
		}
		# We definitely don't want this to be parsed
		# as 1 - (42+12); meaning, + & - are left associative
		{
			descr    = ''parse "1	- 42 + 12"'';
			fun      = exprs.parse;
			args     = "1	- 42 + 12";
			expected = {
				err  = null;
				s    = "1	- 42 + 12";
				p    = 11;
				expr = {
					type  = "Term";
					op    = "+";
					left  = {
						type  = "Term";
						op    = "-";
						left  = { type = "Num"; val = 1;  };
						right = { type = "Num"; val = 42; };
					};
					right = { type = "Num"; val = 12; };
				};
			};
		}
		{
			descr    = ''parse "1	+ 42 * 12"'';
			fun      = exprs.parse;
			args     = "1	+ 42 * 12";
			expected = {
				err  = null;
				s    = "1	+ 42 * 12";
				p    = 11;
				expr = {
					type  = "Term";
					op    = "+";
					left  = { type = "Num"; val = 1;  };
					right = {
						type  = "Factor";
						op    = "*";
						left  = { type = "Num"; val = 42; };
						right = { type = "Num"; val = 12; };
					};
				};
			};
		}
		{
			descr    = ''parse "1- 3 * 5 + (1 + 34  )/ 3."'';
			fun      = exprs.parse;
			args     = "1- 3 * 5 + (1 + 34  )/ 3.";
			expected = {
				err  = null;
				s    = "1- 3 * 5 + (1 + 34  )/ 3.";
				p    = 25;
				expr = (exprs.mkTerm
						(exprs.mkTerm
							(exprs.mkNum  1)
							"-"
							(exprs.mkFact (exprs.mkNum 3) "*" (exprs.mkNum 5)))
						"+"
						(exprs.mkFact
							(exprs.mkTerm (exprs.mkNum 1) "+" (exprs.mkNum 34))
							"/"
							(exprs.mkNum  3.)));
			};
		}
		{
			descr    = ''parse "0	/ 78 * 12"'';
			fun      = exprs.parse;
			args     = "0	/ 78 * 12";
			expected = {
				err  = null;
				s    = "0	/ 78 * 12";
				p    = 11;
				expr = {
					type = "Factor";
					op   = "*";
					left = {
						type  = "Factor";
						op    = "/";
						left  = { type  = "Num"; val = 0;  };
						right = { type  = "Num"; val = 78; };
					};
					right = { type  = "Num"; val = 12; };
				};
			};
		}
		{
			descr    = ''parse "1 + 3 * 5 + ( 1 - 34 )"'';
			fun      = exprs.parse;
			args     = "1 + 3 * 5 + ( 1 - 34 )";
			expected = {
				err  = null;
				s    = "1 + 3 * 5 + ( 1 - 34 )";
				p    = 22;
				expr = (exprs.mkTerm
						(exprs.mkTerm
							(exprs.mkNum  1)
							"+"
							(exprs.mkFact (exprs.mkNum 3) "*" (exprs.mkNum 5)))
						"+"
						(exprs.mkTerm (exprs.mkNum 1) "-" (exprs.mkNum 34)));
			};
		}
		{
			descr    = ''exec "pre-parsed 1+3*5+(1-34)"'';
			fun      = exprs.exec;
			args     = {
				type = "Term";
				op   = "+";
				left = { type  = "Num"; val = 1; };
				right = {
					type = "Term";
					op   = "+";
					left = {
						type  = "Factor";
						op    = "*";
						left  = { type  = "Num"; val = 3; };
						right = { type  = "Num"; val = 5; };
					};
					right = {
						type  = "Term";
						op    = "-";
						left  = { type  = "Num"; val = 1;  };
						right = { type  = "Num"; val = 34; };
					};
				};
			};
			expected = 1+3*5+(1-34);
		}
		{
			descr    = ''exec (parse "2*(3+(2+4*5)-78+-12)")'';
			fun      = exprs.exec;
			args     = (exprs.parse "2*(3+(2+4*5)-78+-12)").expr;
			expected = 2*(3+(2+4*5)-78+-12);
		}
	];
in ftests.run tests
