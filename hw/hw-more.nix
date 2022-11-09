#!/bin/nix-instantiate --eval
with builtins;

let xs = [
	# Imbricated let/in, cross-referencing variables
	(
		let
			x  = let xx = "hello"; in xx;
			yy = "world";
			y  = yy;
		in
			x+" "+y
	)

	# Closure (more on that later)
	(
		let
			say = x: (y: x + y);
		in
			(say ((say "hello") " ")) "world"
	)

	# After looking for some more string functions:
	(
		let
			s = "noisehello worldmore noise";
		in (
			substring
				(stringLength "noise")
				(stringLength "hello world")
				s
		)
	)

	# Common symbols can be redefined
	(
		let
			true = "hello";
			false = "world";
			substring = false;
		in
			true + " " + substring
	)
]; in deepSeq xs xs
