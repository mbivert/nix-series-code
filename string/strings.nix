with builtins;
with (import ./ascii.nix);
rec {
	charAt     = s: n: substring n 1 s;
	eat1       = s:    substring 1 ((stringLength s) - 1) s;
	skipWhites = s: n: if isWhite (charAt s n) then skipWhites s (n + 1) else n;
}
