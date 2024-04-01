#!/bin/nix-instantiate --eval
with builtins;
let
	foldlnseq = x: f: s: n: let aux = acc: i:
		if i > n then
			acc
		else
			aux (f acc (x i)) (i + 1)
		; in aux s 1;

	foldlnp = p: f:
		foldlnseq
			(i: if p(i) then i else null)
			(x: y: if y == null then x else f x y);

	# foldln is now a special case of foldlnseq
	foldln = foldlnseq (x: x);

	# foldln sample usage
	sum  = foldln add 0;
	fact = foldln mul 1;

	# Importing fib
	fib = n:
		if n == 0 || n == 1 then
			n
		else
			fib(n - 1)+fib(n - 2)
	;

	# Nix idiosyncracies
	toFloat = n: n + 0.1 - 0.1;
	isDiv   = i: j: ceil(toFloat(i) / j) * j == i;
	isEven  = n: isDiv n 2;
	isOdd   = n: !(isEven n);

	# Helpers (we could do without, but they make things clear)
	foldlnr    = f: s: m: foldlnp (i: i >= m) f s;
	foldlneven = foldlnp isEven;
	foldlnodd  = foldlnp isOdd;

	# ------ answers ------
	sumfib  = foldlnseq fib  add 0;
	sumfact = foldlnseq fact add 0;

	sumr    = foldlnr    add 0;
	sumeven = foldlneven add 0;
	sumodd  = foldlnodd  add 0;

	xs = [
		(sum 10)
		(fact 5)
		(sumr 5 10)
		(sumr 1 4)
		(sumeven 10)
		(sumodd 10)
		# https://www.wolframalpha.com/input?i2d=true&i=Sum%5Bi%21%2C%7Bi%2C1%2C5%7D%5D
		(sumfact 5)
		# https://www.wolframalpha.com/input?i2d=true&i=Sum%5BF_i%2C%7Bi%2C1%2C10%7D%5D
		(sumfib 10)
	];
in
	deepSeq xs xs
