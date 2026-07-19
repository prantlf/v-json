module json

fn test_escape_string() {
	r := escape('a')
	assert r == 'a'
}

fn test_escape_escaped_string() {
	r := escape('a"\'b')
	assert r == 'a\\"\'b'
}

fn test_escape_escaped_single_quotes() {
	r := escape_opt('a\'"b', EscapeOpts{ single_quotes: true })
	assert r == 'a\\\'"b'
}

fn test_escape_escape_slashes() {
	r := escape_opt('a/b', EscapeOpts{ escape_slashes: true })
	assert r == 'a\\/b'
}

fn test_escape_whitespace() {
	r := escape('\b\f\n\r\t ')
	assert r == '\\b\\f\\n\\r\\t '
}

fn test_escape_escape_control_chars() {
	r := escape('\u0001\u000e\u0011\u001e')
	assert r == '\\u0001\\u000e\\u0011\\u001e'
}

fn test_escape_escape_unicode() {
	r := escape_opt('ö∑😁', EscapeOpts{ escape_unicode: true })
	assert r == '\\u00f6\\u2211\\ud83d\\ude01'
}
