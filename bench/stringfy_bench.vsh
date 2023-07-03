#!/usr/bin/env -S v -prod run

import benchmark
import os
import x.json2
import prantlf.json

const repeats = 10

har := os.read_file('vlang.io.har.condensed.json')!

any2 := json2.raw_decode(har)!
any := json.parse(har, &json.ParseOpts{})!

condensed := json.StringifyOpts{}
pretty := json.StringifyOpts{
	pretty: true
}

mut b := benchmark.start()

for _ in 0 .. repeats {
	any2.json_str()
}
b.measure('stringifying condensed with x.json2')

for _ in 0 .. repeats {
	json.stringify(any, &condensed)
}
b.measure('stringifying condensed with prantlf.json')

for _ in 0 .. repeats {
	any2.prettify_json_str()
}
b.measure('stringifying pretty with x.json2')

for _ in 0 .. repeats {
	json.stringify(any, &pretty)
}
b.measure('stringifying pretty with prantlf.json')
