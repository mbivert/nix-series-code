#!/bin/nix-instantiate --eval
with builtins;

let xs = [
	("hello world")
	("hello"+" "+"world")
	(
		let
			h = "hello";
			w = "world";
		in
			h+" "+w
	)
	(
		let
			h = "hello";
			w = ["world"];
		in
			"${toString h} ${toString w}"
	)
	(
		let
			hw = ["hello" "world"];
		in
			"${toString hw}"
	)
	(
		(x: "hello "+x) "world"
	)
	(
		let
			f = x: y: x+" "+y;
		in
			f "hello" "world"
	)
	(
		let
			hw = {h, w} : "${h} ${w}";
		in
			hw {h="hello"; w="world";}
	)
	(
		let
			hw = {h ? "hello", w ? "world"} : "${h} ${w}";
		in
			hw {h="hello";}
	)
	(
		let
			hw = x: if x == "hello" then "hello world" else "bye";
		in
			hw "hello"
	)
]; in deepSeq xs xs


