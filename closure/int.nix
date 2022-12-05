#!/bin/nix-instantiate
with builtins;
let
	zero = x: y: x;
	one  = x: y: y x;
	two  = x: y: y (y x);

	print = n: n "anything" (x: trace("+1") x);
	toInt = n: (n 0 (x: x + 1));

	add = n: m: (x: y: m (n x y) y);

	# two       = x: y: y            (y            x);
	# two * two = x: y: (x: y (y x)) ((x: y (y x)) x);
	mul = n: m: (x: y: m x (x: n x y));

	twoplustwoplusone     = add two (add two one);
	twotimestwo           = mul two two;
	twotimesonetimestwo   = mul two (mul two one);
	twotimesonetwoplusone = mul two (add two one);
in
	trace("one (${toString (toInt one)}):")
		seq (print one)
	trace("two (${toString (toInt two)}):")
		seq (print two)
	trace("2+(1+2) (${toString (toInt twoplustwoplusone)}):")
		seq (print (twoplustwoplusone))
	trace("2*2: (${toString (toInt twotimestwo)})")
		seq (print (twotimestwo))
	trace("2*(1*2) (${toString (toInt twotimesonetimestwo)}):")
		seq (print (twotimesonetimestwo))
	trace("2*(1+2) (${toString (toInt twotimesonetwoplusone)}):")
		seq (print (twotimesonetwoplusone))
	"ok"


