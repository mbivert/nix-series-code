rec {
	true   = (x: y: x);
	false  = (x: y: y);
	ifelse = p: x: y: p x y;

	cons    = h: t: (x: ifelse x h t);

	nil     = null;
	isEmpty = l: l == nil;
	access  = x: l: if isEmpty l
		then throw "list is empty"
		else l x
	;

	car = access true;
	cdr = access false;
}
