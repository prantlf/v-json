module json

#include <stdlib.h>
#include <errno.h>

fn C.strtod(charptr, &charptr) f64

@[direct_array_access]
fn (mut p Parser) swallow_value(i int) !int {
	c := p.str[i]
	match c {
		`n` {
			return p.skip_null(i)!
		}
		`f` {
			return p.skip_false(i)!
		}
		`t` {
			return p.skip_true(i)!
		}
		`0`...`9`, `-`, `+` {
			_, next := p.parse_number(i)!
			return next
		}
		`"` {
			return p.swallow_string(i, `"`)!
		}
		`'` {
			if !p.opts.allow_single_quotes {
				return p.fail(i, 'Unexpected "\'" when parsing a value')
			}
			return p.swallow_string(i, `'`)!
		}
		`[` {
			return p.swallow_array(i)!
		}
		`{` {
			return p.swallow_object(i)!
		}
		else {
			return p.fail(i, 'Unexpected "${rune(c)}" when parsing a value')
		}
	}
}

@[direct_array_access]
fn (mut p Parser) swallow_array(from int) !int {
	mut i := from + 1
	mut comma := 0
	for i < p.str.len {
		i = p.skip_space(i, 'Expected item or "]" but encountered an end')!
		if p.str[i] == `]` {
			if comma == 0 || p.opts.ignore_trailing_commas {
				return i + 1
			}
			return p.fail(comma, 'Expected "]" but got "," when parsing an array')
		}
		next := p.swallow_value(i)!
		i = p.skip_space(next, 'Expected "," or "]" but encountered an end when parsing an array')!
		c := p.str[i]
		match c {
			`]` {
				return i + 1
			}
			`,` {
				comma = i
				i++
			}
			else {
				return p.fail(i, 'Expected "," or "]" but got "${rune(c)}" when parsing an array')
			}
		}
	}
	return p.fail(i, 'Unexpected end encountered when parsing an array')
}

@[direct_array_access]
fn (mut p Parser) swallow_object(from int) !int {
	mut i := from + 1
	mut comma := 0
	for i < p.str.len {
		i = p.skip_space(i, 'Expected key or "}" but encountered an end when parsing an object')!
		if p.str[i] == `}` {
			if comma == 0 || p.opts.ignore_trailing_commas {
				return i + 1
			}
			return p.fail(comma, 'Expected "}" but got "," when parsing an object')
		}
		next := p.swallow_key(i)!
		i = p.skip_space(next, 'Expected ":" but but encountered an end when parsing an object')!
		mut c := p.str[i]
		if c != `:` {
			return p.fail(i, 'Expected ":" but got "${rune(c)}" when parsing an object')
		}
		i++
		i = p.skip_space(i, 'Expected value but encountered an end')!
		next2 := p.swallow_value(i)!
		i =
			p.skip_space(next2, 'Expected "," or "}" but encountered an end when parsing an object')!
		c = p.str[i]
		match c {
			`}` {
				return i + 1
			}
			`,` {
				comma = i
				i++
			}
			else {
				return p.fail(i, 'Expected "," or "}" but got "${rune(c)}" when parsing an object')
			}
		}
	}
	return p.fail(i, 'Unexpected end encountered when parsing an object')
}

@[direct_array_access]
fn (mut p Parser) swallow_key(i int) !int {
	c := p.str[i]
	if c != `"` && !(c == `'` && p.opts.allow_single_quotes) {
		option := if p.opts.allow_single_quotes {
			' or "\'"'
		} else {
			''
		}
		return p.fail(i, 'Expected \'"\'${option} but got "${rune(c)}" when parsing an object key')
	}
	return p.swallow_string(i, c)!
}

@[direct_array_access]
fn (mut p Parser) swallow_string(from int, quote u8) !int {
	first := from + 1
	mut i, esc := p.detect_escape(first, quote)!
	if !esc {
		return i + 1
	}
	i = p.swallow_escape_sequence(i)!
	for i < p.str.len {
		mut c := p.str[i]
		mut rune_len := utf8_char_len(c)
		if rune_len == 1 {
			match c {
				quote {
					return i + 1
				}
				`\\` {
					i = p.swallow_escape_sequence(i)!
					continue
				}
				else {
					if c < 32 {
						idx := index_u8(escapable, c)
						if idx >= 0 {
							return p.fail(i,
								'Unescaped whitespace "\\${rune(escaped[idx])}" encountered when parsing a string')
						}
						return p.fail(i,
							'Unescaped control character "\\u${int(c).hex()}" encountered when parsing a string')
					}
				}
			}

			i++
			continue
		}
		i += rune_len
	}
	return p.fail(i, 'Unexpected end encountered when parsing a string')
}

@[direct_array_access]
fn (mut p Parser) swallow_escape_sequence(from int) !int {
	mut i := from + 1
	if i == p.str.len {
		return p.fail(i, 'Unfinished escape sequence encountered when parsing a string')
	}
	mut c := p.str[i]
	idx := index_u8(escaped, c)
	if idx >= 0 || c == `\\` || c == `/` || c == `"` || (c == `'` && p.opts.allow_single_quotes) {
	} else if c == `u` {
		mut high := u16(0)
		high, i = p.parse_unicode(i + 1)!
		if 0xd800 <= high && high <= 0xdfff {
			if (high & 0xfc00) != 0xd800 {
				return p.fail(i,
					'Expected unicode sequence "\\u...." for a high surrogate but encountered "\\u${high.hex()}" when parsing a string')
			}
			if i + 6 > p.str.len {
				return p.fail(i,
					'Expected unicode sequence "\\u...." for a low surrogate but encountered an end when parsing a string')
			}
			if p.str[i] != `\\` || p.str[i + 1] != `u` {
				return p.fail(i, 'Expected unicode sequence "\\u...." for a low surrogate but encountered "${p.str[i..
					i + 2]}" when parsing a string')
			}
			mut low := u16(0)
			low, i = p.parse_unicode(i + 2)!
			if (low & 0xfc00) != 0xdc00 {
				return p.fail(i,
					'Expected unicode sequence "\\u...." for a low surrogate but encountered "\\u${high.hex()}" when parsing a string')
			}
		}
		return i
	} else {
		return p.fail(i, 'Invalid escape sequence "\\${c}" encountered when parsing a string')
	}
	return i + 1
}
