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
	mkTeacher = name: age: email: field: let
			super = mkUser name age email;
		in (func:
			if func == "set" then
				(key: value:
					# Ignore
					if key == "name" then
						mkTeacher name age email field
					else if key == "field" then
						mkTeacher name age email value

					# We can't just return `super "set" key value`
					# here, because we would get a user and not
					# a teacher.
					else let
						super2 = super "set" key value;
					in
						mkTeacher
							(super2 "get" "name")
							(super2 "get" "age")
							(super2 "get" "email")
				)
			else if func == "get" then
				(key: if key == "field" then field else super "get" key)
			else
				super func
		);

	u = mkTeacher "Bob"  42 "bob@uni.com" "CS";
	v = (u "set" "name" "Joe") "set" "field" "IT";
in
	trace (u "get" "name")
	trace (u "get" "age")
	trace (u "get" "email")
	trace (u "get" "field")
	trace (u "isAdult")
	trace (v "get" "name")
	trace (v "get" "field")
	"ok"
