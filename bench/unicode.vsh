#!/usr/bin/env -S v -prod run

import encoding.utf8

fn utf32_to_utf16(utf32 u32) (u16, u16) {
	if utf32 < 0x10000 {
		return 0, u16(utf32)
	}
	rest := utf32 - 0x10000
	high := u16(((rest << 12) >> 22) + 0xD800)
	low := u16(((rest << 22) >> 22) + 0xDC00)
	return high, low
}

fn print_unicode(s string) {
	println(s)
	println(s.len)
	println(s.len_utf8())
	println(s.bytes())
	println(s.runes())
	utf32 := utf8.get_uchar(s, 0)
	println(utf32.hex())
	high, low := utf32_to_utf16(u32(utf32))
	println('${high.hex()} ${low.hex()}')
}

print_unicode('∑')
print_unicode('😁')
