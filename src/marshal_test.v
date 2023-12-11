module json

fn test_marshal_int() {
	r := marshal(1, MarshalOpts{})!
	assert r == '1'
}

fn test_marshal_u8() {
	r := marshal(u8(1), MarshalOpts{})!
	assert r == '1'
}

fn test_marshal_u16() {
	r := marshal(u16(1), MarshalOpts{})!
	assert r == '1'
}

fn test_marshal_u32() {
	r := marshal(u32(1), MarshalOpts{})!
	assert r == '1'
}

fn test_marshal_u64() {
	r := marshal(u64(1), MarshalOpts{})!
	assert r == '1'
}

fn test_marshal_i8() {
	r := marshal(u8(1), MarshalOpts{})!
	assert r == '1'
}

fn test_marshal_i16() {
	r := marshal(u16(1), MarshalOpts{})!
	assert r == '1'
}

fn test_marshal_i64() {
	r := marshal(u64(1), MarshalOpts{})!
	assert r == '1'
}

fn test_marshal_f32() {
	r := marshal(f32(1.2), MarshalOpts{})!
	assert r[0..3] == '1.2'
}

fn test_marshal_f64() {
	r := marshal(1.2, MarshalOpts{})!
	assert r == '1.2'
}

fn test_marshal_bool() {
	r := marshal(true, MarshalOpts{})!
	assert r == 'true'
}

fn test_marshal_string() {
	r := marshal('a', MarshalOpts{})!

	assert r == '"a"'
}

// fn test_marshal_array() {
// 	r := marshal([1], MarshalOpts{})!
// 	assert r == '[1]'
// }

enum Human {
	man
	woman
}

fn test_marshal_enum_num() {
	r := marshal(Human.woman, MarshalOpts{})!
	assert r == '1'
}

fn test_marshal_enum_nam() {
	r := marshal(Human.woman, MarshalOpts{ enums_as_names: true })!
	assert r == '"woman"'
}

struct Empty {}

fn test_marshal_empty_object() {
	r := marshal(Empty{}, MarshalOpts{})!
	assert r == '{}'
}

struct PrimitiveTypes {
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

fn test_marshal_primitive_types() {
	r := marshal(PrimitiveTypes{
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
	}, MarshalOpts{})!
	assert r == '{"h":1,"u8":1,"u16":2,"u32":3,"u64":4,"i8":5,"i16":6,"int":7,"i64":8,"f32":9.100000381469727,"f64":9.2,"string":"s","bool":true}'
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

// fn test_marshal_optional_types() {
// 	input := Any({
// 		'h': Any(f64(Human.woman))
// 		'u8':  Any(f64(1))
// 		'u16': Any(f64(2))
// 		'u32': Any(f64(3))
// 		'u64': Any(f64(4))
// 		'i8':  Any(f64(5))
// 		'i16': Any(f64(6))
// 		'int': Any(f64(7))
// 		'i64': Any(f64(8))
// 		'f32': Any(9.1)
// 		'f64': Any(9.2)
// 		'string': Any('s')
// 		'bool': Any(true)
// 	})
// 	r := marshal[OptionalTypes](input)!
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

/*
struct OptionalType {
	int ?int
}

fn test_marshal_optional_null_type() {
	r := marshal(OptionalType{
		int: none
	})!
	m := r.object()!
	assert m['int']! == Any(null)
}

fn test_marshal_optional_type() {
	r := marshal(OptionalType{
		int: 1
	})!
	m := r.object()!
	assert m['int']! == Any(f64(1))
}
*/

// /*
// struct OptionalArray {
// 	int ?[]int
// }

// fn test_marshal_optional_array() {
// 	input := r'
// int:
// 	- 1
// '
// 	r := marshal[OptionalArray](input)!
// 	assert r.int?.len == 1
// 	assert r.int?[0] == 1
// }
// */

// /*
// struct ArrayOfOptions {
// 	int []?int
// }

// fn test_marshal_array_of_options() {
// 	input := r'
// int:
// 	- 1
// '
// 	r := marshal[ArrayOfOptions](input)!
// 	assert r.int.len == 1
// 	first := r.int[0]
// 	assert first? == 1
// }
// */

// /*
// struct ArrayInStruct {
// 	arr []int
// }

// fn test_marshal_array_in_struct() {
// 	jany.marshal[ArrayInStruct]('', jany.marshalOpts{}) or {
// 		assert err.msg() == 'null is not an object'
// 		return
// 	}
// 	assert false
// }
// */

struct InnerStruct {
	val int
}

struct OuterStruct {
	inner InnerStruct
}

fn test_marshal_struct_in_struct() {
	input := OuterStruct{
		inner: InnerStruct{
			val: 1
		}
	}
	r := marshal(input, MarshalOpts{})!
	assert r == '{"inner":{"val":1}}'
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
	r := marshal(input, MarshalOpts{})!
	assert r == '{"int":1,"string":"","float":2.3,"u8":4,"u16":0}'
}
