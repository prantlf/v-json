module json

import strings { Builder }
import prantlf.jany { Any }

#include <stdlib.h>
#include <errno.h>

fn C.strtod(charptr, &charptr) f64

pub struct ParseOpts {
pub mut:
	ignore_comments        bool
	ignore_trailing_commas bool
	allow_single_quotes    bool
}

struct Parser {
	opts &ParseOpts = unsafe { nil }
	str  string
mut:
	line       int
	line_start int
}

@[inline]
pub fn parse(str string) !Any {
	return parse_opt(str, &ParseOpts{})!
}

pub fn parse_opt(str string, opts &ParseOpts) !Any {
	mut p := Parser{
		opts: unsafe { opts }
		str: str
	}

	i := p.find_start()!
	any, next := p.parse_value(i)!
	p.check_end(next)!

	return any
}

@[direct_array_access]
fn (mut p Parser) parse_value(i int) !(Any, int) {
	c := p.str[i]
	match c {
		`n` {
			return Any(jany.null), p.skip_null(i)!
		}
		`f` {
			return Any(false), p.skip_false(i)!
		}
		`t` {
			return Any(true), p.skip_true(i)!
		}
		`0`...`9`, `-` {
			num, next := p.parse_number(i)!
			return Any(num), next
		}
		`"` {
			str, next := p.parse_string(i, `"`)!
			return Any(str), next
		}
		`'` {
			if !p.opts.allow_single_quotes {
				return p.fail(i, 'Unexpected "\'" when parsing a value')
			}
			str, next := p.parse_string(i, `'`)!
			return Any(str), next
		}
		`[` {
			arr, next := p.parse_array(i)!
			return Any(arr), next
		}
		`{` {
			obj, next := p.parse_object(i)!
			return Any(obj), next
		}
		else {
			return p.fail(i, 'Unexpected "${rune(c)}" when parsing a value')
		}
	}
}

fn (mut p Parser) find_start() !int {
	from := p.after_bom()
	return p.skip_space(from, 'Unexpected end when starting to parse')!
}

@[direct_array_access]
fn (mut p Parser) skip_space(from int, msg string) !int {
	mut i := from
	for i < p.str.len {
		c := p.str[i]
		match c {
			` `, `\t`, `\r` {
				i++
			}
			`\n` {
				i++
				p.line++
				p.line_start = i
			}
			`/` {
				if p.opts.ignore_comments {
					i = p.skip_comment(i)!
				} else {
					break
				}
			}
			else {
				break
			}
		}
	}
	if i == p.str.len {
		if i == 0 {
			return p.fail(i, 'Empty input encountered when starting to parse')
		}
		return p.fail(i, msg)
	}
	return i
}

@[direct_array_access]
fn (mut p Parser) skip_comment(from int) !int {
	mut i := from + 1
	if i == p.str.len {
		return p.fail(i, 'Expected "/" or "*" but encountered an end when parsing a comment')
	}
	match p.str[i] {
		`/` {
			i++
			for i < p.str.len {
				c := p.str[i]
				i++
				if c == `\n` {
					p.line++
					p.line_start = i
					break
				}
			}
			return i
		}
		`*` {
			i++
			for i < p.str.len {
				mut c := p.str[i]
				i++
				if c == `\n` {
					p.line++
					p.line_start = i
				} else if c == `*` {
					if i < p.str.len {
						c = p.str[i]
						i++
						if c == `/` {
							return i
						}
					} else {
						return p.fail(i, 'Expected "/" but encountered an end when parsing a multi-line comment')
					}
				}
			}
			return p.fail(i, 'Expected "*/" but encountered an end when parsing a multi-line comment')
		}
		else {
			return from
		}
	}
	return i
}

@[direct_array_access]
fn (mut p Parser) after_bom() int {
	if p.str.len >= 3 {
		unsafe {
			text := p.str.str
			if text[0] == 0xEF && text[1] == 0xBB && text[2] == 0xBF {
				return 3
			}
		}
	}
	return 0
}

@[direct_array_access]
fn (mut p Parser) check_end(from int) ! {
	mut i := from
	for i < p.str.len {
		c := p.str[i]
		match c {
			` `, `\t`, `\r` {
				i++
			}
			`\n` {
				i++
				p.line++
				p.line_start = i
			}
			`/` {
				if p.opts.ignore_comments {
					i = p.skip_comment(i)!
				} else {
					return p.fail(i, 'Unexpected "/" at the end of the parsed content')
				}
			}
			else {
				return p.fail(i, 'Unexpected "${rune(c)}" at the end of the parsed content')
			}
		}
	}
}

@[direct_array_access]
fn (mut p Parser) parse_array(from int) !([]Any, int) {
	mut arr := []Any{}
	mut i := from + 1
	mut comma := 0
	for i < p.str.len {
		i = p.skip_space(i, 'Expected item or "]" but encountered an end')!
		if p.str[i] == `]` {
			if comma == 0 || p.opts.ignore_trailing_commas {
				return arr, i + 1
			}
			return p.fail(comma, 'Expected "]" but got "," when parsing an array')
		}
		a, next := p.parse_value(i)!
		i = p.skip_space(next, 'Expected "," or "]" but encountered an end when parsing an array')!
		arr << a
		c := p.str[i]
		match c {
			`]` {
				return arr, i + 1
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
fn (mut p Parser) parse_object(from int) !(map[string]Any, int) {
	mut obj := map[string]Any{}
	mut i := from + 1
	mut comma := 0
	for i < p.str.len {
		i = p.skip_space(i, 'Expected key or "}" but encountered an end when parsing an object')!
		if p.str[i] == `}` {
			if comma == 0 || p.opts.ignore_trailing_commas {
				return obj, i + 1
			}
			return p.fail(comma, 'Expected "}" but got "," when parsing an object')
		}
		key, next := p.parse_key(i)!
		i = p.skip_space(next, 'Expected ":" but but encountered an end when parsing an object')!
		mut c := p.str[i]
		if c != `:` {
			return p.fail(i, 'Expected ":" but got "${rune(c)}" when parsing an object')
		}
		i++
		i = p.skip_space(i, 'Expected value but encountered an end')!
		a, next2 := p.parse_value(i)!
		obj[key] = a
		i = p.skip_space(next2, 'Expected "," or "}" but encountered an end when parsing an object')!
		c = p.str[i]
		match c {
			`}` {
				return obj, i + 1
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
fn (mut p Parser) parse_key(i int) !(string, int) {
	c := p.str[i]
	if c != `"` && !(c == `'` && p.opts.allow_single_quotes) {
		option := if p.opts.allow_single_quotes {
			' or "\'"'
		} else {
			''
		}
		return p.fail(i, 'Expected \'"\'${option} but got "${rune(c)}" when parsing an object key')
	}
	return p.parse_string(i, c)!
}

@[direct_array_access]
fn (mut p Parser) skip_null(i int) !int {
	if i + 3 >= p.str.len {
		return p.fail(p.str.len, 'Expected "null" but encountered an end when parsing the primitive')
	}
	if p.str[i + 1] != `u` || p.str[i + 2] != `l` || p.str[i + 3] != `l` {
		return p.fail(i, 'Expected "null" but encountered an end when parsing the primitive')
	}
	return i + 4
}

@[direct_array_access]
fn (mut p Parser) skip_false(i int) !int {
	if i + 4 >= p.str.len {
		return p.fail(p.str.len, 'Expected "false" but encountered an end when parsing the primitive')
	}
	if p.str[i + 1] != `a` || p.str[i + 2] != `l` || p.str[i + 3] != `s` || p.str[i + 4] != `e` {
		return p.fail(i, 'Expected "false" but encountered an end when parsing the primitive')
	}
	return i + 5
}

@[direct_array_access]
fn (mut p Parser) skip_true(i int) !int {
	if i + 3 >= p.str.len {
		return p.fail(p.str.len, 'Expected "true" but encountered an end when parsing the primitive')
	}
	if p.str[i + 1] != `r` || p.str[i + 2] != `u` || p.str[i + 3] != `e` {
		return p.fail(i, 'Expected "true" but encountered an end when parsing the primitive')
	}
	return i + 4
}

fn (mut p Parser) parse_number(i int) !(f64, int) {
	end := unsafe { nil }
	C.errno = 0
	n := C.strtod(unsafe { p.str.str + i }, &end)
	if C.errno != 0 {
		val := if end != unsafe { nil } {
			unsafe { tos(p.str.str + i, &u8(end) - p.str.str + i).clone() }
		} else {
			unsafe { tos(p.str.str + i, 1) }
		}
		return p.fail(i, 'Expected number but got "${val}" when parsing a number')
	}
	return n, unsafe { &u8(end) - p.str.str }
}

@[direct_array_access]
fn (mut p Parser) parse_string(from int, quote u8) !(string, int) {
	first := from + 1
	mut i, esc := p.detect_escape(first, quote)!
	if !esc {
		return unsafe { tos(p.str.str + first, i - first).clone() }, i + 1
	}
	mut builder := strings.new_builder(64)
	for j := first; j < i; j++ {
		builder.write_u8(p.str[j])
	}
	i = p.parse_escape_sequence(mut builder, i)!
	for i < p.str.len {
		mut c := p.str[i]
		mut rune_len := utf8_char_len(c)
		if rune_len == 1 {
			match c {
				quote {
					return builder.str(), i + 1
				}
				`\\` {
					i = p.parse_escape_sequence(mut builder, i)!
					continue
				}
				else {
					if c < 32 {
						idx := index_u8(escapable, c)
						if idx >= 0 {
							return p.fail(i, 'Unescaped whitespace "\\${rune(escaped[idx])}" encountered when parsing a string')
						}
						return p.fail(i, 'Unescaped control character "\\u${int(c).hex()}" encountered when parsing a string')
					}
					builder.write_u8(c)
				}
			}
			i++
			continue
		}
		unsafe { builder.push_many(p.str.str + i, rune_len) }
		i += rune_len
	}
	return p.fail(i, 'Unexpected end encountered when parsing a string')
}

@[direct_array_access]
fn (mut p Parser) parse_escape_sequence(mut builder Builder, from int) !int {
	mut i := from + 1
	if i == p.str.len {
		return p.fail(i, 'Unfinished escape sequence encountered when parsing a string')
	}
	mut c := p.str[i]
	idx := index_u8(escaped, c)
	if idx >= 0 {
		builder.write_u8(escapable[idx])
	} else if c == `\\` || c == `/` || c == `"` || (c == `'` && p.opts.allow_single_quotes) {
		builder.write_u8(c)
	} else if c == `u` {
		mut high := u16(0)
		high, i = p.parse_unicode(i + 1)!
		if 0xd800 <= high && high <= 0xdfff {
			if (high & 0xfc00) != 0xd800 {
				return p.fail(i, 'Expected unicode sequence "\\u...." for a high surrogate but encountered "\\u${high.hex()}" when parsing a string')
			}
			if i + 6 > p.str.len {
				return p.fail(i, 'Expected unicode sequence "\\u...." for a low surrogate but encountered an end when parsing a string')
			}
			if p.str[i] != `\\` || p.str[i + 1] != `u` {
				return p.fail(i, 'Expected unicode sequence "\\u...." for a low surrogate but encountered "${p.str[i..
					i + 2]}" when parsing a string')
			}
			mut low := u16(0)
			low, i = p.parse_unicode(i + 2)!
			if (low & 0xfc00) != 0xdc00 {
				return p.fail(i, 'Expected unicode sequence "\\u...." for a low surrogate but encountered "\\u${high.hex()}" when parsing a string')
			}
			utf32 := u32(high << 10) + low - 0x35fdc00
			builder.write_rune(utf32)
		} else {
			builder.write_rune(high)
		}
		return i
	} else {
		return p.fail(i, 'Invalid escape sequence "\\${c}" encountered when parsing a string')
	}
	return i + 1
}

@[direct_array_access]
fn (mut p Parser) detect_escape(from int, quote u8) !(int, bool) {
	mut i := from
	for i < p.str.len {
		mut c := p.str[i]
		mut rune_len := utf8_char_len(c)
		if rune_len == 1 {
			match c {
				quote {
					return i, false
				}
				`\\` {
					return i, true
				}
				else {
					if c < 32 {
						idx := index_u8(escapable, c)
						if idx >= 0 {
							return p.fail(i, 'Unescaped whitespace "\\${rune(escaped[idx])}" encountered when parsing a string')
						}
						return p.fail(i, 'Unescaped control character "\\u${int(c).hex()}" encountered when parsing a string')
					}
				}
			}
		}
		i += rune_len
	}
	return p.fail(i, 'Unexpected end encountered when parsing a string')
}

@[direct_array_access]
fn (mut p Parser) parse_unicode(from int) !(u16, int) {
	if from + 4 > p.str.len {
		return p.fail(from, 'Expected unicode sequence "\\u...." but encountered an end when parsing a string')
	}
	mut num := u16(0)
	end := from + 4
	mut i := from
	for i < end {
		c := p.str[i]
		mut dig := u16(c - `0`)
		if dig < 0 || dig > 9 {
			dig = u16((c & ~32) - `A` + 10)
			if dig < 10 || dig > 15 {
				return p.fail(i, 'Invalid hexadecimal digit in unicode sequence "\\u${p.str[from..
					i + 1]}" encountered when parsing a string')
			}
		}
		num = (num << 4) | dig
		i++
	}
	return u16(num), i
}
