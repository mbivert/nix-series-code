#!/bin/nix-instantiate --eval
with builtins;
let
	mkUser = name: age: email: (key:
		if      key == "name" then name
		else if key == "age"  then age
		else                       email
	);
	u = mkUser "Bob" 42 "bob@corp.com";
in
	trace (u "name")
	trace (u "age")
	trace (u "email")
	"ok"
