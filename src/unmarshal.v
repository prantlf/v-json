module json

import prantlf.jany

pub struct UnmarshalOpts {
pub mut:
	ignore_comments        bool
	ignore_trailing_commas bool
	allow_single_quotes    bool
	require_all_fields     bool
	forbid_extra_keys      bool
	cast_null_to_default   bool
	ignore_number_overflow bool
}

pub fn unmarshal[T](input string, opts &UnmarshalOpts) !T {
	mut obj := T{}
	unmarshal_to[T](input, mut obj, opts)!
	return obj
}

pub fn unmarshal_to[T](input string, mut obj T, opts &UnmarshalOpts) ! {
	a := parse(input, ParseOpts{
		ignore_comments: opts.ignore_comments
		ignore_trailing_commas: opts.ignore_trailing_commas
		allow_single_quotes: opts.allow_single_quotes
	})!
	jany.unmarshal_to[T](a, mut obj, jany.UnmarshalOpts{
		require_all_fields: opts.require_all_fields
		forbid_extra_keys: opts.forbid_extra_keys
		cast_null_to_default: opts.cast_null_to_default
		ignore_number_overflow: opts.ignore_number_overflow
	})!
}
