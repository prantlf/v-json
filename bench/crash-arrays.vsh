#!/usr/bin/env -S v run

// import json
// import os
import v.reflection { get_type }

// Declare structures covering a subset of a HAR file

pub struct HarPage {}

struct HarContent {
	size      i64
	mime_type string @[json: 'mimeType']
}

struct HarResponse {
	content HarContent
}

struct HarEntry {
	response HarResponse
}

pub struct HarLog {
	pages   []HarPage
	entries []HarEntry
}

struct Har {
	log HarLog
}

// Declare public functions printing object contents using generics

pub fn show[T](val T) {
	$if T is string {
		show_string(val)
	} $else $if T is $array {
		show_array(val)
	} $else $if T is $struct {
		panic('unexpected ${T.name} as value')
	} $else {
		print('primitive: ${val.str()}')
	}
}

pub fn show_ref[T](ref &T) {
	$if T is $struct {
		show_struct(ref)
	} $else {
		panic('unexpected ${T.name} as reference')
	}
}

// Declare private functions printing object contents using generics

fn show_array[T](array []T) {
	println('array []${T.name}')
	for i, item in array {
		println('item ${i}')
		$if T is $struct {
			show_struct(&item)
		} $else {
			show(item)
		}
		println('')
	}
}

fn show_struct[T](object &T) {
	println('struct ${T.name}')
	$for field in T.fields {
		mut json_name := field.name
		for attr in field.attrs {
			if attr.starts_with('json: ') {
				json_name = if attr[6] == `'` {
					attr[7..(attr.len - 1)]
				} else {
					attr[6..]
				}
			}
		}

		print('key: ')
		show_string(json_name)
		println('')

		println('value ${T.name}.${field.name} (json: ${json_name}) of type ${type_name(field.typ)}')
		$if field.typ is string {
			print('string: ')
			show_string(object.$(field.name))
		} $else $if field.is_array {
			item := object.$(field.name)
			show_array(item)
		} $else $if field.is_struct {
			item := &(object.$(field.name))
			show_struct(item)
		} $else {
			print('primitive: ')
			print(object.$(field.name).str())
		}
		println('')
	}
}

fn show_string(s string) {
	print(`"`)
	print(s)
	print(`"`)
}

fn type_name(idx int) string {
	if typ := get_type(idx) {
		return typ.name
	}
	panic('unknown type ${idx}')
}

// Read a HAR file and deserialise it using the built-in json support
// raw := os.read_file('har.json')!
// har := json.decode(Har, raw)!

// Simulate a HAR deserialised from a JSON file

har := Har{
	log: HarLog{
		pages:   [
			HarPage{},
		]
		entries: [
			HarEntry{
				response: HarResponse{
					content: HarContent{
						size:      48752
						mime_type: 'text/html'
					}
				}
			},
		]
	}
}

// Show the deserialised object - crashes in array processing

show_ref(har)
