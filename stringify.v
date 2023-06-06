module json

import strings
import jsany { Any, Null }

pub struct StringifyOpts {
pub:
	pretty bool
}

pub fn stringify(a Any, opts StringifyOpts) string {
	mut buffer := strings.new_builder(64)
	level := if opts.pretty {
		1
	} else {
		0
	}
	write_any(mut buffer, a, level)
	return buffer.str()
}

fn write_any(mut builder strings.Builder, a Any, level int) {
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
			write_string(mut builder, a)
		}
		[]Any {
			write_array(mut builder, a, level)
		}
		map[string]Any {
			write_object(mut builder, a, level)
		}
	}
}

fn write_raw(mut builder strings.Builder, s string) {
	unsafe { builder.write_ptr(s.str, s.len) }
}

const escapable = [u8(`\b`), u8(`\f`), u8(`\n`), u8(`\r`), u8(`\t`), u8(`\\`), u8(`"`)]

const escaped = [u8(`b`), u8(`f`), u8(`n`), u8(`r`), u8(`t`), u8(`\\`), u8(`"`)]

/*
fn write_string(mut builder strings.Builder, s string) {
	builder.write_u8(`"`)
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
	builder.write_u8(`"`)
}
*/

fn write_string(mut builder strings.Builder, s string) {
	builder.write_u8(`"`)
	len := s.len
	mut cur := 0
	for cur < len {
		ch := s[cur]
		rune_len := utf8_char_len(ch)
		if rune_len == 1 {
			idx := json.escapable.index(ch)
			if idx >= 0 {
				builder.write_u8(`\\`)
				builder.write_u8(json.escaped[idx])
			} else {
				builder.write_u8(ch)
			}
			cur++
		} else {
			builder.write_u8(ch)
			rune_end := cur + rune_len
			cur++
			for cur < rune_end {
				builder.write_u8(s[cur])
				cur++
			}
		}
	}
	builder.write_u8(`"`)
}

fn write_array(mut builder strings.Builder, array []Any, level int) {
	builder.write_u8(`[`)
	newlevel := next_level(level)
	last := array.len - 1
	for i, item in array {
		if level > 0 {
			write_indent(mut builder, level)
		}
		write_any(mut builder, item, newlevel)
		if i != last {
			builder.write_u8(`,`)
		}
	}
	if last >= 0 && level > 0 {
		write_indent(mut builder, level - 1)
	}
	builder.write_u8(`]`)
}

fn write_object(mut builder strings.Builder, object map[string]Any, level int) {
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
		write_string(mut builder, key)
		builder.write_u8(`:`)
		if level > 0 {
			builder.write_u8(` `)
		}
		write_any(mut builder, val, newlevel)
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
