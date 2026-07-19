module json

import prantlf.jany

@[inline]
pub fn marshal_via_jany[T](val T) !string {
	return marshal_via_jany_opt[T](val, &MarshalOpts{})!
}

pub fn marshal_via_jany_opt[T](val T, opts &MarshalOpts) !string {
	a := jany.marshal_opt(val, jany.MarshalOpts{
		enums_as_names: opts.enums_as_names
	})!
	return stringify_opt(a, StringifyOpts{
		pretty:          opts.pretty
		trailing_commas: opts.trailing_commas
		single_quotes:   opts.single_quotes
		escape_slashes:  opts.escape_slashes
		escape_unicode:  opts.escape_unicode
	})
}
