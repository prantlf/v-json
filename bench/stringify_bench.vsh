#!/usr/bin/env -S v -prod -use-os-system-to-run run

import benchmark
import os
import x.json2
import prantlf.json as json3

const repeats = 10

har := os.read_file('vlang.io.har.condensed.json')!

any2 := json2.raw_decode(har)!
any3 := json3.parse(har)!

pretty := json3.StringifyOpts{
	pretty: true
}

mut b := benchmark.start()

for _ in 0 .. repeats {
	any2.json_str()
}
b.measure('stringifying condensed with x.json2')

for _ in 0 .. repeats {
	json3.stringify(any3)
}
b.measure('stringifying condensed with prantlf.json')

for _ in 0 .. repeats {
	any2.prettify_json_str()
}
b.measure('stringifying pretty with x.json2')

for _ in 0 .. repeats {
	json3.stringify_opt(any3, &pretty)
}
b.measure('stringifying pretty with prantlf.json')
