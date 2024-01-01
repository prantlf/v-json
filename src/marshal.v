module json

import strings { Builder }
import v.reflection

pub struct MarshalOpts {
	StringifyOpts
pub mut:
	enums_as_names bool
}

@[inline]
pub fn marshal[T](val T) string {
	return marshal_opt[T](val, &MarshalOpts{})
}

pub fn marshal_opt[T](val T, opts &MarshalOpts) string {
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
	marshal_any(mut builder, val, level, opts)
	return builder.str()
}

fn marshal_any[T](mut builder Builder, val T, level int, opts &MarshalOpts) {
	$if T is $enum {
		marshal_enum(mut builder, val, opts)
	} $else $if T is string {
		write_string(mut builder, val, &StringifyOpts(opts))
	} $else $if T is $array {
		marshal_array(mut builder, val, level, opts)
	} $else $if T is $map {
		marshal_map(mut builder, val, level, opts)
	} $else $if T is $struct {
		marshal_struct(mut builder, &val, level, opts)
	} $else {
		builder.write_string(val.str())
	}
}

fn type_name(idx int) string {
	return if typ := reflection.get_type(idx) {
		typ.name
	} else {
		'unknown'
	}
}

fn enum_vals(idx int) []string {
	return if typ := reflection.get_type(idx) {
		if typ.sym.info is reflection.Enum {
			typ.sym.info.vals
		} else {
			panic('not an enum ${typ.name}')
		}
	} else {
		panic('unknown enum')
	}
}

@[direct_array_access]
fn marshal_enum[T](mut builder Builder, val T, opts &MarshalOpts) {
	ival := int(val)
	if opts.enums_as_names {
		enums := enum_vals(T.idx)
		if ival >= 0 || ival < enums.len {
			builder.write_u8(opts.quote)
			write_raw(mut builder, enums[ival])
			builder.write_u8(opts.quote)
			return
		}
	}
	write_raw(mut builder, ival.str())
}

fn marshal_array[T](mut builder Builder, array []T, level int, opts &MarshalOpts) {
	builder.write_u8(`[`)
	newlevel := next_level(level)
	last := array.len - 1
	for i, item in array {
		if level > 0 {
			write_indent(mut builder, level)
		}
		marshal_any(mut builder, item, newlevel, opts)
		// $if T is $enum {
		// 	marshal_enum(mut builder, item, opts)
		// } $else $if T is string {
		// 	write_string(mut builder, item, &StringifyOpts(opts))
		// } $else $if T is $array {
		// 	marshal_array(mut builder, item, newlevel, opts)
		// } $else $if T is $map {
		// 	marshal_map(mut builder, item, newlevel, opts)
		// } $else $if T is $struct {
		// 	marshal_struct(mut builder, &item, newlevel, opts)
		// } $else {
		// 	builder.write_string(item.str())
		// }
		if i != last || opts.trailing_commas {
			builder.write_u8(`,`)
		}
	}
	if last >= 0 && level > 0 {
		write_indent(mut builder, level - 1)
	}
	builder.write_u8(`]`)
}

fn marshal_map[T](mut builder Builder, object map[string]T, level int, opts &MarshalOpts) {
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
		write_string(mut builder, key, &StringifyOpts(opts))
		builder.write_u8(`:`)
		if level > 0 {
			builder.write_u8(` `)
		}
		marshal_any(mut builder, val, newlevel, opts)
	}
	if next && opts.trailing_commas {
		builder.write_u8(`,`)
	}
	if next && level > 0 {
		write_indent(mut builder, level - 1)
	}
	builder.write_u8(`}`)
}

fn marshal_struct[T](mut builder Builder, object &T, level int, opts &MarshalOpts) {
	builder.write_u8(`{`)
	newlevel := next_level(level)
	mut next := false
	$for field in T.fields {
		mut json_name := field.name
		mut skip := false
		for attr in field.attrs {
			if attr.starts_with('json: ') {
				json_name = attr[6..]
			} else if attr == 'skip' {
				skip = true
			}
		}

		if skip {
		} else {
			if next {
				builder.write_u8(`,`)
			} else {
				next = true
			}
			if level > 0 {
				write_indent(mut builder, level)
			}

			write_string(mut builder, json_name, &StringifyOpts(opts))
			builder.write_u8(`:`)
			if level > 0 {
				builder.write_u8(` `)
			}
			// item := object.$(field.name)
			// marshal_any(mut builder, item, newlevel, opts)
			$if field.is_enum {
				item := object.$(field.name)
				$if field.is_option {
					if val := item {
						marshal_enum(mut builder, val, opts)
					} else {
						write_raw(mut builder, null_str)
					}
				} $else {
					marshal_enum(mut builder, item, opts)
				}
			} $else $if field.typ is string {
				item := object.$(field.name)
				$if field.is_option {
					if val := item {
						write_string(mut builder, val, &StringifyOpts(opts))
					} else {
						write_raw(mut builder, null_str)
					}
				} $else {
					write_string(mut builder, item, &StringifyOpts(opts))
				}
			} $else $if field.is_array {
				item := object.$(field.name)
				$if field.is_option {
					if val := item {
						marshal_array(mut builder, val, newlevel, opts)
					} else {
						write_raw(mut builder, null_str)
					}
				} $else {
					marshal_array(mut builder, item, newlevel, opts)
				}
			} $else $if field.is_map {
				item := object.$(field.name)
				$if field.is_option {
					if val := item {
						marshal_map(mut builder, val, newlevel, opts)
					} else {
						write_raw(mut builder, null_str)
					}
				} $else {
					marshal_map(mut builder, item, newlevel, opts)
				}
			} $else $if field.is_struct {
				item := object.$(field.name)
				$if field.is_option {
					if val := item {
						marshal_struct(mut builder, val, newlevel, opts)
					} else {
						write_raw(mut builder, null_str)
					}
				} $else {
					marshal_struct(mut builder, item, newlevel, opts)
				}
				// } $else $if field.typ is int || field.typ is u8 || field.typ is u16 || field.typ is u32
				// 	|| field.typ is u64 || field.typ is i8 || field.typ is i16 || field.typ is i64
				// 	|| field.typ is f32 || field.typ is f64 || field.typ is bool {
			} $else {
				item := object.$(field.name)
				$if field.is_option {
					if val := item {
						builder.write_string(val.str())
					} else {
						write_raw(mut builder, null_str)
					}
				} $else {
					builder.write_string(item.str())
				}
				// } $else {
				// 	panic('unsupported type ${type_name(field.typ)} of ${T.name}.${field.name}')
			}
		}
	}
	if next && opts.trailing_commas {
		builder.write_u8(`,`)
	}
	if next && level > 0 {
		write_indent(mut builder, level - 1)
	}
	builder.write_u8(`}`)
}
