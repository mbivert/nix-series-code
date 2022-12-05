#!/bin/nix-instantiate
with builtins;
with (import ./string/strings.nix);
let
	matchstar = y: xs: re: let x = charAt xs 0; in
		if x == "" then
			false
		else if matchhere xs re then
			true
		else if x == y || y == "." then
			matchstar y (eat1 xs) re
		else
			false;

	matchhere = xs: re:
		let
			x = charAt xs 0;
			r = charAt re 0;
			s = charAt re 1;
		in
			if r == "" then
				true
			else if  s == "*" then
				matchstar r xs (eat1 (eat1 re))
			else if r == "$" && s == "" then
				x == ""
			else if x != "" && (r == "." || r == x) then
				matchhere (eat1 xs) (eat1 re)
			else
				false
		;

	match1 = xs: re:
		let
			# Note that charAt returns "" when there's not enough bytes
			x = charAt xs 0;
			r = charAt re 0;
		in
			if x == "" && r != ""   then false
			else if matchhere xs re then true
			else                    match1 (eat1 xs) re
		;

	match = xs: re: let r = charAt re 0; in
		if r == "^" then matchhere xs (eat1 re)
		else             match1     xs re;

	xmatch = s: re: if match s re then "true" else "false";
in
	trace(''match("",       ""):       ${xmatch ""       ""}'')
	trace(''match("foobar", ""):       ${xmatch "foobar" ""}'')
	trace(''match("foobar", "foo"):    ${xmatch "foobar" "foo"}'')
	trace(''match("foobar", "bar"):    ${xmatch "foobar" "bar"}'')
	trace(''match("foobar", "baz"):    ${xmatch "foobar" "baz"}'')
	trace(''match("barbaz", "baz"):    ${xmatch "barbaz" "baz"}'')
	trace(''match("barbaz", ".ar"):    ${xmatch "barbaz" ".ar"}'')
	trace(''match("barbaz", "ar."):    ${xmatch "barbaz" "ar."}'')
	trace(''match("aaa",    "b*"):     ${xmatch "aaa"    "b*"}'')
	trace(''match("aaa",    "b.*"):    ${xmatch "aaa"    "b.*"}'')
	trace(''match("foobar", "b.*"):    ${xmatch "foobar" "b.*"}'')
	trace(''match("foobar", "o.*a"):   ${xmatch "foobar" "o.*a"}'')
	trace(''match("foobar", "^foo"):   ${xmatch "foobar" "^foo"}'')
	trace(''match("foobar", "^bar"):   ${xmatch "foobar" "^bar"}'')
	trace(''match("foobar", "oob$"):   ${xmatch "foobar" "oob$"}'')
	trace(''match("foobar", "bar$"):   ${xmatch "foobar" "bar$"}'')
	trace(''match("foobar", "o.*z*"):  ${xmatch "foobar" "o.*z*"}'')
	trace(''match("foobar", "o.*z.*"): ${xmatch "foobar" "o.*z.*"}'')
	trace(''match("fo^bar", "o^b"):    ${xmatch "fo^bar" "o^b"}'')
	trace(''match("foobar", "o^b"):    ${xmatch "foobar" "o^b"}'')
	trace(''match("foobar", "o$b"):    ${xmatch "foobar" "o$b"}'')
	"ok"
