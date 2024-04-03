#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	ftests = (import ./ftests.nix);
	tests = [
		{
			descr     = "run1 [1 2 3] ≠ [1 2 3 4]";
			fun      = ftests.run1;
			args     = {
				descr     = "(should fail)";
				indent   = "// ";
				fun      = _ : [ 1 2 3];
				args     = [];
				expected = [1 2 3 4];
			};
			expected = false;
		}
	];
in ftests.run tests
