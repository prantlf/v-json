module json

import prantlf.jany

pub struct UnmarshalOpts {
pub:
	ignore_comments        bool
	ignore_trailing_commas bool
	require_all_fields     bool
	forbid_extra_keys      bool
	cast_null_to_default   bool
	ignore_number_overflow bool
}

pub fn unmarshal[T](input string, opts &UnmarshalOpts) !T {
	a := parse(input, ParseOpts{
		ignore_comments: opts.ignore_comments
		ignore_trailing_commas: opts.ignore_trailing_commas
	})!
	return jany.unmarshal[T](a, jany.UnmarshalOpts{
		require_all_fields: opts.require_all_fields
		forbid_extra_keys: opts.forbid_extra_keys
		cast_null_to_default: opts.cast_null_to_default
		ignore_number_overflow: opts.ignore_number_overflow
	})!
}
