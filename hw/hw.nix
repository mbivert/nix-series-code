#!/bin/nix-instantiate
/*
 * Regarding ``with builtins;``, it is an import-like.
 * From a user perspective, suffice to know, for now,
 * that it means we won't have to prefix "trace" with "bulitins"
 * everywhere.
 *
 * More on this later.
 *
 * Mind the two kinds of comments used throughout this file.
 */
with builtins;

# most basic
trace ("hello world")

# string concatenation
trace ("hello"+" "+"world")

# "variables" definition and usage
# NOTE: mind the semicolon after each variable
# declaration.
trace (
	let
		h = "hello";
		w = "world";
	in
		h+" "+w
)

# strings "format" (w is a list containing a single
# element)
trace (
	let
		h = "hello";
		w = ["world"];
	in
		"${toString h} ${toString w}"
)

# Same as before, but with a single list with two
# elements
trace (
	let
		hw = ["hello" "world"];
	in
		"${toString hw}"
)

# lambda function, list of argument (one arg)
trace (
	(x: "hello "+x) "world"
)

# named function, list of argument (two args)
trace (
	let
		f = x: y: x+" "+y;
	in
		f "hello" "world"
)

# named function, "named parameters" (attribute sets)
trace (
	let
		hw = {h, w} : "${h} ${w}";
	in
		hw {h="hello"; w="world";}
)

# default parameters
trace (
	let
		hw = {h ? "hello", w ? "world"} : "${h} ${w}";
	in
		hw {h="hello";}
)

# if/then/else
trace (
	let
		hw = x: if x == "hello" then "hello world" else "bye";
	in
		hw "hello"
)

# Evaluation value for this script
"OK"

