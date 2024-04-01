#!/bin/nix-instantiate --eval
with builtins;
let
	mkUser = name: age: email: (func:
		if func == "isAdult" then
			age >= 18
		else if func == "set" then
			(key: value:
				if key == "name" then
					mkUser value age   email
				else if key == "age" then
					mkUser name  value email
				else
					mkUser name  age   value
			)
		else (key:
			if      key == "name" then name
			else if key == "age"  then age
			else                       email
		)
	);
	u = mkUser "Bob"  42 "bob@corp.com";
	v = (u "set" "age" 2) "set" "email" "nein@plan.com";
in
	trace (u "get" "name")
	trace (u "get" "age")
	trace (u "get" "email")
	trace (u "isAdult")
	trace (v "get" "name")
	trace (v "isAdult")
	trace (v "get" "email")
	"ok"
