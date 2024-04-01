#!/bin/nix-instantiate --eval
with builtins;
let
	# with head/tail
	take = n: xs:
		if xs == [] || n == 0 then
			[]
		else
			[(head xs)]++(take (n - 1) (tail xs))
	;

	# with elemAt and an auxiliary function
	take2 = n: xs: let m = length xs; aux = acc: i:
		if i >= m then
			acc
		else
			aux (acc++[(elemAt xs i)]) (i + 1)
		; in aux [] 0;

	# and with foldl'
	take3 = n: xs: elemAt (foldl' (acc: x:
		let
			m  = elemAt acc 0;
			ys = elemAt acc 1;
		in
			if m >= n then acc
			else [(m + 1) (ys++[x])]
		) [0 []] xs) 1;

	xs = take  5 [1 2];
	ys = take2 2 [1 2 3 4 5];
	zs = take  0 [];
	ts = take3 3 [1 2 3 4 5];
	us = take3 9 [1 2 3 4 5];
in
	trace(deepSeq xs xs)
	trace(deepSeq ys ys)
	trace(deepSeq zs zs)
	trace(deepSeq ts ts)
	trace(deepSeq us us)
	"ok"
