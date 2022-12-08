with builtins;
rec {
	apply = f: l: foldl' (x: y: x y) f l;

	run1 = {descr ? "", fun, args, expected, indent ? ""} :
		let
			# This means, if we want only one argument that is a list,
			# we have to use a list with a single element: [theSingleListArg].
			got = if isList(args) then (apply fun args)
			      else                 (fun args);
			r = got == expected;
			ok = if r then "OK" else "failed!";
		in
			trace("${indent}${ok}\t:${descr}") (if r then r else
			trace("${indent}\tGot:")
			trace(deepSeq got got)
			trace("${indent}\tExpected:")
			trace(deepSeq expected expected)
			r)
	;
	run = foldl' (ok: t: ok && (run1 t)) true;
}
