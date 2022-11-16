rec {
	cons    = h: t: (x: if x then h else t);

	nil     = null;
	isEmpty = l: l == nil;
	access  = x: l: if isEmpty l
		then throw "list is empty"
		else l x
	;

	car = access true;
	cdr = access false;
}
