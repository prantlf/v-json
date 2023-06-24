# JSON Parser and Formatter

Strictly parse and format [JSON]/[JSONC] data.

* Uses a [fast](#performance) recursive descent parser written in V.
* Shows detailed [error messages](#errors) with location context.
* Optionally supports [JSONC] - ignores single-line and multi-line JavaScript-style comments treating them as whitespace and also trailing commas in arrays ans objects.
* Offers both condensed and prettified [JSON] output.
* Works with the `Any` type suitable for safe handling of [JSON]/[YAML] data.
* Supports statically typed data as well.

Uses [jany]. See also the [yaml] package and the [yaml2json] tool.

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

You will usually need the `Any` type as well, either from [VPM] or from GitHub:

```txt
v install prantlf.jany
v install --git https://github.com/prantlf/v-jany
```

## API

The following functions are exported:

### parse(input string, opts ParseOpts) !Any

Parses an `Any` value from a string in the JSON format. See [jany] for more information about the `Any` type. Fields available in `ParseOpts`:

| Name                     | Type   | Default | Description |
|:-------------------------|:-------|:--------|:------------|
| `ignore_comments`        | `bool` | `false` | ignores single-line and multi-line JavaScript-style comments treating them as whitespace |
| `ignore_trailing_commas` | `bool` | `false` | ignores commas behind the last item in an array or in an object             |

```go
any := parse(input, ParseOpts{})
```

### stringify(any Any, opts StringifyOpts) !string

Formats an `Any` value to a string according to the JSON specification. See [jany] for more information about the `Any` type. Fields available in `StringifyOpts`:

| Name     | Type   | Default | Description                                                           |
|:---------|:-------|:--------|:----------------------------------------------------------------------|
| `pretty` | `bool` | `false` | enables readable formatting using line breaks, spaces and indentation |

```go
str := stringify(any, StringifyOpts{ pretty: true })
```

### marshal[T](value T, opts MarshalOpts) !string

Marshals a value of `T` to a `string` value. Fields available in `MarshalOpts`:

| Name             | Type   | Default | Description                                                           |
|:-----------------|:-------|:--------|:----------------------------------------------------------------------|
| `enums_as_names` | `bool` | `false` | stores `string` names of enum values instead of their `int` values    |
| `pretty`         | `bool` | `false` | enables readable formatting using line breaks, spaces and indentation |

```go
struct Config {
	answer int
}

config := Config{ answer: 42 }
str := marshal(config, MarshalOpts{})
```

### unmarshal_text[T](input string, opts UnmarshalOpts) !T

Unmarshals an `Any` value to an instance of `T`. Fields available in `UnmarshalOpts`:

| Name                     | Type   | Default | Description                                                             |
|:-------------------------|:-------|:--------|:------------------------------------------------------------------------|
| `ignore_comments`        | `bool` | `false` | ignores single-line and multi-line JavaScript-style comments treating them as whitespace |
| `ignore_trailing_commas` | `bool` | `false` | ignores commas behind the last item in an array or in an object             |
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

config := unmarshal[Config](json, UnmarshalOpts{})
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

This module is almost 3.8x faster than `x.json2` when parsing:

    ❯ ./parse_bench.vsh

    SPENT  1082.011 ms in parsing condensed with x.json2
    SPENT   283.197 ms in parsing condensed with prantlf.json
    SPENT  1047.946 ms in parsing pretty with x.json2
    SPENT   284.696 ms in parsing pretty with prantlf.json

and almost 3.5x faster when stringifying:

    ❯ ./stringfy_bench.vsh

    SPENT  1271.921 ms in stringifying condensed with x.json2
    SPENT   380.261 ms in stringifying condensed with prantlf.json
    SPENT  1386.552 ms in stringifying pretty with x.json2
    SPENT   398.728 ms in stringifying pretty with prantlf.json

## TODO

This is a work in progress.

* Support `replacer` for `stringify` and `marshal` and `reviver` for `parse` and `unmarshal`.
* Help fixing a bug in V - generics doesn't support nested structs.

[VPM]: https://vpm.vlang.io/packages/prantlf.jany
[jany]: https://github.com/prantlf/v-jany
[yaml]: https://github.com/prantlf/v-yaml
[yaml2json]: https://github.com/prantlf/v-yaml2json
[JSON]: https://www.json.org/
[JSONC]: https://changelog.com/news/jsonc-is-a-superset-of-json-which-supports-comments-6LwR
[YAML]: https://yaml.org/
