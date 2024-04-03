#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	true   = (x: y: x);
	false  = (x: y: y);
	ifelse = p: x: y: p x y;

	and2 = x: y: ifelse x (ifelse y true false) false;
	and  = x: y: x y false;

	# error: syntax error, unexpected OR_KW
	_or2 = x: y: ifelse x true (ifelse y true false);
	_or  = x: y: x true y;

	xor2 = x: y: ifelse x (ifelse y false true) (ifelse y true false);
	xor  = x: y: x (y false true) (y true false);

	not2 = x: ifelse x false true;
	not  = x: x false true;
in
	trace (ifelse (and true  true)  "1&1 = 1" "error")
	trace (ifelse (and true  false) "error"   "1&0 = 0")
	trace (ifelse (and false false) "error"   "0&0 = 0")
	trace (ifelse (and false true)  "error"   "0&1 = 0")
	trace ("---")
	trace (ifelse (and2 true  true)  "1&1 = 1" "error")
	trace (ifelse (and2 true  false) "error"   "1&0 = 0")
	trace (ifelse (and2 false false) "error"   "0&0 = 0")
	trace (ifelse (and2 false true)  "error"   "0&1 = 0")
	trace ("---")
	trace (ifelse (_or true  true)  "1|1 = 1" "error")
	trace (ifelse (_or true  false) "1|0 = 1" "error")
	trace (ifelse (_or false false) "error"   "0|0 = 0")
	trace (ifelse (_or false true)  "0|1 = 1" "error")
	trace ("---")
	trace (ifelse (_or2 true  true)  "1|1 = 1" "error")
	trace (ifelse (_or2 true  false) "1|0 = 1" "error")
	trace (ifelse (_or2 false false) "error"   "0|0 = 0")
	trace (ifelse (_or2 false true)  "0|1 = 1" "error")
	trace ("---")
	trace (ifelse (xor true  true)  "error"   "1^1 = 0")
	trace (ifelse (xor true  false) "1^0 = 1" "error")
	trace (ifelse (xor false false) "error"   "0^0 = 0")
	trace (ifelse (xor false true)  "0^1 = 1" "error")
	trace ("---")
	trace (ifelse (xor2 true  true)  "error"   "1^1 = 0")
	trace (ifelse (xor2 true  false) "1^0 = 1" "error")
	trace (ifelse (xor2 false false) "error"   "0^0 = 0")
	trace (ifelse (xor2 false true)  "0^1 = 1" "error")
	trace ("---")
	trace (ifelse (not true)        "error"   "!1 = 0")
	trace (ifelse (not false)       "!0 = 1"  "error")
	trace ("---")
	trace (ifelse (not2 true)        "error"   "!1 = 0")
	trace (ifelse (not2 false)       "!0 = 1"  "error")
	"ok"
