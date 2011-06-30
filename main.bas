#include once "lex.bi"
#include once "tree.bi"

type FrogStuff
	'' Emitting
	as integer emit_fo  '' Output file number during emitting
end type

dim shared as FrogStuff frog

private sub write_me()
	lex_xoops("not yet implemented, write me!")
end sub

private sub parse_pp_directive()
	'' #
	lex_skip()

	select case as const (lex_tk())
	case TK_IF

	case TK_IFDEF

	case TK_IFNDEF

	case TK_ELIF

	case TK_ENDIF

	case TK_DEFINE
		lex_skip()
		tree_add(tree_new_define(lex_text()))

	case TK_PRAGMA
		lex_skip()

		select case (*lex_text())
		case "ms_struct"
			lex_skip()
			'' GCC's #pragma ms_struct on | off | reset
			select case (*lex_text())
			case "on"
			case "off", "reset"
			end select

			write_me()

		case else
			write_me()

		end select

	case else
		lex_xoops("unexpected PP directive: '" & *lex_text() & "'")
	end select

	if (lex_tk() = TK_EOL) then
		lex_skip()
	else
		lex_xoops("expected end-of-line following PP directive")
	end if
end sub

private sub parse_header(byref file as string)
	print "parsing '" & file & "'..."
	lex_open(file)
	tree_begin_header(path_strip_ext(file) & ".bi")

	do
		select case as const (lex_tk())
		case TK_HASH
			parse_pp_directive()

		case TK_EOF
			exit do

		case TK_EOL
			lex_skip()

		end select
	loop

	lex_close()
end sub

private sub print_help_and_exit()
	print "usage: frog [ *.h ] [ --help ]"
	print "For every given C header (*.h) an FB header (*.bi) will be generated."
	print "With some luck and not too complex headers the translation should be fine."
	print "If something is wrong or requires a human eye, you will be notified via"
	print "errors and warnings, and there may be notes emitted into the .bi files."
	end 1
end sub

private sub emit(byval what as zstring ptr)
	if (put(#frog.emit_fo, , *what)) then
		xoops("file output failed!")
	end if
end sub

private sub emit_open(byref filename as string)
	frog.emit_fo = freefile()
	if (open(filename, for binary, access write, as #frog.emit_fo)) then
		xoops("could not open output file: '" & filename & "'")
	end if
end sub

private sub emit_close()
	close #frog.emit_fo
	frog.emit_fo = 0
end sub

private sub emit_tree(byval t as FbTree ptr)
	static as integer level = 0

	select case as const (t->type)
	case TREE_DEFINE
		emit("#define ")
		emit(t->text)

	case TREE_INCLUDE
		emit("#include ")
		emit(t->text)

	case else
		xassert(FALSE)
	end select
end sub

private sub emit_header(byval header as FbHeader ptr)
	emit_open(*header->filename)

	dim as FbTree ptr t = header->head
	while (t)
		emit_tree(t)
		t = t->next
	wend

	emit_close()
end sub


''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

	if (__FB_ARGC__ = 1) then
		print_help_and_exit()
	end if

	dim as string arg

	'' Check for command line options
	for i as integer = 1 to (__FB_ARGC__ - 1)
		arg = *__FB_ARGV__[i]

		if (arg[0] <> asc("-")) then
			continue for
		end if

		select case (arg)
		case "--help"
			print_help_and_exit()

		case "--"
			cptr(ubyte ptr, __FB_ARGV__[i])[0] = 0
			exit for

		case else
			oops("unknown command line option: '" & arg & "'")
			print_help_and_exit()

		end select
	next

	lex_global_init()
	tree_global_init()

	'' Parse all files specified on the command line
	for i as integer = 1 to (__FB_ARGC__ - 1)
		arg = *__FB_ARGV__[i]

		'' Ignore args that we emptied when processing the options
		if (len(arg) > 0) then
			parse_header(arg)
		end if
	next

	lex_global_end()

	''transforms_global_init()

	print "done."
	end 0
