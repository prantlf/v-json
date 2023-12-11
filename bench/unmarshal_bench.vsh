#!/usr/bin/env -S v run

import benchmark
import os
import json
// import prantlf.json as json2

struct HarPageTimings {
	on_content_load f64 @[json: 'onContentLoad']
	on_load         f64 @[json: 'onLoad']
}

struct HarPage {
	started_date_time string         @[json: 'startedDateTime']
	id                string
	title             string
	page_timings      HarPageTimings @[json: 'pageTimings']
}

struct HarCreator {
	name    string
	version string
}

struct HarInitiaor {
	typ string @[json: 'type']
}

struct HarCache {
}

struct HarNameValue {
	name  string
	value string
}

struct HarCookie {
	name      string
	value     string
	path      string
	domain    string
	expires   string
	http_hnly bool   @[json: 'httpOnly']
	secure    bool
}

struct HarRequest {
	method       string
	url          string
	http_version string         @[json: 'httpVersion']
	headers      []HarNameValue
	query_string []HarNameValue @[json: 'queryString']
	cookies      []HarCookie
	headers_size int            @[json: 'headersSize']
	body_size    i64            @[json: 'headersSize']
}

struct HarContent {
	size          i64
	mime_type     string @[json: 'mimeType']
	text          string
	redirect_url  string @[json: 'redirectURL']
	headers_size  int    @[json: 'headersSize']
	body_size     i64    @[json: 'headersSize']
	transfer_size i64    @[json: 'bodySize']
	error         string @[json: '_error']
}

struct HarResponse {
	status       i16
	status_text  string      @[json: 'statusText']
	http_version string      @[json: 'httpVersion']
	cookies      []HarCookie
	content      HarContent
}

struct HarTimings {
	blocked          f64
	dns              f64
	ssl              f64
	connect          f64
	send             f64
	wait             f64
	receive          f64
	blocked_queueing f64 @[json: '_blocked_queueing']
}

struct HarEntry {
	initiator         HarInitiaor @[json: '_initiator']
	priority          string      @[json: '_priority']
	resource_type     string      @[json: '_resourceType']
	cache             HarCache
	connection        string
	pageref           string
	request           HarRequest
	response          HarResponse
	server_ip_address string      @[json: 'serverIPAddress']
	started_date_time string      @[json: 'startedDateTime']
	time              f64
	timings           HarTimings
}

struct HarLog {
	version string
	creator HarCreator
	pages   []HarPage
	entries []HarEntry
}

struct Har {
	log HarLog
}

const repeats = 20

raw := os.read_file('vlang.io.har.condensed.json')!

// opts := json2.UnmarshalOpts{}

println(json.decode(Har, raw)!)

mut b := benchmark.start()

for _ in 0 .. repeats {
	json.decode(Har, raw)!
}
b.measure('unmarshalling with json')

// for _ in 0 .. repeats {
// 	json2.unmarshal[Har](raw, &opts)!
// }
// b.measure('unmarshalling with prantlf.json')
