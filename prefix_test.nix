#!/usr/bin/env -S nix-instantiate --eval
with builtins;
let
	ftests = (import ./ftests.nix);
	prefix = (import ./prefix.nix);
	tests = [
		{
			descr     = ''exec ""'';
			fun      = (x: prefix.exec x 0);
			args     = "";
			expected = 0;
		}
		{
			descr     = ''exec "3"'';
			fun      = prefix.exec;
			args     = "3";
			expected = 3;
		}
		{
			descr     = ''exec "+"'';
			fun      = (x: prefix.exec x 0 0);
			args     = "+";
			expected = 0;
		}
		{
			descr     = ''exec "+12"'';
			fun      = (x: prefix.exec x 0);
			args     = "+12";
			expected = 12;
		}
		{
			descr     = ''exec "+ 1 2"'';
			fun      = prefix.exec;
			args     = "+1 2";
			expected = 3;
		}
		{
			descr     = ''exec "+1 + 2 33"'';
			fun      = prefix.exec;
			args     = "+1 + 2 33";
			expected = 36;
		}
		{
			descr     = ''exec "*2 +1 + 2hello33"'';
			fun      = prefix.exec;
			args     = "*2 +1 + 2hello33";
			expected = 72;
		}
		{
			descr     = ''exec "+ + 3 * 5 + 2 2 19"'';
			fun      = prefix.exec;
			args     = "+ + 3 * 5 + 2 2 19";
			expected = 3+5*(2+2)+19;
		}
		{
			descr     = ''exec "*2.1 + 1 4.23"'';
			fun      = prefix.exec;
			args     = "*2.1 + 1 4.23";
			expected = 10.983;
		}
/*
		This one is "naturally" an error:
		{
			descr     = ''exec "+ 1 2 3"'';
			fun      = prefix.exec;
			args     = "+ 1 2 3";
			expected = error;
		}
*/
	];
in ftests.run tests
