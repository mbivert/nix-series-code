#!/bin/nix-instantiate
with builtins;
let
	# concatLists' parameter *must* be a list of lists, no
	# scalars allowed down there
	xs = concatLists (map (x: if !isList x then [x] else x) [[1 2] 3]);

	# This is a more efficient and more general "variant" of
	# concatLists (equivalent to concatLists (map f xs))
	ys = concatMap (x: if !isList x then [x] else x) [[1 2] 3 [4]];

	# the ' indicates that foldl is *strict* here, meaning, it
	# will systematically evaluate the list entries before processing
	# them (like deepSeq does).
	n = foldl' add 0 (map (x: 2*x) [1 2 3]);
in
	trace(xs)
	trace(ys)
	trace(n)
	"ok"

