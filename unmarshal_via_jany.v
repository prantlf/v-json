module json

import prantlf.jany

@[inline]
pub fn unmarshal_via_jany[T](input string) !T {
	return unmarshal_via_jany_opt[T](input, &UnmarshalOpts{})!
}

@[inline]
pub fn unmarshal_via_jany_opt[T](input string, opts &UnmarshalOpts) !T {
	mut obj := T{}
	unmarshal_via_jany_opt_to[T](input, mut obj, opts)!
	return obj
}

@[inline]
pub fn unmarshal_via_jany_to[T](input string, mut obj T) ! {
	unmarshal_via_jany_opt_to[T](input, mut obj, &UnmarshalOpts{})!
}

pub fn unmarshal_via_jany_opt_to[T](input string, mut obj T, opts &UnmarshalOpts) ! {
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
