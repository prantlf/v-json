module json

import prantlf.jany { Any }

fn test_stringify_null() {
	r := stringify(Any(jany.null))
	assert r == 'null'
}

fn test_stringify_int() {
	r := stringify(Any(f64(1)))
	assert r == '1'
}

fn test_stringify_float() {
	r := stringify(Any(1.2))
	assert r == '1.2'
}

fn test_stringify_bool() {
	r := stringify(Any(true))
	assert r == 'true'
}

fn test_stringify_string() {
	r := stringify(Any('a'))
	assert r == '"a"'
}

fn test_stringify_escaped_string() {
	r := stringify(Any('a"b'))
	assert r == '"a\\"b"'
}

fn test_stringify_empty_array() {
	r := stringify(Any([]Any{}))
	assert r == '[]'
}

fn test_stringify_array_1() {
	r := stringify(Any([Any(f64(1))]))
	assert r == '[1]'
}

fn test_stringify_array_2() {
	r := stringify(Any([Any(f64(1)), Any(f64(2))]))
	assert r == '[1,2]'
}

fn test_stringify_empty_object() {
	r := stringify(Any(map[string]Any{}))
	assert r == '{}'
}

fn test_stringify_object_1() {
	r := stringify(Any({
		'a': Any(f64(1))
	}))
	assert r == '{"a":1}'
}

fn test_stringify_object_2() {
	r := stringify(Any({
		'a': Any(f64(1))
		'b': Any(f64(2))
	}))
	assert r == '{"a":1,"b":2}'
}

fn test_stringify_trailing_commas() {
	r := stringify_opt(Any({
		'a': Any([Any(f64(1)), Any(f64(2))])
		'b': Any(f64(3))
	}), StringifyOpts{ trailing_commas: true, pretty: true })
	assert r == '{
  "a": [
    1,
    2,
  ],
  "b": 3,
}'
}

fn test_stringify_object_single_quotes() {
	r := stringify_opt(Any({
		'a': Any(f64(1))
	}), StringifyOpts{ single_quotes: true })
	assert r == "{'a':1}"
}

fn test_stringify_escaped_single_quotes() {
	r := stringify_opt(Any("a'b"), StringifyOpts{ single_quotes: true })
	assert r == "'a\\'b'"
}

fn test_stringify_escape_slashes() {
	r := stringify_opt(Any('a/b'), StringifyOpts{ escape_slashes: true })
	assert r == '"a\\/b"'
}

fn test_stringify_whitespace() {
	r := stringify_opt(Any('\b\f\n\r\t '), StringifyOpts{ escape_slashes: true })
	assert r == '"\\b\\f\\n\\r\\t "'
}

fn test_stringify_escape_control_chars() {
	r := stringify_opt(Any('\u0001\u000e\u0011\u001e'), StringifyOpts{ escape_slashes: true })
	assert r == '"\\u0001\\u000e\\u0011\\u001e"'
}

fn test_stringify_escape_unicode() {
	r := stringify_opt(Any('ö∑😁'), StringifyOpts{ escape_unicode: true })
	assert r == '"\\u00f6\\u2211\\ud83d\\ude01"'
}

fn test_parse_and_write_u8() {
	r := stringify(Any('\np’s'))
	assert r == '"\\np’s"'
}
