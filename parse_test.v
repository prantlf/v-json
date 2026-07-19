module json

import prantlf.jany { Any }

fn test_parse_unicode() {
	r := parse('"\\u2211\\ud83d\\ude01"')!
	assert r == Any('∑😁')
}
