# JSON Parser and Formatter

Strictly parse and format [JSON]/[JSONC]/[JSON5] data.

* Uses a [fast](#performance) recursive descent parser written in V.
* Shows detailed [error messages](#errors) with location context.
* Optionally supports [JSONC] - ignores single-line and multi-line JavaScript-style comments treating them as whitespace and also trailing commas in arrays ans objects.
* Partially supports [JSON5] - allows single-quoted strings. (JSON5 is work in progress.)
* Offers both condensed and prettified [JSON] output.
* Works with the `Any` type suitable for safe handling of [JSON]/[YAML] data.
* Supports statically typed data as well.

Uses [prantlf.jany]. See also the [prantlf.yaml] package and [jsonlint] and [yaml2json] tools.

## Synopsis

```go
import prantlf.json { parse, ParseOpts }

// Prepare a JSON string
json := '{
  "answer": 42
}'

// Parse a data from the JSON string
any := parse(json, ParseOpts{})
```

```go
import prantlf.jany { Any, any_int }
import prantlf.json { stringify, StringifyOpts }

// Create a JSON data
any := Any({
  'answer': any_int(42)
})

// Format the data to a JSON string
str := stringify(any, StringifyOpts{})
```

```go
import prantlf.json { unmarshal, UnmarshalOpts }

// Prepare a JSON string
json := '{
  "answer": 42
}'

// Declare a target object
struct Config {
  answer int
}

// Parse an object from the JSON string
config := unmarshal[Config](json, UnmarshalOpts{})
```

```go
import prantlf.json { stringify, MarshalOpts }

// Declare a source object
struct Config {
  answer int
}

// Assign a source object
config := Config{
  answer: 42
}

// Format the object to a JSON string
str := marshal(config, MarshalOpts{})
```

## Installation

You can install this package either from [VPM] or from GitHub:

```txt
v install prantlf.json
v install --git https://github.com/prantlf/v-json
```

The package with the type `Any` will be installed automatically. You can install it explicitly from [VPM] or from GitHub too:

```txt
v install prantlf.jany
v install --git https://github.com/prantlf/v-jany
```

## API

The following functions are exported:

### parse(input string, opts &ParseOpts) !Any

Parses an `Any` value from a string in the JSON format. See [jany] for more information about the `Any` type. Fields available in `ParseOpts`:

| Name                     | Type   | Default | Description |
|:-------------------------|:-------|:--------|:------------|
| `ignore_comments`        | `bool` | `false` | ignores single-line and multi-line JavaScript-style comments treating them as whitespace |
| `ignore_trailing_commas` | `bool` | `false` | ignores commas behind the last item in an array or in an object             |
| `allow_single_quotes`    | `bool` | `false` | allows single-quoted strings |

```go
any := parse(input, ParseOpts{})!
```

### stringify(any Any, opts &StringifyOpts) !string

Formats an `Any` value to a string according to the JSON specification. See [jany] for more information about the `Any` type. Fields available in `StringifyOpts`:

| Name              | Type   | Default | Description                                                           |
|:------------------|:-------|:--------|:----------------------------------------------------------------------|
| `pretty`          | `bool` | `false` | enables readable formatting using line breaks, spaces and indentation |
| `trailing_commas` | `bool` | `false` | inserts commas behind the last item in an array or in an object       |
| `single_quotes`   | `bool` | `false` | format single-quoted instead of double-quoted strings                 |
| `escape_slashes`  | `bool` | `false` | escape slashes by prefixing them with a backslash (reverse solidus)   |
| `escape_unicode`  | `bool` | `false` | escape multibyte Unicode characters with `\u` literals                |

```go
str := stringify(any, StringifyOpts{ pretty: true })!
```

### marshal[T](value T, opts &MarshalOpts) !string

Marshals a value of `T` to a `string` value. Fields available in `MarshalOpts`:

| Name              | Type   | Default | Description                                                           |
|:------------------|:-------|:--------|:----------------------------------------------------------------------|
| `enums_as_names`  | `bool` | `false` | stores `string` names of enum values instead of their `int` values    |
| `pretty`          | `bool` | `false` | enables readable formatting using line breaks, spaces and indentation |
| `trailing_commas` | `bool` | `false` | inserts commas behind the last item in an array or in an object       |
| `single_quotes`   | `bool` | `false` | format single-quoted instead of double-quoted strings                 |
| `escape_slashes`  | `bool` | `false` | escape slashes by prefixing them with a backslash (reverse solidus)   |
| `escape_unicode`  | `bool` | `false` | escape multibyte Unicode characters with `\u` literals                |

```go
struct Config {
	answer int
}

config := Config{ answer: 42 }
str := marshal(config, MarshalOpts{})!
```

### unmarshal[T](input string, opts &UnmarshalOpts) !T

Unmarshals an `Any` value to a new instance of `T`. Fields available in `UnmarshalOpts`:

| Name                     | Type   | Default | Description                                                                              |
|:-------------------------|:-------|:--------|:-----------------------------------------------------------------------------------------|
| `ignore_comments`        | `bool` | `false` | ignores single-line and multi-line JavaScript-style comments treating them as whitespace |
| `ignore_trailing_commas` | `bool` | `false` | ignores commas behind the last item in an array or in an object                          |
| `allow_single_quotes`    | `bool` | `false` | allows single-quoted strings                                                             |
| `require_all_fields`     | `bool` | `false` | requires a key in the source object for each field in the target struct                  |
| `forbid_extra_keys`      | `bool` | `false` | forbids keys in the source object not mapping to a field in the target struct            |
| `cast_null_to_default`   | `bool` | `false` | allows `null`s in the source data to be translated to default values of V types; `null`s can be unmarshaled only to Option types by default |
| `ignore_number_overflow` | `bool` | `false` | allows losing precision when unmarshaling numbers to smaller numeric types               |

```go
struct Config {
	answer int
}

json := '{
  "answer": 42
}'

config := unmarshal[Config](json, UnmarshalOpts{})!
```

### unmarshal_to[T](input string, mut obj T, opts &UnmarshalOpts) !

Unmarshals an `Any` value to an existing instance of `T`. Fields available in `UnmarshalOpts`:

| Name                     | Type   | Default | Description                                                             |
|:-------------------------|:-------|:--------|:------------------------------------------------------------------------|
| `ignore_comments`        | `bool` | `false` | ignores single-line and multi-line JavaScript-style comments treating them as whitespace |
| `ignore_trailing_commas` | `bool` | `false` | ignores commas behind the last item in an array or in an object             |
| `allow_single_quotes`    | `bool` | `false` | allows single-quoted strings |
| `require_all_fields`     | `bool` | `false` | requires a key in the source object for each field in the target struct |
| `forbid_extra_keys`      | `bool` | `false` | forbids keys in the source object not mapping to a field in the target struct |
| `cast_null_to_default`   | `bool` | `false` | allows `null`s in the source data to be translated to default values of V types; `null`s can be unmarshaled only to Option types by default |
| `ignore_number_overflow` | `bool` | `false` | allows losing precision when unmarshaling numbers to smaller numeric types |

```go
struct Config {
	answer int
}

json := '{
  "answer": 42
}'

mut config := Config{}
config := unmarshal_to(json, mut config, UnmarshalOpts{})!
```

## Errors

For example, the following code:

```go
parse('42 // ultimate answer', ParseOpts{})
```

will fail with the following message:

    Unexpected "/" at the end of the parsed content on line 1, column 4:
    1 | 42 // ultimate answer
      |    ^

The message is formatted using the error fields, for example:

    JsonError {
      reason  string = 'Unexpected "/" at the end of the parsed content'
      offset  int    = 3
      line    int    = 1
      column  int    = 3
    }

## Performance

This module is around 4x faster than `x.json2` when parsing:

    ❯ ./parse_bench.vsh

    SPENT  1130.785 ms in parsing condensed with x.json2
    SPENT   282.204 ms in parsing condensed with prantlf.json
    SPENT  1071.293 ms in parsing pretty with x.json2
    SPENT   271.030 ms in parsing pretty with prantlf.json

and almost 3x faster when stringifying:

    ❯ ./stringify_bench.vsh

    SPENT  1201.283 ms in stringifying condensed with x.json2
    SPENT   439.548 ms in stringifying condensed with prantlf.json
    SPENT  1307.802 ms in stringifying pretty with x.json2
    SPENT   445.283 ms in stringifying pretty with prantlf.json

and almost 4x faster when unmarshalling:

    ❯ ./unmarshal_bench.vsh

    SPENT   155.405 ms in unmarshalling condensed with json
    SPENT  1184.805 ms in unmarshalling condensed with x.json2
    SPENT   330.345 ms in unmarshalling condensed with prantlf.json
    SPENT   153.020 ms in unmarshalling pretty with json
    SPENT  1172.505 ms in unmarshalling pretty with x.json2
    SPENT   304.557 ms in unmarshalling pretty with prantlf.json

and more than 46x and in the pretty mode more than 68x faster when marshalling:

    ❯ ./marshal_bench.vsh

    SPENT    96.876 ms in marshalling condensed with json
    SPENT   516.113 ms in marshalling condensed with x.json2
    SPENT    11.678 ms in marshalling condensed with prantlf.json
    SPENT    87.807 ms in marshalling pretty with json
    SPENT  1027.831 ms in marshalling pretty with x.json2
    SPENT    15.724 ms in marshalling pretty with prantlf.json

## TODO

This is a work in progress.

* Support `replacer` for `stringify` and `marshal` and `reviver` for `parse` and `unmarshal`.
* Finish the [JSON5] support.
* Help fixing a bug in V - generics doesn't support nested structs.

[VPM]: https://vpm.vlang.io/packages/prantlf.json
[prantlf.jany]: https://github.com/prantlf/v-jany
[prantlf.yaml]: https://github.com/prantlf/v-yaml
[jsonlint]: https://github.com/prantlf/v-jsonlint
[yaml2json]: https://github.com/prantlf/v-yaml2json
[JSON]: https://www.json.org/
[JSONC]: https://changelog.com/news/jsonc-is-a-superset-of-json-which-supports-comments-6LwR
[JSON5]: https://spec.json5.org/
[YAML]: https://yaml.org/
