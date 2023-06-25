module json

import strings
import prantlf.jany { Any }

#include <stdlib.h>
#include <errno.h>

fn C.strtod(charptr, &charptr) f64

pub struct ParseOpts {
pub mut:
	ignore_comments        bool
	ignore_trailing_commas bool
}

struct Parser {
	opts &ParseOpts = unsafe { nil }
	str  string
mut:
	line       int
	line_start int
}

pub fn parse(str string, opts &ParseOpts) !Any {
	mut p := Parser{
		opts: unsafe { opts }
		str: str
	}

	i := p.find_start()!
	any, next := p.parse_value(i)!
	p.check_end(next)!

	return any
}

[direct_array_access]
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
			str, next := p.parse_string(i)!
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

[direct_array_access]
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

[direct_array_access]
fn (mut p Parser) skip_comment(from int) !int {
	mut i := from + 1
	if i == p.str.len {
		return p.fail(i, 'Expected "/" or "*" but encounted an end when parsing a comment')
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
						return p.fail(i, 'Expected "/" but encounted an end when parsing a multi-line comment')
					}
				}
			}
			return p.fail(i, 'Expected "*/" but encounted an end when parsing a multi-line comment')
		}
		else {
			return from
		}
	}
	return i
}

[direct_array_access]
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

[direct_array_access]
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

[direct_array_access]
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

[direct_array_access]
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

[direct_array_access]
fn (mut p Parser) parse_key(i int) !(string, int) {
	c := p.str[i]
	if c != `"` {
		return p.fail(i, 'Expected \'"\' but got "${rune(c)}" when parsing an object key')
	}
	return p.parse_string(i)!
}

[direct_array_access]
fn (mut p Parser) skip_null(i int) !int {
	if i + 3 >= p.str.len {
		return p.fail(p.str.len, 'Expected "null" but encountered an end when parsing the primitive')
	}
	if p.str[i + 1] != `u` || p.str[i + 2] != `l` || p.str[i + 3] != `l` {
		return p.fail(i, 'Expected "null" but encountered an end when parsing the primitive')
	}
	return i + 4
}

[direct_array_access]
fn (mut p Parser) skip_false(i int) !int {
	if i + 4 >= p.str.len {
		return p.fail(p.str.len, 'Expected "false" but encountered an end when parsing the primitive')
	}
	if p.str[i + 1] != `a` || p.str[i + 2] != `l` || p.str[i + 3] != `s` || p.str[i + 4] != `e` {
		return p.fail(i, 'Expected "false" but encountered an end when parsing the primitive')
	}
	return i + 5
}

[direct_array_access]
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
			unsafe { tos(p.str.str + i, &u8(end) - p.str.str + i) }
		} else {
			unsafe { tos(p.str.str + i, 1) }
		}
		return p.fail(i, 'Expected number but got "${val}" when parsing a number')
	}
	return n, unsafe { &u8(end) - p.str.str }
}

[direct_array_access]
fn (mut p Parser) parse_string(from int) !(string, int) {
	first := from + 1
	mut i, mut c, esc := p.detect_escape(first)!
	if !esc {
		return unsafe { tos(p.str.str + first, i - first) }, i + 1
	}
	mut builder := strings.new_builder(64)
	builder.write_u8(c)
	for i < p.str.len {
		c = p.str[i]
		mut rune_len := utf8_char_len(c)
		if rune_len == 1 {
			match c {
				`"` {
					return builder.str(), i + 1
				}
				`\\` {
					i++
					if i == p.str.len {
						return p.fail(i, 'Unfinished escape sequence encountered when parsing a string')
					}
					c = p.str[i]
					idx := escaped.index(c)
					if idx >= 0 {
						builder.write_u8(escapable[idx])
					} else {
						builder.write_u8(c)
					}
				}
				`\b`, `\f`, `\n`, `\r`, `\t` {
					idx := escapable.index(c)
					return p.fail(i, 'Unexpected whitespace "\\${rune(escaped[idx])}" encountered when parsing a string')
				}
				else {
					builder.write_u8(c)
				}
			}
			i++
			continue
		}
		builder.write_u8(c)
		i += rune_len
		rune_len--
		for rune_len > 0 {
			builder.write_u8(p.str[rune_len])
			rune_len--
		}
	}
	return p.fail(i, 'Unexpected end encountered when parsing a string')
}

[direct_array_access]
fn (mut p Parser) detect_escape(from int) !(int, u8, bool) {
	mut i := from
	for i < p.str.len {
		mut c := p.str[i]
		mut rune_len := utf8_char_len(c)
		if rune_len == 1 {
			match c {
				`"` {
					return i, 0, false
				}
				`\\` {
					i++
					if i == p.str.len {
						return p.fail(i, 'Unfinished escape sequence encountered when parsing a string')
					}
					c = p.str[i]
					idx := escaped.index(c)
					if idx >= 0 {
						c = escapable[idx]
					}
					return i + 1, c, true
				}
				`\b`, `\f`, `\n`, `\r`, `\t` {
					idx := escapable.index(c)
					return p.fail(i, 'Unexpected whitespace "\\${rune(escaped[idx])}" encountered when parsing a string')
				}
				else {}
			}
		}
		i += rune_len
	}
	return p.fail(i, 'Unexpected end encountered when parsing a string')
}
