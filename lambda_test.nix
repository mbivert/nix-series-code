#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	ftests = (import ./ftests.nix);
	L = (import ./lambda.nix);

	# shortcuts
	G   = s: (L.parse s).expr;
	P   = m: L.pretty m;

	# S/P are used here and there to help create
	# test input; S used to be a toString shortcut,
	# but is now a shortcut to P.
#	S   = m: L.toString m;
	S   = P;

	/*
	 * Church booleans
	 */
	T = L.mkLambda "x" (L.mkLambda "y" (L.mkVar "x"));
	F = L.mkLambda "x" (L.mkLambda "y" (L.mkVar "y"));
	and = L.mkLambda "x"
		(L.mkLambda "y"
			(L.mkApply (L.mkApply (L.mkVar "x") (L.mkVar "y")) F));

	# those are voluntarily made more complex than need be.
	ifelse = (G "(λp. λx. λy. p x y)");
	not    = (G ''
		(λx.
			${S ifelse} x ${S F} ${S T})
	'');

	_or     = (G ''
		λx. λy.
			${S ifelse}
				x
				${S T}
				(${S ifelse} y ${S T} ${S F})''
	);

	xor    = (G ''
		(λx. λy.
			(${S ifelse} x
				(${S ifelse} y ${S F} ${S T})
				(${S ifelse} y ${S T} ${S F})))
		'');

	/*
	 * Church integers
	 */
	zero  = (G "(λf. λx. x)");
	one   = (G "(λf. λx. f x)");
	two   = (G "(λf. λx. f (f x))");
	three = (G "(λf. λx. f (f (f x)))");
	four  = (G "(λf. λx. f (f (f (f x))))");

	succ  = (G "(λn. λf. λx. f (n f x))");
	add   = (G "(λn. λm. λf. λx. n f (m f x))");
	mult  = (G "(λn. λm. λf. n (m f))");

	iszero = (G "(λn. λx. λy. n (λz.y) x)");

	pred   = (G "λn.λf.λx. n (λg.λh. h (g f)) (λu.x) (λu.u)");
#	pred   = (G "n.f.x. n (g.h. h (g f)) (u.x) (u.u)");

	/*
	 * Turing fixed point, recursion
	 */
	A   = (G "(λx. λy. y (x x y))");
	TFP = (G "((${S A}) (${S A}))");

	Ffact    = (G ''
		λf.λn.
			(${S ifelse}) (${S iszero} n)
				(${S one})
				(${S mult} n (f (${S pred} n)))

	'');
	fact = (G "(${S TFP}) (${S Ffact})");

	tests = [
		{
			descr    = ''skipBlacks "   a"'';
			fun      = L.skipBlacks;
			args     = ["   a" 0];
			expected = 0;
		}
		{
			descr    = ''skipBlacks "aaa"'';
			fun      = L.skipBlacks;
			args     = ["aaa" 0];
			expected = 3;
		}
		{
			descr    = ''skipBlacks "aaa) "'';
			fun      = L.skipBlacks;
			args     = ["aaa) " 0];
			expected = 3;
		}
		{
			descr    = ''skipBlacks "(123)" 1'';
			fun      = L.skipBlacks;
			args     = ["(123)" 1];
			expected = 4;
		}
		{
			descr    = ''toString T'';
			fun      = L.toString;
			args     = T;
			expected = "(λx. (λy. x))";
		}
		{
			descr    = ''toString F'';
			fun      = L.toString;
			args     = F;
			expected = "(λx. (λy. y))";
		}
		{
			descr    = ''toString and'';
			fun      = L.toString;
			args     = and;
			expected = "(λx. (λy. ((x y) (λx. (λy. y)))))";
		}
		{
			descr    = ''pretty and'';
			fun      = L.pretty;
			args     = and;
			expected = "(λx. y. (x y (λx. y. y)))";
		}
		{
			descr    = ''pretty (((x y) q) (z p))'';
			fun      = L.pretty;
			args     =
				L.mkApply
					(L.mkApply
						(L.mkApply (L.mkVar "x") (L.mkVar "y"))
						(L.mkVar "q"))
					(L.mkApply (L.mkVar "z") (L.mkVar "p"));
			expected = "(x y q (z p))";
		}
		{
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
			descr    = ''parse "(λx. (λy. x))"'';
			fun      = L.parse;
			args     = "(λx. (λy. x))";
			expected = L.start // {
				s    = "(λx. (λy. x))";
				p    = 15; # 13 runes, 15 bytes
				expr = T;
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
			descr    = ''parse "not true"'';
			fun      = L.parse;
			args     = "not true";
			expected = L.start // {
				s    = "not true";
				p    = 8;
				expr = {
					type  = "apply";
					left  = { type = "var"; name = "not"; };
					right = { type = "var"; name = "true"; };
				};
			};
		}
		{
			descr    = ''parse "2\tthree"'';
			fun      = L.parse;
			args     = "2\tthree";
			expected = L.start // {
				s    = "2\tthree";
				p    = 7;
				expr = {
					type  = "apply";
					left  = { type = "var"; name = "2"; };
					right = { type = "var"; name = "three"; };
				};
			};
		}
		{
			descr    = ''parse "add   2\tthree"'';
			fun      = L.parse;
			args     = "add   2 three";
			expected = L.start // {
				s    = "add   2 three";
				p    = 13;
				expr = {
					type  = "apply";
					left  = {
						type  = "apply";
						left  = { type = "var"; name = "add"; };
						right = { type = "var"; name = "2";   };
					};
					right = { type = "var"; name = "three"; };
				};
			};
		}
		{
			descr    = ''parse "one two three four five"'';
			fun      = L.parse;
			args     = "one two three four five";
			expected = L.start // {
				s    = "one two three four five";
				p    = 23;
				expr = {
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
			descr    = ''parse "((  one two ) three four)five"'';
			fun      = L.parse;
			args     = "((  one two ) three four)five";
			expected = L.start // {
				s    = "((  one two ) three four)five";
				p    = 29;
				expr = {
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
		}
		{
			descr    = ''parse "(x y) 3"'';
			fun      = L.parse;
			args     = "(x y) 3";
			expected = L.start // {
				s    = "(x y) 3";
				p    = 7;
				expr = {
					type  = "apply";
					left = {
						type  = "apply";
						left  = { type = "var"; name = "x"; };
						right = { type = "var"; name = "y"; };
					};
					right = { type = "var"; name = "3"; };
				};
			};
		}
		{
			descr    = ''parse "(λy. ((x y) 3))"'';
			fun      = L.parse;
			args     = "(λy. ((x y) 3))";
			expected = L.start // {
				s    = "(λy. ((x y) 3))";
				p    = 16;
				expr = {
					type  = "lambda";
					bound = "y";
					expr  = {
						type = "apply";
						left = {
							type  = "apply";
							left  = { type = "var"; name = "x"; };
							right = { type = "var"; name = "y"; };
						};
						right = { type = "var"; name = "3"; };
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
		# (\forall e) parse(toString e) = e
		#             parse(pretty e) = e
		{
			descr    = ''parse (toString and)'';
			fun      = L.parse;
			args     = (L.toString and);
			expected = L.start // {
				s    = (L.toString and);
				p    = 37;
				expr = and;
			};
		}
		{
			descr    = ''parse (pretty and)'';
			fun      = L.parse;
			args     = (P and);
			expected = L.start // {
				s    = (P and);
				p    = 27;
				expr = and;
			};
		}
		{
			descr    = ''parse (pretty (or F T))'';
			fun      = L.parse;
			args     = "${P _or} ${P F} ${P T}";
			expected = L.start // {
				s    = "${P _or} ${P F} ${P T}";
				p    = 119;
				expr = {
					type = "apply";
					left = {
						type = "apply";
						left  = _or;
						right = F;
					};
					right = T;
				};
			};
		}
		{
			descr    = ''parse (lambda called on lambdas)'';
			fun      = L.parse;
			args     = "(λx. λy. x) (λx. λy. x) ((λx. λy. y))";
			expected = L.start // {
				s    = "(λx. λy. x) (λx. λy. x) ((λx. λy. y))";
				p    = 43;
				expr = {
					type = "apply";
					left = {
						type  = "apply";
						left  = T;
						right = T;
					};
					right = F;
				};
			};
		}
		{
			descr    = ''parse preserved right-associativity (old bug) (1)'';
			fun      = L.parse;
			args     = "((x y) (x y))";
			expected = L.start // {
				s    = "((x y) (x y))";
				p    = 13;
				expr = {
					type = "apply";
					left = {
						type  = "apply";
						left  = { type = "var"; name = "x"; };
						right = { type = "var"; name = "y"; };
					};
					right = {
						type  = "apply";
						left  = { type = "var"; name = "x"; };
						right = { type = "var"; name = "y"; };
					};
				};
			};
		}
		{
			descr    = ''parse preserved right-associativity (old bug) (2)'';
			fun      = L.parse;
			args     = "x y (x y)";
			expected = L.start // {
				s    = "x y (x y)";
				p    = 9;
				expr = {
					type = "apply";
					left = {
						type  = "apply";
						left  = { type = "var"; name = "x"; };
						right = { type = "var"; name = "y"; };
					};
					right = {
						type  = "apply";
						left  = { type = "var"; name = "x"; };
						right = { type = "var"; name = "y"; };
					};
				};
			};
		}
		{
			descr    = ''parse (lambda called on lambdas of lambdas)'';
			fun      = L.parse;
			args     = "(λx. λy. x) (λx. λy. x) ((λx. λy. x) (λx. λy. y))";
			expected = L.start // {
				s    = "(λx. λy. x) (λx. λy. x) ((λx. λy. x) (λx. λy. y))";
				p    = 57;
				expr = {
					type = "apply";
					left = {
						type  = "apply";
						left  = T;
						right = T;
					};
					right = {
						type  = "apply";
						left  = T;
						right = F;
					};
				};
			};
		}
		{
			descr    = ''parse (lambda called on lambdas of lambdas of lambdas)'';
			fun      = L.parse;
			args     = "(λx. λy. x) (λx. λy. x) ((λx. λy. x) (λx. λy. x) (λx. λy. y))";
			expected = L.start // {
				s    = "(λx. λy. x) (λx. λy. x) ((λx. λy. x) (λx. λy. x) (λx. λy. y))";
				p    = 71;
				expr = {
					type = "apply";
					left = {
						type  = "apply";
						left  = T;
						right = T;
					};
					right = {
						type  = "apply";
						left  = {
							type  = "apply";
							left  = T;
							right = T;
						};
						right = F;
					};
				};
			};
		}
		{
			descr    = ''parse (toString ($xor $T $T)) (1)'';
			fun      = L.parse;
			args     = "${S xor} ${S T} ${S T}";
			expected = L.start // {
				s    = "${S xor} ${S T} ${S T}";
				p    = 156;
				expr = {
					type = "apply";
					left = {
						type  = "apply";
						left  = {
							type  = "lambda";
							bound = "x";
							expr  = {
								type  = "lambda";
								bound = "y";
								expr  = {
									type = "apply";
									left = {
										type  = "apply";
										left  = {
											type  = "apply";
											left  = ifelse;
											right = {
												type = "var";
												name = "x";
											};
										};
										right = {
											type = "apply";
											left = {
												type = "apply";
												left = {
													type  = "apply";
													left  = ifelse;
													right = {
														type = "var";
														name = "y";
													};
												};
												right = F;
											};
											right = T;
										};
									};
									right = {
										type = "apply";
										left = {
											type = "apply";
											left = {
												type  = "apply";
												left  = ifelse;
												right = {
													type = "var";
													name = "y";
												};
											};
											right = T;
										};
										right = F;
									};
								};
							};
						};
						right = T;
					};
					right = T;
				};
			};
		}
		{
			descr    = ''parse (toString ($xor $T $T)) (2)'';
			fun      = L.parse;
			args     = ''
				(λx. λy.
					((((λp. λx. λy. (p x y)) x)
						((((λp. λx. λy. (p x y)) y) (λx. λy. y)) (λx. λy. x)))
						((((λp. λx. λy. (p x y)) y) (λx. λy. x)) (λx. λy. y))))
					(λx. λy. x)
					(λx. λy. x)
			'';
			expected = L.start // {
				s    = ''
				(λx. λy.
					((((λp. λx. λy. (p x y)) x)
						((((λp. λx. λy. (p x y)) y) (λx. λy. y)) (λx. λy. x)))
						((((λp. λx. λy. (p x y)) y) (λx. λy. x)) (λx. λy. y))))
					(λx. λy. x)
					(λx. λy. x)
			'';
				p    = 225;
				expr = {
					type = "apply";
					left = {
						type  = "apply";
						left  = xor;
						right = T;
					};
					right = T;
				};
			};
		}
		{
			descr    = ''parse (toString ($xor $T $T)) (3)'';
			fun      = L.parse;
			args     = ''
				(
					(
						(λx. (λy.
							((((λp. (λx. (λy. ((p x) y)))) x)
							((((λp. (λx. (λy. ((p x) y)))) y)
							(λx. (λy. y))) (λx. (λy. x))))
							((((λp. (λx. (λy. ((p x) y)))) y)
							(λx. (λy. x))) (λx. (λy. y)))))
						)
						(λx. λy. x)
					)
					(λx. λy. x)
				)
			'';
			expected = L.start // {
				s    = ''
				(
					(
						(λx. (λy.
							((((λp. (λx. (λy. ((p x) y)))) x)
							((((λp. (λx. (λy. ((p x) y)))) y)
							(λx. (λy. y))) (λx. (λy. x))))
							((((λp. (λx. (λy. ((p x) y)))) y)
							(λx. (λy. x))) (λx. (λy. y)))))
						)
						(λx. λy. x)
					)
					(λx. λy. x)
				)
			'';
				p    = 307;
				expr = {
					type = "apply";
					left = {
						type  = "apply";
						left  = xor;
						right = T;
					};
					right = T;
				};
			};
		}

		# NOTE: we're indirectly testing again L.parse below ("G"
		# is a shortcut calling L.parse, and assuming success)
		{
			descr    = ''freeVars "hello"'';
			fun      = L.freeVars;
			args     = (G "hello");
			expected = { hello = true; };
		}
		{
			descr    = ''freeVars and'';
			fun      = L.freeVars;
			args     = and;
			expected = {};
		}
		{
			descr    = ''freeVars "((x y) (λx. λy. y z))"'';
			fun      = L.freeVars;
			args     = (G "((x y) (λx. λy. y z))");
			expected = { x = true; y = true; z = true; };
		}
		{
			descr    = ''freeVars "((λx. λy. y z) (x y))"'';
			fun      = L.freeVars;
			args     = (G "((λx. λy. y z) (x y))");
			expected = { x = true; y = true; z = true; };
		}
		{
			descr    = ''freeVars "λx. λy. y z foo x bar"'';
			fun      = L.freeVars;
			args     = (G "λx. λy. y z foo x bar");
			expected = { z = true; foo = true; bar = true; };
		}
		{
			descr    = ''freeVars "λx. y λy. y z foo x bar"'';
			fun      = L.freeVars;
			args     = (G "λx. y λy. y z foo x bar");
			expected = { z = true; foo = true; bar = true; y = true; };
		}
		{
			descr    = ''allVars "((x y) (λx. λy. y z))"'';
			fun      = L.allVars;
			args     = (G "((x y) (λx. λy. y z))");
			expected = { x = true; y = true; z = true; };
		}
		{
			descr    = ''allVars "λx. y λy. y z foo x bar"'';
			fun      = L.allVars;
			args     = (G "λx. y λy. y z foo x bar");
			expected = {
				z = true; foo = true; bar = true; y = true;
				x = true;
			};
		}
		{
			descr    = ''getFresh {}'';
			fun      = L.getFresh;
			args     = [{}];
			expected = "x0";
		}
		{
			descr    = ''getFresh { x = true; y = true; z = true;}'';
			fun      = L.getFresh;
			args     = [{ x = true; y = true; z = true;}];
			expected = "x0";
		}
		{
			descr    = ''getFresh { x0 = true; y = true; z = true;}'';
			fun      = L.getFresh;
			args     = [{ x0 = true; y = true; z = true;}];
			expected = "x1";
		}
		{
			descr    = ''isFree "λx. y λy. y z foo x bar" x'';
			fun      = L.isFree;
			args     = [(G "λx. y λy. y z foo x bar") "x"];
			expected = false;
		}
		{
			descr    = ''isFree "λx. y λy. y z foo x bar" y'';
			fun      = L.isFree;
			args     = [(G "λx. y λy. y z foo x bar") "y"];
			expected = true;
		}
		{
			descr    = ''isFree "λx. y λy. y z foo x bar" foo'';
			fun      = L.isFree;
			args     = [(G "λx. y λy. y z foo x bar") "foo"];
			expected = true;
		}
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
		{
			descr    = ''substitute: "complex" substitute (bis)'';
			fun      = L.substitute;
			args     = [(G ''
				(λp. λx. λy. p x y)
				(λx. λy. x)
				(λx. λy. x)
				(
					(λp. λx. λy. p x y)
					y
					(λx. λy. x)
					(λx. λy. y))'') (G "(λx. λy. x)") "y"];
			expected = (G ''
				(λp. λx. λy. p x y)
				(λx. λy. x)
				(λx. λy. x)
				(
					(λp. λx. λy. p x y)
					(λx. λy. x)
					(λx. λy. x)
					(λx. λy. y))'');
		}
		{
			descr    = ''substitute: "complex" substitute (ter)'';
			fun      = L.substitute;
			args     = [
				(G ''((λx. λy. x) (λx. λy. x) y)'')
				(G "((λx. λy. x) (λx. λy. x) (λx. λy. y))")
				"y"
			];
			expected = (G ''
				(λx. λy. x) (λx. λy. x) ((λx. λy. x) (λx. λy. x) (λx. λy. y))
			'');
		}
		{
			descr    = ''substitute: "complex" substitute (xor, 1)'';
			fun      = L.substitute;
			args     = [ (G ''
				((((λp. λx. λy. (p x y)) x)
					((((λp. λx. λy. (p x y)) y) (λx. λy. y)) (λx. λy. x)))
					((((λp. λx. λy. (p x y)) y) (λx. λy. x)) (λx. λy. y)))
				'')
				(G "(λx. (λy. x))")
				"y"
			];
			expected = (G ''
				((((λp. λx. λy. (p x y)) x)
					((((λp. λx. λy. (p x y)) (λx. (λy. x))) (λx. λy. y)) (λx. λy. x)))
					((((λp. λx. λy. (p x y)) (λx. (λy. x))) (λx. λy. x)) (λx. λy. y)))
			'');
		}
		{
			descr    = ''substitute: "complex" substitute (xor, 2)'';
			fun      = L.substitute;
			args     = [
				(G ''
					(λy.
						((((λp. λx. λy. (p x y)) x)
							((((λp. λx. λy. (p x y)) y) (λx. λy. y)) (λx. λy. x)))
							((((λp. λx. λy. (p x y)) y) (λx. λy. x)) (λx. λy. y))))
						(λx. (λy. x))
				'')
				(G "(λx. (λy. x))")
				"x"
			];
			expected =
			(G ''
				(λy.
					((((λp. λx. λy. (p x y)) (λx. (λy. x)))
						((((λp. λx. λy. (p x y)) y) (λx. λy. y)) (λx. λy. x)))
						((((λp. λx. λy. (p x y)) y) (λx. λy. x)) (λx. λy. y))))
					(λx. (λy. x))
			'');
		}
		{
			descr    = ''eval: variable'';
			fun      = L.eval;
			args     = (G "x");
			expected = (G "x");
		}
		{
			descr    = ''eval: unreductible apply'';
			fun      = L.eval;
			args     = (G "x y");
			expected = (G "x y");
		}
		{
			descr    = ''eval: unreductible applies'';
			fun      = L.eval;
			args     = (G "x y z");
			expected = (G "x y z");
		}
		{
			descr    = ''eval: function call, single arg'';
			fun      = L.eval;
			args     = (G "(λx. x y) z");
			expected = (G "z y");
		}
		{
			descr    = ''eval: function call, two args'';
			fun      = L.eval;
			args     = (G "(λx. λy. x y) z z0");
			expected = (G "z z0");
		}
		{
			descr    = ''eval: and T F == F'';
			fun      = L.eval;
			args     = (G "${S and} ${S T} ${S F}");
			expected = F;
		}
		{
			descr    = ''eval: and F T == F'';
			fun      = L.eval;
			args     = (G "${S and} ${S F} ${S T}");
			expected = F;
		}
		{
			descr    = ''eval: and F F == F'';
			fun      = L.eval;
			args     = (G "${S and} ${S F} ${S F}");
			expected = F;
		}
		{
			descr    = ''eval: and T T == T'';
			fun      = L.eval;
			args     = (G "${S and} ${S T} ${S T}");
			expected = T;
		}
		{
			descr    = ''eval: not F == T'';
			fun      = L.eval;
			args     = (G "${S not} ${S F}");
			expected = T;
		}
		{
			descr    = ''eval: not T == F'';
			fun      = L.eval;
			args     = (G "${S not} ${S T}");
			expected = F;
		}
		{
			descr    = ''eval: let ... in ... -like'';
			fun      = L.eval;
			args     = (G ''
				(
					(λ zero.
					(λ one.
					(λ two.
					(λ ifelse.
					(λ iszero.
					(
						((ifelse (iszero one)) two) zero
					)
					) (λn. (λx. (λy. ((n (λz.y)) x))))
					) (λp. (λx. (λy. ((p x) y))))
					) (λf. (λx. (f (f x))))
					) (λf. (λx. (f x)))
					) (λf. (λx. x))
				)
			'');
			expected = zero;
		}
		{
			descr    = ''eval: let ... in ... -like (or T T)'';
			fun      = L.eval;
			args     = (G ''
				(
					(λ ifelse.
					(λ F.
					(λ T.
					(λ or.
					(
						(or T) T
					)
					) (λx. (λy. (((ifelse x) T) (((ifelse y) T) F))))
					) (λx. (λy. x))
					) (λx. (λy. y))
					) (λp. (λx. (λy. ((p x) y))))
				)
			'');
			expected = T;
		}
		{
			descr    = ''eval: let ... in ... -like (xor T T)'';
			fun      = L.eval;
			args     = (G ''
				(
					(λ ifelse.
					(λ F.
					(λ T.
					(λ xor.
					(
						(xor T) T
					)
					) (λx. (λy. (((ifelse x) (((ifelse y) F) T)) (((ifelse y) T) F))))
					) (λx. (λy. x))
					) (λx. (λy. y))
					) (λp. (λx. (λy. ((p x) y))))
				)
			'');
			expected = F;
		}
		# Below are some manual debugging evaluation unrolls on
		# "or" and "xor". They've been kept to help narrow down
		# later issues faster.
		{
			descr    = ''eval: or T T == T (1)'';
			fun      = L.eval;
			args     = (G ''
				((λx. λy. x) (λx. λy. x) ((λx. λy. x) (λx. λy. x) (λx. λy. y)))
			'');
			expected = T;
		}
		{
			descr    = ''eval: or T T == T (2)'';
			fun      = L.eval;
			args     = (G ''
				((λx. λy. x) (λx. λy. x)
					(
						(λp. λx. λy. p x y)
						(λx. λy. x)
						(λx. λy. x)
						(λx. λy. y)))
			'');
			expected = T;
		}
		{
			descr    = ''eval: or T T == T (3)'';
			fun      = L.eval;
			args     = (G ''
				(λy. ((λx. λy. x) (λx. λy. x) y))
					(
						(λp. λx. λy. p x y)
						(λx. λy. x)
						(λx. λy. x)
						(λx. λy. y))
			'');
			expected = T;
		}
		{
			descr    = ''eval: or T T == T (4)'';
			fun      = L.eval;
			args     = (G ''
				(λp. λx. λy. p x y)
					(λx. λy. x)
					(λx. λy. x)
					(
						(λp. λx. λy. p x y)
						(λx. λy. x)
						(λx. λy. x)
						(λx. λy. y)))
			'');
			expected = T;
		}
		{
			descr    = ''eval: or T T == T (5)'';
			fun      = L.eval;
			args     = (G "${S _or} ${S T} ${S T}");
			expected = T;
		}
		{
			descr    = ''eval: or F T == T'';
			fun      = L.eval;
			args     = (G "${S _or} ${S F} ${S T}");
			expected = T;
		}
		{
			descr    = ''eval: or T F == T'';
			fun      = L.eval;
			args     = (G "${S _or} ${S T} ${S F}");
			expected = T;
		}
		{
			descr    = ''eval: or F F == F'';
			fun      = L.eval;
			args     = (G "${S _or} ${S F} ${S F}");
			expected = F;
		}
		{
			descr    = ''eval: xor F T == T'';
			fun      = L.eval;
			args     = (G "${S _or} ${S F} ${S T}");
			expected = T;
		}
		{
			descr    = ''eval: xor T F == T'';
			fun      = L.eval;
			args     = (G "(${S xor}) (${S T}) (${S F})");
			expected = T;
		}
		{
			descr    = ''eval: xor F F == F'';
			fun      = L.eval;
			args     = (G "${S xor} ${S F} ${S F}");
			expected = F;
		}
		{
			descr    = ''eval: xor T T == F (0)'';
			fun      = L.eval;
			args     = (G ''
				((((λp. λx. λy. (p x y)) (λx. (λy. x)))
					((((λp. λx. λy. (p x y)) (λx. (λy. x))) (λx. λy. y)) (λx. λy. x)))
					((((λp. λx. λy. (p x y)) (λx. (λy. x))) (λx. λy. x)) (λx. λy. y)))
			''
			);
			expected = F;
		}
		{
			descr    = ''eval: xor T T == F (1)'';
			fun      = L.eval;
			args     = (G ''
				(λy. ((((λp. λx. λy. (p x y)) (λx. (λy. x)))
						((((λp. λx. λy. (p x y)) y) (λx. λy. y)) (λx. λy. x)))
						((((λp. λx. λy. (p x y)) y) (λx. λy. x)) (λx. λy. y))))
					(λx. λy. x)
			''
			);
			expected = F;
		}
		{
			descr    = ''eval: xor T T == F (2)'';
			fun      = L.eval;
			args     = (G ''
				(
					(
						(λy.
							((((λp. (λx. (λy. ((p x) y)))) (λx. λy. x))
							((((λp. (λx. (λy. ((p x) y)))) y)
							(λx. (λy. y))) (λx. (λy. x))))
							((((λp. (λx. (λy. ((p x) y)))) y)
							(λx. (λy. x))) (λx. (λy. y)))))
					)
					(λx. λy. x)
				)
			''
			);
			expected = F;
		}
		{
			descr    = ''eval: xor T T == F (2.25)'';
			fun      = L.eval;
			args     = (G ''
				(
					(
						(λx. (λy.
							((((λp. (λx. (λy. ((p x) y)))) x)
							((((λp. (λx. (λy. ((p x) y)))) y)
							(λx. (λy. y))) (λx. (λy. x))))
							((((λp. (λx. (λy. ((p x) y)))) y)
							(λx. (λy. x))) (λx. (λy. y)))))
						)
						(λx. λy. x)
					)
					(λx. λy. x)
				)
			''
			);
			expected = F;
		}
		{
			descr    = ''eval: xor T T == F (2.5)'';
			fun      = L.eval;
			args     = (G ''
				(((λx. (λy.
						((((λp. (λx. (λy. ((p x) y)))) x)
						((((λp. (λx. (λy. ((p x) y)))) y) (λx. (λy. y)))
						(λx. (λy. x)))) ((((λp. (λx. (λy. ((p x) y)))) y)
						(λx. (λy. x))) (λx. (λy. y))))))
						(λx. (λy. x)))
						(λx. (λy. x)))
			''
			);
			expected = F;
		}
		{
			descr    = ''eval: xor T T == F (3)'';
			fun      = L.eval;
			args     = (G "((${S xor} ${S T}) ${S T})");
			expected = F;
		}
		{
			descr    = ''eval: succ zero == one'';
			fun      = L.eval;
			args     = (G "${S succ} ${S zero})");
			expected = one;
		}
		{
			descr    = ''eval: succ (succ one) == three'';
			fun      = L.eval;
			args     = (G "${S succ} (${S succ} ${S one})");
			expected = three;
		}
		{
			descr    = ''eval: add two three == add three two'';
			fun      = L.eval;
			args     = (G "${S add} ${S two} ${S three}");
			expected = L.eval (G "${S add} ${S three} ${S two}");
		}
		{
			descr    = ''eval: mult two three == add three three'';
			fun      = L.eval;
			args     = (G "${S mult} ${S two} ${S three}");
			expected = L.eval (G "${S add} ${S three} ${S three}");
		}
		{
			descr    = ''eval: iszero zero == T'';
			fun      = L.eval;
			args     = (G "${S iszero} ${S zero}");
			expected = T;
		}
		{
			descr    = ''eval: iszero one == F'';
			fun      = L.eval;
			args     = (G "${S iszero} ${S one}");
			expected = F;
		}
		{
			descr    = ''eval: iszero three == F'';
			fun      = L.eval;
			args     = (G "${S iszero} ${S three}");
			expected = F;
		}
		{
			descr    = ''eval: pred one == zero'';
			fun      = L.eval;
			args     = (G "${S pred} ${S one}");
			expected = zero;
		}
		{
			descr    = ''eval: pred two == one'';
			fun      = L.eval;
			args     = (G "${S pred} ${S two}");
			expected = one;
		}
		{
			descr    = ''eval: pred (pred three) == one'';
			fun      = L.eval;
			args     = (G "${S pred} (${S pred} ${S three})");
			expected = one;
		}
		{
			descr    = ''eval: fact zero == one'';
			fun      = L.eval;
			args     = (G "${S fact} ${S zero}");
			expected = one;
		}
		{
			descr    = ''eval: fact one == one'';
			fun      = L.eval;
			args     = (G "${S fact} ${S one}");
			expected = one;
		}
		{
			descr    = ''eval: fact two == two'';
			fun      = L.eval;
			args     = (G "${S fact} ${S two}");
			expected = two;
		}
		{
			descr    = ''eval: fact three == three * two * one = six'';
			fun      = L.eval;
			args     = (G "${S fact} ${S three}");
			expected =
				L.eval (G "${S mult} ${S three} ${S two}");
		}
		# Working but slow; the previous one already
		# takes a few seconds.
/*
		{
			descr    = ''eval: fact four == four * three * two'';
			fun      = L.eval;
			args     = (G "${S fact} ${S four}");
			expected =
				L.eval (G ''
					${S mult}
						(${S mult} (${S add} ${S three} ${S one}) ${S three})
						${S two}
				'');
		}
*/
	];
in ftests.run tests
