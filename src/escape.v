module json

import strings

pub struct EscapeOpts {
pub mut:
	single_quotes  bool
	escape_slashes bool
	escape_unicode bool
mut:
	quote u8
}

@[inline]
pub fn escape(s string) string {
	return escape_opt(s, &EscapeOpts{})
}

pub fn escape_opt(s string, opts &EscapeOpts) string {
	mut builder := strings.new_builder(s.len + 64)
	mut str_opts := StringifyOpts{
		single_quotes: opts.single_quotes
		escape_slashes: opts.escape_slashes
		escape_unicode: opts.escape_unicode
	}
	str_opts.quote = if opts.single_quotes { `'` } else { `"` }
	write_string(mut builder, s, str_opts, false)
	return builder.str()
}
