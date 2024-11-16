module json

import prantlf.jany

pub struct UnmarshalOpts {
	ParseOpts
pub mut:
	require_all_fields     bool
	forbid_extra_keys      bool
	cast_null_to_default   bool
	ignore_number_overflow bool
}

@[inline]
pub fn unmarshal[T](input string) !T {
	return unmarshal_opt[T](input, &UnmarshalOpts{})!
}

@[inline]
pub fn unmarshal_opt[T](input string, opts &UnmarshalOpts) !T {
	mut obj := T{}
	unmarshal_opt_to[T](input, mut obj, opts)!
	return obj
}

@[inline]
pub fn unmarshal_to[T](input string, mut obj T) ! {
	unmarshal_opt_to[T](input, mut obj, &UnmarshalOpts{})!
}

pub fn unmarshal_opt_to[T](input string, mut obj T, opts &UnmarshalOpts) ! {
	a := parse_opt(input, ParseOpts{
		ignore_comments:        opts.ignore_comments
		ignore_trailing_commas: opts.ignore_trailing_commas
		allow_single_quotes:    opts.allow_single_quotes
	})!
	jany.unmarshal_opt_to[T](a, mut obj, jany.UnmarshalOpts{
		require_all_fields:     opts.require_all_fields
		forbid_extra_keys:      opts.forbid_extra_keys
		cast_null_to_default:   opts.cast_null_to_default
		ignore_number_overflow: opts.ignore_number_overflow
	})!
}
