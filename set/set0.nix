#!/bin/nix-instantiate
with builtins;
let
	x = {
		n = 3;
		s = "hello";
		f = (x: x);
		y = {
			m = 4;
			z = x;
		};
		"what" = "ok";
	};
in deepSeq x x
