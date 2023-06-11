# JSON Parser and Formatter

Strictly parse and format JSON data.

* Condensed and prettified JSON output.
* Works with the `Any` type suitable for safe handling of JSON/YAML data.

Uses [jany]. See also the [yaml] package and the [yaml2json] tool.

## Synopsis

```go
import prantlf.jany { Any, any_int }
import prantlf.json { stringify, StringifyOpts }

// Create JSON data
any := Any({
  'answer': any_int(42)
})

// Format the data to JSON string
str := stringify(any, StringifyOpts{})
```

## Installation

You can install this package either from [VPM] or from GitHub:

```txt
v install prantlf.json
v install --git https://github.com/prantlf/v-json
```

You will usually need the `Any` type as well, either from [VPM] or from GitHub:

```txt
v install prantlf.jany
v install --git https://github.com/prantlf/v-jany
```

## API

The following functions are exported:

### stringify(any Any, opts StringifyOpts) !string

Formats an `Any` value to a string according to the JSON specification. See [jany] for more information about the `Any` type. Fields available in `StringifyOpts`:

| Name     | Type   | Default | Description                                                           |
|:---------|:-------|:--------|:----------------------------------------------------------------------|
| `pretty` | `bool` | `false` | enables readable formatting using line breaks, spaces and indentation |

```go
str := stringify(any, StringifyOpts{ pretty: true })
```

## TODO

This is a work in progress.

* Add the function `parse`.
* Support `replacer` for `stringify` and `reviver` for `parse`.

[VPM]: https://vpm.vlang.io/packages/prantlf.jany
[jany]: https://github.com/prantlf/v-jany
[yaml]: https://github.com/prantlf/v-yaml
[yaml2json]: https://github.com/prantlf/v-yaml2json
