#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	apply  = f: l: foldl' (x: y: x y) f l;
	charAt = s: n: substring n 1 s;
	sAfter = s: n: substring n ((stringLength s) - n) s;
	fst    = xs: elemAt xs 0;
	snd    = xs: elemAt xs 1;
	isList = xs: typeOf xs == "list";
	wrap   = x: if !isList x then [x] else x;

	mkStep = o: r: { o = o; r = r; };
	mkWith = f: s: p: mkStep (mkMover s p) (f s p);

	mkMover = s: p: c:
		if      c == "prev"  then mkWith charAt s (p - 1)
		else if c == "next"  then mkWith charAt s (p + 1)
		else if c == "get"   then mkWith charAt s p
		else if c == "setp"  then mkWith charAt s
		else if c == "after" then mkWith sAfter s p
		else throw "unknown command ${c}";

	# Code could be simpler were we not trying to
	# keep track of intermediate results.
	chain = o: xs: let go = rs: n: o:
		if n == length xs then mkStep o rs
		else let
			x   = elemAt xs n;
			ret = apply (o (fst x)) (snd x);
		in go (rs ++ [ret.r]) (n + 1) ret.o
		; in go [] 0 o;

	# Convenience
	fmtMoves = map (x: let
			cmd  = if isList x then fst x else x;
			args = if ! (isList x) || length x == 1 then [] else wrap (snd x);
		in [cmd args]);

	A = chain (mkMover "hello world" 0) (fmtMoves [
		"get" "next" "next" "next" "next" "prev" ["setp"  6] "after"
	]);
in
	trace(deepSeq A.r A.r)
	"ok"
