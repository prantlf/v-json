module json

import prantlf.jany

pub struct MarshalOpts {
pub mut:
	enums_as_names  bool
	pretty          bool
	trailing_commas bool
	single_quotes   bool
	escape_slashes  bool
}

pub fn marshal[T](val T, opts &MarshalOpts) !string {
	a := jany.marshal(val, jany.MarshalOpts{
		enums_as_names: opts.enums_as_names
	})!
	return stringify(a, StringifyOpts{
		pretty: opts.pretty
		trailing_commas: opts.trailing_commas
		single_quotes: opts.single_quotes
		escape_slashes: opts.escape_slashes
	})
}
