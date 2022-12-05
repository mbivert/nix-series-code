# Note that rec is mandatory here
rec {
	fib = n:
		if n == 0 || n == 1 then
			n
		else
			fib(n - 1)+fib(n - 2)
	;
}
