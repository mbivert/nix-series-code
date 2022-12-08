#!/bin/nix-instantiate
with builtins;
with (import ./string/strings.nix);
let
	ascii  = (import ./string/ascii.nix);

	# --- lazy lists (partial) implementation ---
	cons   = h: t: [h t];
	car    = xs: elemAt xs 0;
	cdr    = xs: elemAt xs 1;

	zeroes = cons 0 (zeroes);

	# --- list zipper implementation ---
	# (aka, double-infinite stream)
	tape  = b: e: a: [b e a];
	prev  = xs: elemAt xs 0;
	elem  = xs: elemAt xs 1;
	next  = xs: elemAt xs 2;

	right = t:    tape (cons (elem t) (prev t)) (car (next t)) (cdr (next t));
	left  = t:    tape (cdr (prev t)) (car (prev t)) (cons (elem t) (next t));
	alter = t: n: tape (prev t) ((elem t) + n) (next t);

	# --- Starting state ---
	state = {
		mem = tape zeroes 0 zeroes;

		# stdin/stdout ("in" is a reserved keyword)
		xin = "";
		out = "";

		# Note that there's only one error (jump failure)
		err = "";

		# Command and pointer to the current character
		# in cmd
		cmd  = "";
		pcmd = 0;

		# Use (_: y: y) to disable (expects
		# a builtins.trace-compatible function).
		dbg = trace;
	};

	# --- Looping ---
	# jump in the given direction
	#	d is the direction (as an increment of i)
	#	a is the type of quote we're jumping away from
	#	b is the type of quote we're jumping away to
	#	e is the value of i marking the end of our search
	#	c is the string (command) we're jumping in
	#	n is our starting position
	jmp = d: a: b: e: c: n: let aux = st: c: i:
		# syntax error
		if (i == e) then null
		else if (charAt c i) == a then
			aux (st + 1) c (i + d)
		else if (charAt c i) == b then
			if st == 1 then i
			else aux (st - 1) c (i + d)
		else aux st c (i + d)
		; in aux 0 c n;

	jmpnxt = c: jmp 1    "[" "]" (stringLength c) c;
	jmpprv =    jmp (-1) "]" "[" 0;

	# --- Entry point ---
	exec = s:
		if s.pcmd == null then
			s // { err = "syntax error: cannot jump"; }
		else if s.pcmd == (stringLength s.cmd) then
			s
		else let
			p = s.dbg(charAt s.cmd s.pcmd) (charAt s.cmd s.pcmd);

		# By default (unless eventually for [ and ]), jump
		# to next instruction at next step
		in let t = (s // { pcmd = s.pcmd + 1; }) // (
			if p == ">" then      { mem = right s.mem;      }
			else if p == "<" then { mem = left  s.mem;      }
			else if p == "+" then { mem = alter s.mem ( 1); }
			else if p == "-" then { mem = alter s.mem (-1); }
			else if p == "." then {
				out = s.out + (ascii.toChar (toString (elem s.mem)));
			} else if p == "," then {
				mem = tape (prev s.mem) (ascii.toInt (charAt s.xin 0)) (next s.mem);
				xin = eat1 s.xin;
			} else if p == "[" && (elem s.mem) == 0 then {
				pcmd = jmpnxt s.cmd s.pcmd;
			} else if p == "]" && (elem s.mem) != 0 then {
				pcmd = jmpprv s.cmd s.pcmd;
			# Comments, no-op
			} else {}
			); in s.dbg(deepSeq t t) (exec t)
		;

	s = exec(state // { dbg = (_: y: y); cmd = ''
		++++++++++[>+++++++>++++++++++>+++>+<<<<-]
		>++.>+.+++++++..+++.>++.<<+++++++++++++++.
		>.+++.------.--------.>+.>.
	'';});
/*
	s = exec(state // { dbg = (_: y: y); cmd = ''
		>+++++++++[<++++++++>-]<.>++++++[<+++++>-]
		<-.+++++++..+++.>>+++++++[<++++++>-]<++.--
		----------.<++++++++.--------.+++.------.--
		------.>+.>++++++++++.
	'';});
*/
in
	s.out

