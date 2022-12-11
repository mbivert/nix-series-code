#!/bin/sh

set -e

for x in *_test.nix */*_test.nix; do
	echo Running $x...
	nix-instantiate --eval $x
done