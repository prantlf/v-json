module json

import prantlf.jany { Any }

fn fail_check(err IError) (string, string) {
	return if err is JsonError {
		err.msg(), err.msg_full()
	} else {
		err.msg(), 'other error type'
	}
}

fn failing_test(input string) (string, string) {
	parse(input) or { return fail_check(err) }
	return 'success', ''
}

fn failing_test_opt(input string, opts &ParseOpts) (string, string) {
	parse_opt(input, opts) or { return fail_check(err) }
	return 'success', ''
}

fn test_parse_empty() {
	short, full := failing_test('')
	assert short == 'Empty input encountered when starting to parse on line 1, column 1'
	assert full == 'Empty input encountered when starting to parse:
 1 |
   | ^'
}

fn test_parse_space() {
	short, full := failing_test(' ')
	assert short == 'Unexpected end when starting to parse on line 1, column 2'
	assert full == 'Unexpected end when starting to parse:
 1 |  
   |  ^'
}

fn test_parse_null() {
	r := parse('null')!
	assert r.is_null()
}

fn test_parse_null_short() {
	short, full := failing_test('nul')
	assert short == 'Expected "null" but encountered an end when parsing the primitive on line 1, column 4'
	assert full == 'Expected "null" but encountered an end when parsing the primitive:
 1 | nul
   |    ^'
}

fn test_parse_null_long() {
	short, full := failing_test('nulll')
	assert short == 'Unexpected "l" at the end of the parsed content on line 1, column 5'
	assert full == 'Unexpected "l" at the end of the parsed content:
 1 | nulll
   |     ^'
}

fn test_parse_false() {
	r := parse('false')!
	assert r == Any(false)
}

fn test_parse_false_short() {
	short, full := failing_test('fals')
	assert short == 'Expected "false" but encountered an end when parsing the primitive on line 1, column 5'
	assert full == 'Expected "false" but encountered an end when parsing the primitive:
 1 | fals
   |     ^'
}

fn test_parse_false_long() {
	short, full := failing_test('falsee')
	assert short == 'Unexpected "e" at the end of the parsed content on line 1, column 6'
	assert full == 'Unexpected "e" at the end of the parsed content:
 1 | falsee
   |      ^'
}

fn test_parse_true() {
	r := parse('true')!
	assert r == Any(true)
}

fn test_parse_true_short() {
	short, full := failing_test('tru')
	assert short == 'Expected "true" but encountered an end when parsing the primitive on line 1, column 4'
	assert full == 'Expected "true" but encountered an end when parsing the primitive:
 1 | tru
   |    ^'
}

fn test_parse_true_long() {
	short, full := failing_test('truee')
	assert short == 'Unexpected "e" at the end of the parsed content on line 1, column 5'
	assert full == 'Unexpected "e" at the end of the parsed content:
 1 | truee
   |     ^'
}

fn test_parse_int() {
	r := parse('1')!
	assert r == Any(f64(1))
}

fn test_parse_int_negative() {
	r := parse('-1')!
	assert r == Any(f64(-1))
}

fn test_parse_float() {
	r := parse('1.2')!
	assert r == Any(1.2)
}

fn test_parse_number_bad() {
	short, full := failing_test('1a')
	assert short == 'Unexpected "a" at the end of the parsed content on line 1, column 2'
	assert full == 'Unexpected "a" at the end of the parsed content:
 1 | 1a
   |  ^'
}

fn test_parse_string_empty() {
	r := parse('""')!
	assert r == Any('')
}

fn test_parse_string() {
	r := parse('"a"')!
	assert r == Any('a')
}

fn test_parse_string_escaped() {
	r := parse('"\\t"')!
	assert r == Any('\t')
}

fn test_parse_string_escaped_later() {
	r := parse('"a\\t"')!
	assert r == Any('a\t')
}

fn test_parse_string_escaped_unneeded() {
	r := parse('"\\/"')!
	assert r == Any('/')
}

fn test_parse_string_utf8() {
	r := parse('"🚀"')!
	assert r == Any('🚀')
}

fn test_parse_string_invalid() {
	short, full := failing_test('"\n"')
	assert short == 'Unescaped whitespace "\\n" encountered when parsing a string on line 1, column 2'
	assert full == 'Unescaped whitespace "\\n" encountered when parsing a string:
 1 | "
   |  ^
 2 | "'
}

fn test_parse_string_invalid_2() {
	short, full := failing_test('"\\/\n"')
	assert short == 'Unescaped whitespace "\\n" encountered when parsing a string on line 1, column 4'
	assert full == 'Unescaped whitespace "\\n" encountered when parsing a string:
 1 | "\\/
   |    ^
 2 | "'
}

fn test_parse_string_unfinished() {
	short, full := failing_test('"')
	assert short == 'Unexpected end encountered when parsing a string on line 1, column 2'
	assert full == 'Unexpected end encountered when parsing a string:
 1 | "
   |  ^'
}

fn test_parse_string_unfinished_escape() {
	short, full := failing_test('"\\')
	assert short == 'Unfinished escape sequence encountered when parsing a string on line 1, column 3'
	assert full == 'Unfinished escape sequence encountered when parsing a string:
 1 | "\\' +
		'
   |   ^'
}

fn test_parse_string_unfinished_escape_2() {
	short, full := failing_test('"\\/\\')
	assert short == 'Unfinished escape sequence encountered when parsing a string on line 1, column 5'
	assert full == 'Unfinished escape sequence encountered when parsing a string:
 1 | "\\/\\' +
		'
   |     ^'
}

fn test_parse_bom() {
	arr := [u8(0xEF), u8(0xBB), u8(0xBF), `n`, `u`, `l`, `l`]
	str := unsafe { tos(arr.data, arr.len) }
	r := parse(str)!
	assert r.is_null()
}

fn test_parse_invalid() {
	short, full := failing_test('a')
	assert short == 'Unexpected "a" when parsing a value on line 1, column 1'
	assert full == 'Unexpected "a" when parsing a value:
 1 | a
   | ^'
}

fn test_parse_array_empty() {
	r := parse('[]')!
	assert r == Any([]Any{})
}

fn test_parse_array_empty_unfinished() {
	short, full := failing_test('[')
	assert short == 'Unexpected end encountered when parsing an array on line 1, column 2'
	assert full == 'Unexpected end encountered when parsing an array:
 1 | [
   |  ^'
}

fn test_parse_array_1() {
	r := parse('[1]')!
	assert r == Any([Any(f64(1))])
}

fn test_parse_array_1_unfinished() {
	short, full := failing_test('[1')
	assert short == 'Expected "," or "]" but encountered an end when parsing an array on line 1, column 3'
	assert full == 'Expected "," or "]" but encountered an end when parsing an array:
 1 | [1
   |   ^'
}

fn test_parse_array_2() {
	r := parse('[1,2]')!
	assert r == Any([Any(f64(1)), Any(f64(2))])
}

fn test_parse_array_2_unfinished() {
	short, full := failing_test('[1,')
	assert short == 'Unexpected end encountered when parsing an array on line 1, column 4'
	assert full == 'Unexpected end encountered when parsing an array:
 1 | [1,
   |    ^'
}

fn test_parse_array_nested() {
	r := parse('[[]]')!
	assert r == Any([Any([]Any{})])
}

fn test_parse_array_trailing_comma_no() {
	short, full := failing_test('[1,]')
	assert short == 'Expected "]" but got "," when parsing an array on line 1, column 3'
	assert full == 'Expected "]" but got "," when parsing an array:
 1 | [1,]
   |   ^'
}

fn test_parse_array_trailing_comma() {
	r := parse_opt('[1,]', ParseOpts{ ignore_trailing_commas: true })!
	assert r == Any([Any(f64(1))])
}

fn test_parse_object_empty() {
	r := parse('{}')!
	assert r == Any(map[string]Any{})
}

fn test_parse_object_empty_unfinished() {
	short, full := failing_test('{')
	assert short == 'Unexpected end encountered when parsing an object on line 1, column 2'
	assert full == 'Unexpected end encountered when parsing an object:
 1 | {
   |  ^'
}

fn test_parse_object_key_bad() {
	short, full := failing_test('{1')
	assert short == 'Expected \'"\' but got "1" when parsing an object key on line 1, column 2'
	assert full == 'Expected \'"\' but got "1" when parsing an object key:
 1 | {1
   |  ^'
}

fn test_parse_object_key_unfinished() {
	short, full := failing_test('{"')
	assert short == 'Unexpected end encountered when parsing a string on line 1, column 3'
	assert full == 'Unexpected end encountered when parsing a string:
 1 | {"
   |   ^'
}

fn test_parse_object_key_alone() {
	short, full := failing_test('{"a"')
	assert short == 'Expected ":" but but encountered an end when parsing an object on line 1, column 5'
	assert full == 'Expected ":" but but encountered an end when parsing an object:
 1 | {"a"
   |     ^'
}

fn test_parse_object_colon_alone() {
	short, full := failing_test('{"a":')
	assert short == 'Expected value but encountered an end on line 1, column 6'
	assert full == 'Expected value but encountered an end:
 1 | {"a":
   |      ^'
}

fn test_parse_object_value_alone() {
	short, full := failing_test('{"a":1')
	assert short == 'Expected "," or "}" but encountered an end when parsing an object on line 1, column 7'
	assert full == 'Expected "," or "}" but encountered an end when parsing an object:
 1 | {"a":1
   |       ^'
}

fn test_parse_object_1() {
	r := parse('{"a":1}')!
	assert r == Any({
		'a': Any(f64(1))
	})
}

fn test_parse_object_1_unfinished() {
	short, full := failing_test('{"a":1,')
	assert short == 'Unexpected end encountered when parsing an object on line 1, column 8'
	assert full == 'Unexpected end encountered when parsing an object:
 1 | {"a":1,
   |        ^'
}

fn test_parse_object_2() {
	r := parse('{"a":1, "b":2}')!
	assert r == Any({
		'a': Any(f64(1))
		'b': Any(f64(2))
	})
}

fn test_parse_object_nested() {
	r := parse(' { "a" : { "b" : 1 } } ')!
	assert r == Any({
		'a': Any({
			'b': Any(f64(1))
		})
	})
}

fn test_parse_object_trailing_comma_no() {
	short, full := failing_test('{"a":1,}')
	assert short == 'Expected "}" but got "," when parsing an object on line 1, column 7'
	assert full == 'Expected "}" but got "," when parsing an object:
 1 | {"a":1,}
   |       ^'
}

fn test_parse_object_trailing_comma() {
	r := parse_opt('{"a":1,}', ParseOpts{ ignore_trailing_commas: true })!
	assert r == Any({
		'a': Any(f64(1))
	})
}

fn test_single_line_comment_begin_no() {
	short, full := failing_test('// ultimate answer
42')
	assert short == 'Unexpected "/" when parsing a value on line 1, column 1'
	assert full == 'Unexpected "/" when parsing a value:
 1 | // ultimate answer
   | ^
 2 | 42'
}

fn test_single_line_comment_end_no() {
	short, full := failing_test('42// ultimate answer')
	assert short == 'Unexpected "/" at the end of the parsed content on line 1, column 3'
	assert full == 'Unexpected "/" at the end of the parsed content:
 1 | 42// ultimate answer
   |   ^'
}

fn test_single_line_comment_middle_no() {
	short, full := failing_test('[
  // ultimate
  // answer
  42
]')
	assert short == 'Unexpected "/" when parsing a value on line 3, column 3'
	assert full == 'Unexpected "/" when parsing a value:
 2 | [
 3 |   // ultimate
   |   ^
 4 |   // answer
 5 |   42
 6 | ]'
}

fn test_single_line_comment_begin() {
	r := parse_opt('// ultimate answer
42', ParseOpts{ ignore_comments: true })!
	assert r == Any(f64(42))
}

fn test_single_line_comment_end() {
	r := parse_opt('42// ultimate answer', ParseOpts{ ignore_comments: true })!
	assert r == Any(f64(42))
}

fn test_single_line_comment_middle() {
	r := parse_opt('[
  // ultimate
  // answer
  42
]', ParseOpts{ ignore_comments: true })!
	assert r == Any([Any(f64(42))])
}

fn test_parse_single_line_comment_only() {
	short, full := failing_test_opt('//', ParseOpts{ ignore_comments: true })
	assert short == 'Unexpected end when starting to parse on line 1, column 3'
	assert full == 'Unexpected end when starting to parse:
 1 | //
   |   ^'
}

fn test_parse_single_line_comment_only_no() {
	short, full := failing_test('//')
	assert short == 'Unexpected "/" when parsing a value on line 1, column 1'
	assert full == 'Unexpected "/" when parsing a value:
 1 | //
   | ^'
}

fn test_multi_line_comment_begin_no() {
	short, full := failing_test('/* ultimate answer */
42')
	assert short == 'Unexpected "/" when parsing a value on line 1, column 1'
	assert full == 'Unexpected "/" when parsing a value:
 1 | /* ultimate answer */
   | ^
 2 | 42'
}

fn test_multi_line_comment_end_no() {
	short, full := failing_test('42 /* ultimate answer */')
	assert short == 'Unexpected "/" at the end of the parsed content on line 1, column 4'
	assert full == 'Unexpected "/" at the end of the parsed content:
 1 | 42 /* ultimate answer */
   |    ^'
}

fn test_multi_line_comment_middle_no() {
	short, full := failing_test('[
  /* ultimate
   * answer */
  42
]')
	assert short == 'Unexpected "/" when parsing a value on line 3, column 3'
	assert full == 'Unexpected "/" when parsing a value:
 2 | [
 3 |   /* ultimate
   |   ^
 4 |    * answer */
 5 |   4…'
}

fn test_multi_line_comment_begin() {
	r := parse_opt('/* ultimate answer */
42', ParseOpts{ ignore_comments: true })!
	assert r == Any(f64(42))
}

fn test_multi_line_comment_end() {
	r := parse_opt('42/* ultimate answer */', ParseOpts{ ignore_comments: true })!
	assert r == Any(f64(42))
}

fn test_multi_line_comment_middle() {
	r := parse_opt('[
  /* ultimate
   * answer */
  42
]', ParseOpts{ ignore_comments: true })!
	assert r == Any([Any(f64(42))])
}

fn test_parse_multi_line_comment_only() {
	short, full := failing_test_opt('/**/', ParseOpts{ ignore_comments: true })
	assert short == 'Unexpected end when starting to parse on line 1, column 5'
	assert full == 'Unexpected end when starting to parse:
 1 | /**/
   |     ^'
}

fn test_parse_multi_line_comment_only_no() {
	short, full := failing_test('/**/')
	assert short == 'Unexpected "/" when parsing a value on line 1, column 1'
	assert full == 'Unexpected "/" when parsing a value:
 1 | /**/
   | ^'
}

fn test_parse_object_single_quote() {
	r := parse_opt("{'a':1}", ParseOpts{ allow_single_quotes: true })!
	assert r == Any({
		'a': Any(f64(1))
	})
}

fn test_parse_string_single_quotes_escaped() {
	r := parse_opt("'a\\'b'", ParseOpts{ allow_single_quotes: true })!
	assert r == Any("a'b")
}

fn test_parse_whitespace() {
	r := parse('"\\b\\f\\n\\r\\t "')!
	assert r == Any('\b\f\n\r\t ')
}

fn test_parse_control_chars() {
	r := parse('"\\u0001\\u000e\\u0011\\u001e"')!
	assert r == Any('\u0001\u000e\u0011\u001e')
}

fn test_parse_unicode() {
	r := parse('"\\u2211\\ud83d\\ude01"')!
	assert r == Any('∑😁')
}

fn test_parse_and_write_u8() {
	r := parse('"\\np’s"')!
	assert r == Any('\np’s')
}
