#!/bin/nix-instantiate --eval
with builtins;
let
	mkUser = name: age: email: (func:
		if func == "isAdult" then
			age >= 18
		else (key:
			if      key == "name" then name
			else if key == "age"  then age
			else                       email
		)
	);
	u = mkUser "Bob"  42 "bob@corp.com";
	v = mkUser "Boss" 2  "boss@babycorp.com";
in
	trace (u "get" "name")
	trace (u "get" "age")
	trace (u "get" "email")
	trace (u "isAdult")
	trace (v "isAdult")
	"ok"
