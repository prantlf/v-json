module json

import prantlf.jany { Any }

fn test_stringify_null() {
	r := stringify(Any(jany.null), StringifyOpts{})
	assert r == 'null'
}

fn test_stringify_int() {
	r := stringify(Any(f64(1)), StringifyOpts{})
	assert r == '1'
}

fn test_stringify_float() {
	r := stringify(Any(1.2), StringifyOpts{})
	assert r == '1.2'
}

fn test_stringify_bool() {
	r := stringify(Any(true), StringifyOpts{})
	assert r == 'true'
}

fn test_stringify_string() {
	r := stringify(Any('a'), StringifyOpts{})
	assert r == '"a"'
}

fn test_stringify_escaped_string() {
	r := stringify(Any('a"b'), StringifyOpts{})
	assert r == '"a\\"b"'
}

fn test_stringify_empty_array() {
	r := stringify(Any([]Any{}), StringifyOpts{})
	assert r == '[]'
}

fn test_stringify_array_1() {
	r := stringify(Any([Any(f64(1))]), StringifyOpts{})
	assert r == '[1]'
}

fn test_stringify_array_2() {
	r := stringify(Any([Any(f64(1)), Any(f64(2))]), StringifyOpts{})
	assert r == '[1,2]'
}

fn test_stringify_empty_object() {
	r := stringify(Any(map[string]Any{}), StringifyOpts{})
	assert r == '{}'
}

fn test_stringify_object_1() {
	r := stringify(Any({
		'a': Any(f64(1))
	}), StringifyOpts{})
	assert r == '{"a":1}'
}

fn test_stringify_object_2() {
	r := stringify(Any({
		'a': Any(f64(1))
		'b': Any(f64(2))
	}), StringifyOpts{})
	assert r == '{"a":1,"b":2}'
}

fn test_stringify_trailing_commas() {
	r := stringify(Any({
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
	r := stringify(Any({
		'a': Any(f64(1))
	}), StringifyOpts{ single_quotes: true })
	assert r == "{'a':1}"
}

fn test_stringify_escaped_single_quotes() {
	r := stringify(Any("a'b"), StringifyOpts{ single_quotes: true })
	assert r == "'a\\'b'"
}
