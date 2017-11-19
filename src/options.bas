#include once "options.bi"

#include once "fbfrog.bi"
#include once "fbfrog-replacements.bi"
#include once "tk.bi"

using tktokens

constructor BindingOptions()
	for i as integer = lbound(renameopt) to ubound(renameopt)
		renameopt(i).constructor(3, FALSE)
	next
	log = astNewGROUP()
end constructor

destructor BindingOptions()
	for i as integer = 0 to replacementcount - 1
		deallocate(replacements[i].fromcode)
		deallocate(replacements[i].tocode)
	next
	deallocate(replacements)
	astDelete(log)
end destructor

sub BindingOptions.addReplacement(byval fromcode as zstring ptr, byval tocode as zstring ptr, byval tofb as integer)
	var i = replacementcount
	replacementcount += 1
	replacements = reallocate(replacements, replacementcount * sizeof(*replacements))
	clear(replacements[i], 0, sizeof(*replacements))
	with replacements[i]
		.fromcode = strDuplicate(fromcode)
		.tocode = strDuplicate(tocode)
		.tofb = tofb
	end with
end sub

sub BindingOptions.loadOption(byval opt as integer, byval param1 as zstring ptr, byval param2 as zstring ptr)
	select case as const opt
	case OPT_WINDOWSMS        : windowsms        = TRUE
	case OPT_CLONG32          : clong32          = TRUE
	case OPT_FIXUNSIZEDARRAYS : fixunsizedarrays = TRUE
	case OPT_NOFUNCTIONBODIES : nofunctionbodies = TRUE
	case OPT_DROPMACROBODYSCOPES : dropmacrobodyscopes = TRUE
	case OPT_REMOVEEMPTYRESERVEDDEFINES : removeEmptyReservedDefines = TRUE

	case OPT_RENAMETYPEDEF, OPT_RENAMETAG, OPT_RENAMEPROC, _
	     OPT_RENAMEDEFINE, OPT_RENAMEMACROPARAM, OPT_RENAME
		renameopt(opt).addOverwrite(param1, param2)
		have_renames = TRUE

	case OPT_RENAME_, OPT_REMOVE, OPT_REMOVEDEFINE, OPT_REMOVEPROC, OPT_REMOVEVAR, OPT_REMOVE1ST, OPT_REMOVE2ND, _
	     OPT_DROPPROCBODY, OPT_TYPEDEFHINT, OPT_ADDFORWARDDECL, OPT_UNDEFBEFOREDECL, OPT_IFNDEFDECL, _
	     OPT_CONVBODYTOKENS, OPT_FORCEFUNCTION2MACRO, OPT_EXPANDINDEFINE, OPT_NOEXPAND, OPT_EXPAND
		if opt = OPT_RENAME_ then
			have_renames = TRUE
		end if
		idopt(opt).addPattern(param1)

	case OPT_NOSTRING, OPT_STRING
		patterns(opt).parseAndAdd(*param1)

	case OPT_REMOVEINCLUDE
		removeinclude.addOverwrite(param1, NULL)

	case OPT_SETARRAYSIZE
		setarraysizeoptions.addOverwrite(param1, param2)

	case OPT_MOVEABOVE
		var n = astNewTEXT(param1)
		astSetAlias(n, param2)
		astBuildGroupAndAppend(moveaboveoptions, n)

	case OPT_REPLACEMENTS
		dim parser as ReplacementsParser = ReplacementsParser(*param1)
		parser.parse(this)
	end select
end sub

sub BindingOptions.loadOptions()
	var i = script->head
	while i
		assert(i->kind = ASTKIND_OPTION)
		loadOption(i->opt, i->text, i->alias_)
		i = i->nxt
	wend
end sub

sub BindingOptions.print(byref ln as string)
	astAppend(log, astNewTEXT(ln))
end sub

function BindingOptions.prettyId() as string
	return target.id()
end function