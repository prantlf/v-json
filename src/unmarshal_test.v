module json

fn test_unmarshal_null_to_scalar() {
	unmarshal[int]('null') or {
		assert err.msg() == 'null cannot be cast to int'
		return
	}
	assert false
}

fn test_unmarshal_int() {
	r := unmarshal[int]('1')!
	assert r == 1
}

fn test_unmarshal_u8() {
	r := unmarshal[u8]('1')!
	assert r == 1
}

fn test_unmarshal_u16() {
	r := unmarshal[u16]('1')!
	assert r == 1
}

fn test_unmarshal_u32() {
	r := unmarshal[u32]('1')!
	assert r == 1
}

fn test_unmarshal_u64() {
	r := unmarshal[u64]('1')!
	assert r == 1
}

fn test_unmarshal_i8() {
	r := unmarshal[u8]('1')!
	assert r == 1
}

fn test_unmarshal_i16() {
	r := unmarshal[u16]('1')!
	assert r == 1
}

fn test_unmarshal_i64() {
	r := unmarshal[u64]('1')!
	assert r == 1
}

fn test_unmarshal_f32() {
	r := unmarshal[f32]('1.2')!
	assert r == 1.2
}

fn test_unmarshal_f64() {
	r := unmarshal[f64]('1.2')!
	assert r == 1.2
}

fn test_unmarshal_bool() {
	r := unmarshal[bool]('true')!
	assert r == true
}

fn test_unmarshal_string() {
	r := unmarshal[string]('"a"')!
	assert r == 'a'
}

fn test_unmarshal_array() {
	r := unmarshal[[]int]('[1]')!
	assert r.len == 1
	assert r[0] == 1
}

enum Human {
	man
	woman
}

fn test_unmarshal_enum_num() {
	r := unmarshal[Human]('1')!
	assert r == .woman
}

fn test_unmarshal_enum_nam() {
	r := unmarshal[Human]('"woman"')!
	assert r == .woman
}

struct Empty {}

fn test_unmarshal_empty_input() {
	unmarshal[Empty]('null') or {
		assert err.msg() == 'null cannot be cast to json.Empty'
		return
	}
	assert false
}

fn test_unmarshal_empty_object() {
	unmarshal[Empty]('{}')!
}

struct PrimitiveTypes {
	h Human
}

fn test_unmarshal_primitive_types() {
	input := '{"h":1,"u8":1,"u16":2,"u32":3,"u64":4,"i8":5,"i16":6,"int":7,"i64":8,"f32":9.1,"f64":9.2,"string":"s","bool":true}'
	r := unmarshal[PrimitiveTypes](input)!
	assert r.h == .woman
}

// struct OptionalTypes {
// 	h      ?Human
// 	u8     ?u8
// 	u16    ?u16
// 	u32    ?u32
// 	u64    ?u64
// 	i8     ?i8
// 	i16    ?i16
// 	int    ?int
// 	i64    ?i64
// 	f32    ?f32
// 	f64    ?f64
// 	string ?string
// 	bool   ?bool
// }

// fn test_unmarshal_optional_types() {
// 	input := Any({
// 		'h':      Any(f64(Human.woman))
// 		'u8':     Any(f64(1))
// 		'u16':    Any(f64(2))
// 		'u32':    Any(f64(3))
// 		'u64':    Any(f64(4))
// 		'i8':     Any(f64(5))
// 		'i16':    Any(f64(6))
// 		'int':    Any(f64(7))
// 		'i64':    Any(f64(8))
// 		'f32':    Any(9.1)
// 		'f64':    Any(9.2)
// 		'string': Any('s')
// 		'bool':   Any(true)
// 	})
// 	r := unmarshal[OptionalTypes](input)!
// 	assert r.h? == .woman
// 	assert r.u8? == 1
// 	assert r.u16? == 2
// 	assert r.u32? == 3
// 	assert r.u64? == 4
// 	assert r.i8? == 5
// 	assert r.i16? == 6
// 	assert r.int? == 7
// 	assert r.i64? == 8
// 	assert r.f32? == 9.1
// 	assert r.f64? == 9.2
// 	assert r.string? == 's'
// 	assert r.bool? == true
// }

// struct PrimitiveNullType {
// 	int int
// }

// fn test_unmarshal_primitive_null_type() {
// 	input := Any({
// 		'int': Any(null)
// 	})
// 	r := unmarshal[PrimitiveNullType](input) or {
// 		assert err.msg() == 'null cannot be set to int of int'
// 		return
// 	}
// 	assert false
// }

// struct OptionalNullType {
// 	int ?int
// }

// fn test_unmarshal_optional_null_type() {
// 	input := Any({
// 		'int': Any(null)
// 	})
// 	r := unmarshal[OptionalNullType](input)!
// 	r.int or { return }

// 	assert false
// }

// struct OptionalArray {
// 	int ?[]int
// }

// fn test_unmarshal_optional_array() {
// 	input := Any({
// 		'int': Any([Any(f64(1))])
// 	})
// 	r := unmarshal[OptionalArray](input)!
// 	assert r.int?.len == 1
// 	assert r.int?[0] == 1
// }

// /*
// struct ArrayOfOptions {
// mut:	int []?int
// }

// fn test_unmarshal_array_of_options() {
// 	input := Any({
// 		'int': Any([Any(f64(1))])
// 	})
// 	mut r := unmarshal[ArrayOfOptions](input)!
// 						println('*** 2.11')
// 	assert r.int.len == 1
// 	first := r.int[0]
// 	assert first? == 1
// }
// */

// struct ArrayInStruct {
// 	arr []int
// }

// fn test_unmarshal_array_in_struct() {
// 	input := Any({
// 		'arr': Any([Any(f64(1))])
// 	})
// 	r := unmarshal[ArrayInStruct](input)!
// 	assert r.arr.len == 1
// 	assert r.arr[0] == 1
// }

struct InnerStruct {
	val int
}

struct OuterStruct {
	inner InnerStruct
}

fn test_unmarshal_struct_in_struct() {
	r := unmarshal[OuterStruct]('{"inner":{"val":1}}')!
	assert r.inner.val == 1
}

// struct OptionsStruct {
// 	inner ?InnerStruct
// }

// fn test_unmarshal_option_struct() {
// 	input := Any({
// 		'inner': Any({
// 			'val': Any(f64(1))
// 		})
// 	})
// 	r := unmarshal[OuterStruct](input)!
// 	assert r.inner.val == 1
// }

struct Attributes {
	int    int    @[required]
	bool   bool   @[skip]
	string string
	f64    f64    @[json: float; required]
	u8     u8     @[nooverflow]
	u16    u16    @[nullable]
}

fn test_attributes() {
	input := '{"int":1,"float":2.3,"bool":true,"u8":1234,"u16":null}'
	opts := UnmarshalOpts{
		require_all_fields: false
		forbid_extra_keys: false
		cast_null_to_default: false
		ignore_number_overflow: false
	}
	r := unmarshal_opt[Attributes](input, opts)!
	assert r.int == 1
	assert r.bool == false
	assert r.string == ''
	assert r.f64 == 2.3
	assert r.u8 == u8(210)
	assert r.u16 == 0
}
