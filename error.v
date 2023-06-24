module json

import strings

pub struct JsonError {
	Error
	head_context string
	head_error   string
	tail_error   string
	tail_context string
pub:
	reason string
	offset int
	line   int
	column int
}

pub fn (e &JsonError) msg() string {
	return '${e.reason} on line ${e.line}, column ${e.column}'
}

pub fn (e &JsonError) msg_full() string {
	before := (e.head_context + e.head_error + e.tail_error).split_into_lines()
	after := e.tail_context.split_into_lines()

	last_line := e.line - 1 + before.len + after.len
	num_len := last_line.str().len + 1

	mut builder := strings.new_builder(64)
	mut line_num := e.line - before.len

	if before.len == 0 {
		builder.write_string(' 1 |\n')
	}
	line_num = write_context(mut builder, before, line_num, num_len, false)
	write_pointer(mut builder, num_len, e.head_error.len)
	write_context(mut builder, after, line_num, num_len, true)

	return '${e.reason}:\n${builder.str()}'
}

fn write_context(mut builder strings.Builder, lines []string, start_line int, num_len int, eol_before bool) int {
	mut line_num := start_line
	for line in lines {
		if eol_before {
			builder.write_u8(`\n`)
		}
		line_num++
		num_str := line_num.str()
		for i := num_str.len; i < num_len; i++ {
			builder.write_u8(` `)
		}
		builder.write_string(num_str)
		builder.write_string(' | ')
		builder.write_string(line)
		if !eol_before {
			builder.write_u8(`\n`)
		}
	}
	return line_num
}

fn write_pointer(mut builder strings.Builder, num_len int, head_len int) {
	for i := 0; i < num_len + 1; i++ {
		builder.write_u8(` `)
	}
	builder.write_u8(`|`)
	for i := 0; i < head_len + 1; i++ {
		builder.write_u8(` `)
	}
	builder.write_u8(`^`)
}

fn (mut p Parser) fail(offset int, msg string) JsonError {
	head_context, head_error := before_error(p.str, offset)
	tail_error, tail_context := after_error(p.str, offset)

	return JsonError{
		reason: msg
		head_context: head_context
		head_error: head_error
		tail_error: tail_error
		tail_context: tail_context
		offset: offset + 1
		line: p.line_start + 1
		column: offset - p.line_start + 1
	}
}

fn before_error(input string, offset int) (string, string) {
	if input.len == 0 {
		return '', ''
	}

	mut inline := if offset > 20 {
		'…' + input[offset - 20..offset]
	} else {
		input[..offset]
	}

	mut head := ''
	eol := inline.last_index_u8(`\n`) + 1
	if eol > 0 {
		head = inline[..eol]
		inline = inline[eol..]
	}

	return head, inline
}

fn after_error(input string, offset int) (string, string) {
	if input.len == 0 {
		return '', ''
	}

	mut inline := if offset + 20 < input.len {
		input[offset..offset + 20] + '…'
	} else {
		input[offset..]
	}

	mut tail := ''
	eol := inline.index_u8(`\n`)
	if eol >= 0 {
		tail = inline[eol + 1..]
		inline = inline[..eol]
	}

	return inline, tail
}
