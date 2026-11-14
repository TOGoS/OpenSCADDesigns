// DbgCtxStrLib1.0
// 
// Library for dealing with 'debug context strings' (usually 'dbgctxstr').

function dbgctxstr_errmsg_suffix(dbgctxstr) =
	is_undef(dbgctxstr) || dbgctxstr == "" ? "" :
	str(" (", dbgctxstr, ")");
