#!/usr/bin/env -S nix-instantiate --eval
with builtins;
with (import ./list.nix);
let
	cadr  = l: car (cdr l);
	caddr = l: car (cdr (cdr l));
	cdar  = l: cdr (car l);
in
	"untested"
