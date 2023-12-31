module json

import strings
import encoding.utf8
import prantlf.jany { Any, Null }

pub struct StringifyOpts {
pub mut:
	pretty          bool
	trailing_commas bool
	single_quotes   bool
	escape_slashes  bool
	escape_unicode  bool
mut:
	quote u8
}

pub fn stringify(a Any, opts &StringifyOpts) string {
	if opts.single_quotes {
		unsafe {
			opts.quote = `'`
		}
	} else {
		unsafe {
			opts.quote = `"`
		}
	}

	mut builder := strings.new_builder(64)
	level := if opts.pretty {
		1
	} else {
		0
	}
	write_any(mut builder, a, level, opts)
	return builder.str()
}

fn write_any(mut builder strings.Builder, a Any, level int, opts &StringifyOpts) {
	match a {
		Null {
			write_raw(mut builder, json.null_str)
		}
		bool {
			write_raw(mut builder, bool_to_string(a))
		}
		f64 {
			write_raw(mut builder, number_to_string(a))
		}
		string {
			write_string(mut builder, a, opts)
		}
		[]Any {
			write_array(mut builder, a, level, opts)
		}
		map[string]Any {
			write_object(mut builder, a, level, opts)
		}
	}
}

fn write_raw(mut builder strings.Builder, s string) {
	unsafe { builder.write_ptr(s.str, s.len) }
}

const escapable = [u8(`\b`), u8(`\f`), u8(`\n`), u8(`\r`), u8(`\t`)]

const escaped = [u8(`b`), u8(`f`), u8(`n`), u8(`r`), u8(`t`)]

/*
fn write_string(mut builder strings.Builder, s string, opts &StringifyOpts) {
	quote := opts.quote
	builder.write_u8(quote)
	len := s.len
	mut prev := 0
	mut cur := 0
	for cur < len {
		ch := s[cur]
		rune_len := utf8_char_len(ch)
		if rune_len == 1 {
			idx := escapable.index(ch)
			if idx >= 0 {
				if prev < cur {
					unsafe { builder.write_ptr(s.str + prev, cur - prev) }
				}
				builder.write_u8(`\\`)
				builder.write_u8(escaped[idx])
				cur++
				prev = cur
				continue
			}
		}
		cur += rune_len
	}
	if prev < cur {
		unsafe { builder.write_ptr(s.str + prev, cur - prev) }
	}
	builder.write_u8(quote)
}
*/

@[direct_array_access]
fn write_string(mut builder strings.Builder, s string, opts &StringifyOpts) {
	escape_unicode := opts.escape_unicode
	escape_slashes := opts.escape_slashes
	quote := opts.quote
	builder.write_u8(quote)
	len := s.len
	mut cur := 0
	for cur < len {
		ch := s[cur]
		rune_len := utf8_char_len(ch)
		if rune_len == 1 {
			if ch == quote || ch == `\\` || (ch == `/` && escape_slashes) {
				builder.write_u8(`\\`)
				builder.write_u8(ch)
			} else {
				idx := json.escapable.index(ch)
				if idx >= 0 {
					builder.write_u8(`\\`)
					builder.write_u8(json.escaped[idx])
				} else if ch < ` ` {
					builder.write_u8(`\\`)
					builder.write_u8(`u`)
					builder.write_u8(`0`)
					builder.write_u8(`0`)
					if ch < 16 {
						builder.write_u8(`0`)
					} else {
						builder.write_u8(`1`)
					}
					num := ch & 0xf
					dig := if num > 9 {
						num + `a` - 10
					} else {
						num + `0`
					}
					builder.write_u8(dig)
				} else {
					builder.write_u8(ch)
				}
			}
			cur++
		} else if escape_unicode {
			builder.write_u8(`\\`)
			builder.write_u8(`u`)
			utf32 := u32(utf8.get_uchar(s, cur))
			mut buf := []u8{len: 4}
			if utf32 < 0x10000 {
				u16_to_hex(u16(utf32), mut buf)
				unsafe { builder.push_many(buf.data, 4) }
			} else {
				high, low := get_surrogates(u32(utf32))
				u16_to_hex(high, mut buf)
				unsafe { builder.push_many(buf.data, 4) }
				builder.write_u8(`\\`)
				builder.write_u8(`u`)
				u16_to_hex(low, mut buf)
				unsafe { builder.push_many(buf.data, 4) }
			}
			cur += rune_len
		} else {
			unsafe { builder.push_many(s.str + cur, rune_len) }
			cur += rune_len
		}
	}
	builder.write_u8(quote)
}

fn write_array(mut builder strings.Builder, array []Any, level int, opts &StringifyOpts) {
	builder.write_u8(`[`)
	newlevel := next_level(level)
	last := array.len - 1
	for i, item in array {
		if level > 0 {
			write_indent(mut builder, level)
		}
		write_any(mut builder, item, newlevel, opts)
		if i != last || opts.trailing_commas {
			builder.write_u8(`,`)
		}
	}
	if last >= 0 && level > 0 {
		write_indent(mut builder, level - 1)
	}
	builder.write_u8(`]`)
}

fn write_object(mut builder strings.Builder, object map[string]Any, level int, opts &StringifyOpts) {
	builder.write_u8(`{`)
	newlevel := next_level(level)
	mut next := false
	for key, val in object {
		if next {
			builder.write_u8(`,`)
		} else {
			next = true
		}
		if level > 0 {
			write_indent(mut builder, level)
		}
		write_string(mut builder, key, opts)
		builder.write_u8(`:`)
		if level > 0 {
			builder.write_u8(` `)
		}
		write_any(mut builder, val, newlevel, opts)
	}
	if next && opts.trailing_commas {
		builder.write_u8(`,`)
	}
	if next && level > 0 {
		write_indent(mut builder, level - 1)
	}
	builder.write_u8(`}`)
}

fn next_level(level int) int {
	return if level > 0 { level + 1 } else { 0 }
}

fn write_indent(mut builder strings.Builder, level int) {
	builder.write_u8(`\n`)
	for i := 0; i < level * 2; i++ {
		builder.write_u8(` `)
	}
}

const null_str = 'null'

const false_str = 'false'

const true_str = 'true'

fn bool_to_string(b bool) string {
	return if b {
		json.true_str
	} else {
		json.false_str
	}
}

fn number_to_string(n f64) string {
	integer := int(n)
	return if n == integer {
		integer.str()
	} else {
		n.str()
	}
}

fn get_surrogates(utf32 u32) (u16, u16) {
	rest := utf32 - 0x10000
	high := u16(((rest << 12) >> 22) + 0xD800)
	low := u16(((rest << 22) >> 22) + 0xDC00)
	return high, low
}

@[direct_array_access]
fn u16_to_hex(nn u16, mut buf []u8) {
	mut n := nn
	for i := 3; i >= 0; i-- {
		d := u8(n & 0xF)
		buf[i] = if d < 10 { d + `0` } else { d + 87 }
		n >>= 4
	}
}
