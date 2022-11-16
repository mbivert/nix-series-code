with builtins;
rec {
	true   = (x: y: x);
	false  = (x: y: y);
	ifelse = p: x: y: p x y;

	nil    = (a: b: a);
	cons   = h: t: (a: b: (b h t));

	isEmpty = l: l true (a: b: false);

	access  = x: l:
		l
			(throw "list is empty")
			(h: t: ifelse x h t);

	car = access true;
	cdr = access false;
}
