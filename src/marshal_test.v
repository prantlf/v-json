module json

fn test_marshal_int() {
	r := marshal(1)
	assert r == '1'
}

fn test_marshal_u8() {
	r := marshal(u8(1))
	assert r == '1'
}

fn test_marshal_u16() {
	r := marshal(u16(1))
	assert r == '1'
}

fn test_marshal_u32() {
	r := marshal(u32(1))
	assert r == '1'
}

fn test_marshal_u64() {
	r := marshal(u64(1))
	assert r == '1'
}

fn test_marshal_i8() {
	r := marshal(u8(1))
	assert r == '1'
}

fn test_marshal_i16() {
	r := marshal(i16(1))
	assert r == '1'
}

fn test_marshal_i64() {
	r := marshal(i64(1))
	assert r == '1'
}

fn test_marshal_f32() {
	r := marshal(f32(1.2))
	assert r[0..3] == '1.2'
}

fn test_marshal_f64() {
	r := marshal(1.2)
	assert r == '1.2'
}

fn test_marshal_bool() {
	r := marshal(true)
	assert r == 'true'
}

fn test_marshal_string_0() {
	r := marshal('')
	assert r == '""'
}

fn test_marshal_string_1() {
	r := marshal('a')
	assert r == '"a"'
}

enum Human {
	man
	woman
}

fn test_marshal_enum_num() {
	r := marshal(Human.woman)
	assert r == '1'
}

fn test_marshal_enum_name() {
	r := marshal_opt(Human.woman, MarshalOpts{ enums_as_names: true })
	assert r == '"woman"'
}

fn test_marshal_array_0() {
	r := marshal([]int{})
	assert r == '[]'
}

fn test_marshal_array_1() {
	r := marshal([1])
	assert r == '[1]'
}

fn test_marshal_array_2() {
	r := marshal([1, 2])
	assert r == '[1,2]'
}

fn test_marshal_array_2_pretty() {
	r := marshal_opt([1, 2], MarshalOpts{ pretty: true })
	assert r == '[
  1,
  2
]'
}

// fn test_marshal_array_2x1() {
// 	r := marshal([[1], [2]])
// 	assert r == '[[1],[2]]'
// }

// fn test_marshal_array_2x1_pretty() {
// 	r := marshal_opt([[1], [2]], MarshalOpts{ pretty: true })
// 	assert r == '[
//   [
//     1
//   ],
//   [
//     2
//   ]
// ]'
// }

fn test_marshal_map_0() {
	r := marshal(map[string]int{})
	assert r == '{}'
}

fn test_marshal_map_1() {
	r := marshal({
		'a': 1
	})
	assert r == '{"a":1}'
}

fn test_marshal_map_2() {
	r := marshal({
		'a': 1
		'b': 2
	})
	assert r == '{"a":1,"b":2}'
}

fn test_marshal_map_2_pretty() {
	r := marshal_opt({
		'a': 1
		'b': 2
	}, MarshalOpts{ pretty: true })
	assert r == '{
  "a": 1,
  "b": 2
}'
}

struct Empty {}

fn test_marshal_struct_0() {
	r := marshal(Empty{})
	assert r == '{}'
}

struct One {
	a int
}

fn test_marshal_struct_1() {
	r := marshal(One{ a: 1 })
	assert r == '{"a":1}'
}

struct Two {
	a int
	b string
}

fn test_marshal_struct_2() {
	r := marshal(Two{ a: 1, b: '2' })
	assert r == '{"a":1,"b":"2"}'
}

fn test_marshal_struct_2_pretty() {
	r := marshal(Two{})
	assert r == '{"a":0,"b":""}'
}

struct Nested {
	one One
}

fn test_marshal_struct_nested() {
	r := marshal(Nested{
		one: One{
			a: 1
		}
	})
	assert r == '{"one":{"a":1}}'
}

fn test_marshal_struct_nested_pretty() {
	r := marshal_opt(Nested{}, MarshalOpts{ pretty: true })
	assert r == '{
  "one": {
    "a": 0
  }
}'
}

struct OneArray {
	a []int
}

fn test_marshal_struct_array() {
	r := marshal(OneArray{ a: [1] })
	assert r == '{"a":[1]}'
}

fn test_marshal_struct_array_pretty() {
	r := marshal_opt(OneArray{ a: [1] }, MarshalOpts{
		pretty: true
	})
	assert r == '{
  "a": [
    1
  ]
}'
}

// struct OneArray2 {
// 	b []string
// }

// fn test_marshal_struct_array2() {
// 	r := marshal(OneArray2{ b: ["2"] })
// 	assert r == '{"b":["2"]}'
// }

// fn test_marshal_struct_array2_pretty() {
// 	r := marshal(OneArray2{ b: ["2"] }, MarshalOpts{ pretty: true })
// 	assert r == '{
//   "b": [
//     "2"
//   ]
// }'
// }

// struct TwoArrays {
// 	a []int
// 	b []string
// }

// fn test_marshal_struct_array() {
// 	r := marshal(TwoArrays{ a: [1], b: ['2'] })
// 	assert r == '{"a":[1],"b":["2"]}'
// }

// fn test_marshal_struct_array_pretty() {
// 	r := marshal(TwoArrays{ a: [1], b: ['2'] }, MarshalOpts{ pretty: true })
// 	assert r == '{
//   "a": [
//     1
//   ],
//   "b": [
//     "2"
//   ]
// }'
// }

struct Primitives {
	h      Human
	u8     u8
	u16    u16
	u32    u32
	u64    u64
	i8     i8
	i16    i16
	int    int
	i64    i64
	f32    f32
	f64    f64
	string string
	bool   bool
}

fn test_marshal_struct_primitives_defaults() {
	r := marshal(Primitives{})
	assert r == '{"h":0,"u8":0,"u16":0,"u32":0,"u64":0,"i8":0,"i16":0,"int":0,"i64":0,"f32":0.0,"f64":0.0,"string":"","bool":false}'
}

fn test_marshal_struct_primitives_not_defaults() {
	r := marshal(Primitives{
		h: .woman
		u8: 1
		u16: 2
		u32: 3
		u64: 4
		i8: 5
		i16: 6
		int: 7
		i64: 8
		f32: 9.1
		f64: 9.2
		string: 's'
		bool: true
	})
	assert r == '{"h":1,"u8":1,"u16":2,"u32":3,"u64":4,"i8":5,"i16":6,"int":7,"i64":8,"f32":9.1,"f64":9.2,"string":"s","bool":true}'
}

struct Attributes {
	int    int    @[required]
	bool   bool   @[skip]
	string string
	f64    f64    @[json: float; required]
	u8     u8     @[nooverflow]
	u16    u16    @[nullable]
}

fn test_attributes() {
	input := Attributes{
		int: 1
		f64: 2.3
		bool: true
		u8: 4
		u16: 0
	}
	r := marshal(input)
	assert r == '{"int":1,"string":"","float":2.3,"u8":4,"u16":0}'
}

struct Options {
	a ?int
}

fn test_marshal_option_none() {
	r := marshal(Options{})
	assert r == '{"a":null}'
}

fn test_marshal_option_some() {
	r := marshal(Options{ a: 1 })
	assert r == '{"a":1}'
}
