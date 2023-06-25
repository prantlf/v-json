module json

import prantlf.jany

pub struct MarshalOpts {
pub mut:
	enums_as_names bool
	pretty         bool
}

pub fn marshal[T](val T, opts &MarshalOpts) !string {
	a := jany.marshal(val, jany.MarshalOpts{
		enums_as_names: opts.enums_as_names
	})!
	return stringify(a, StringifyOpts{
		pretty: opts.pretty
	})
}
