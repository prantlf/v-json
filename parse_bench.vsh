#!/usr/bin/env -S v -prod run

import benchmark
import os
import x.json2
import prantlf.json

const repeats = 20

condensed := os.read_file('vlang.io.har.condensed.json')!
pretty := os.read_file('vlang.io.har.pretty.json')!

opts := json.ParseOpts{}

mut b := benchmark.start()

for _ in 0 .. repeats {
	json2.raw_decode(condensed)!
}
b.measure('parsing condensed with x.json2')

for _ in 0 .. repeats {
	json.parse(condensed, &opts)!
}
b.measure('parsing condensed with prantlf.json')

for _ in 0 .. repeats {
	json2.raw_decode(pretty)!
}
b.measure('parsing pretty with x.json2')

for _ in 0 .. repeats {
	json.parse(pretty, &opts)!
}
b.measure('parsing pretty with prantlf.json')
