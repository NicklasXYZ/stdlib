//// A module that provides the `BitBuilder` type used for efficiently concatenating
//// bits to create `BitString`s.
////
//// If we append one `BitString` to another the `BitStrings` must be copied to a
//// new location in memory so that they can sit together. This behaviour
//// enables efficient reading of the string, but copying can be expensive,
//// especially if we want to combine many bit strings.
////
//// `BitBuilder` is different in that it can be joined together in constant
//// time using minimal memory, and then can be efficiently converted to a
//// bit string using the `to_bit_string` function.
////
//// On Erlang this type is compatible with Erlang's iolists.

import gleam/string_builder.{StringBuilder}

if javascript {
  import gleam/list
  import gleam/bit_string
}

if erlang {
  pub external type BitBuilder
}

if javascript {
  pub opaque type BitBuilder {
    Bits(BitString)
    Text(StringBuilder)
    Many(List(BitBuilder))
  }
}

/// Create an empty `BitBuilder`. Useful as the start of a pipe chaining many
/// builders together.
///
/// ## Examples
///
///```
/// > new()
/// > |> to_bit_string
/// <<>>
///```
pub fn new() -> BitBuilder {
  do_concat([])
}

/// Prepends a `BitString` to the start of a `BitBuilder`.
///
/// Runs in constant time.
///
/// ## Examples
///
///```gleam
/// > new()
/// > |> prepend(<<0>>)
/// > |> prepend(<<1>>)
/// > |> prepend(<<2>>)
/// > |> to_bit_string
/// <<2, 1, 0>>
///```
///
pub fn prepend(to: BitBuilder, prefix: BitString) -> BitBuilder {
  append_builder(from_bit_string(prefix), to)
}

/// Appends a `BitString` to the end of a `BitBuilder`.
///
/// Runs in constant time.
///
/// ## Examples
///
///```gleam
/// > new()
/// > |> append(<<0>>)
/// > |> append(<<1>>)
/// > |> append(<<2>>)
/// > |> to_bit_string
/// <<0, 1, 2>>
///```
///
pub fn append(to: BitBuilder, suffix: BitString) -> BitBuilder {
  append_builder(to, from_bit_string(suffix))
}

/// Prepends a `BitBuilder` onto the start of another.
///
/// Runs in constant time.
///
/// ## Examples
///
///```gleam
/// > let builder = from_bit_string(<<3, 4>>)
/// > from_bit_string(<<1, 2>>)
/// > |> prepend_builder(builder)
/// > |> to_bit_string
/// <<3, 4, 1, 2>>
///```
///
pub fn prepend_builder(to: BitBuilder, prefix: BitBuilder) -> BitBuilder {
  append_builder(prefix, to)
}

/// Appends a `BitBuilder` onto the end of another.
///
/// Runs in constant time.
///
/// ## Examples
///
///```gleam
/// > let builder = from_bit_string(<<3, 4>>)
/// > from_bit_string(<<1, 2>>)
/// > |> append_builder(builder)
/// > |> to_bit_string
/// <<1, 2, 3, 4>>
///```
///
pub fn append_builder(
  to first: BitBuilder,
  suffix second: BitBuilder,
) -> BitBuilder {
  do_append_builder(first, second)
}

if erlang {
  external fn do_append_builder(
    to: BitBuilder,
    suffix: BitBuilder,
  ) -> BitBuilder =
    "gleam_stdlib" "iodata_append"
}

if javascript {
  fn do_append_builder(first: BitBuilder, second: BitBuilder) -> BitBuilder {
    case second {
      Many(builders) -> Many([first, ..builders])
      _ -> Many([first, second])
    }
  }
}

/// Prepends a `String` onto the start of a `BitBuilder`.
///
/// Runs in constant time when running on Erlang.
/// Runs in linear time with the length of the string otherwise.
///
/// ## Examples
///
///```gleam
/// > from_bit_string(<<1>>)
/// > |> bit_builder.prepend_string("0")
/// > |> to_bit_string
/// <<"0":utf8, 1>>
///
/// > from_string("1")
/// > |> bit_builder.prepend_string("0")
/// > |> to_bit_string
/// <<"0":utf8, "1":utf8>>
///```
///
pub fn prepend_string(to: BitBuilder, prefix: String) -> BitBuilder {
  append_builder(from_string(prefix), to)
}

/// Appends a `String` onto the end of a `BitBuidler`.
///
/// Runs in constant time when running on Erlang.
/// Runs in linear time with the length of the string otherwise.
///
/// ## Examples
///
///```gleam
/// > from_bit_string(<<1>>)
/// > |> bit_builder.append_string("0")
/// > |> to_bit_string
/// <<1, "0":utf8>>
///
/// > from_string("1")
/// > |> bit_builder.append_string("0")
/// > |> to_bit_string
/// <<"1":utf8, "0":utf8>>
///```
///
pub fn append_string(to: BitBuilder, suffix: String) -> BitBuilder {
  append_builder(to, from_string(suffix))
}

/// Joins a list of `BitBuilder`s into a single `BitBuilder`.
///
/// Runs in constant time.
///
/// ## Examples
///
///```gleam
/// > [from_bit_string(<<1>>), from_bit_string(<<3>>)]
/// > |> bit_builder.concat
/// > |> bit_builder.to_bit_string
/// <<1, 2>>
///```
///
pub fn concat(builders: List(BitBuilder)) -> BitBuilder {
  do_concat(builders)
}

if erlang {
  external fn do_concat(List(BitBuilder)) -> BitBuilder =
    "gleam_stdlib" "identity"
}

if javascript {
  fn do_concat(builders: List(BitBuilder)) -> BitBuilder {
    Many(builders)
  }
}

/// Creates a new `BitBuilder` from a `String`.
///
/// Runs in constant time when running on Erlang.
/// Runs in linear time otherwise.
///
/// ## Examples
///
///```gleam
/// > from_string("")
/// > |> to_bit_string
/// <<>>
///
/// > from_string("1")
/// > |> to_bit_string
/// <<"1":utf8>>
///```
///
pub fn from_string(string: String) -> BitBuilder {
  do_from_string(string)
}

if erlang {
  external fn do_from_string(String) -> BitBuilder =
    "gleam_stdlib" "wrap_list"
}

if javascript {
  fn do_from_string(string: String) -> BitBuilder {
    Text(string_builder.from_string(string))
  }
}

/// Creates a new `BitBuilder` from a `StringBuilder`.
///
/// Runs in constant time when running on Erlang.
/// Runs in linear time otherwise.
///
pub fn from_string_builder(builder: StringBuilder) -> BitBuilder {
  do_from_string_builder(builder)
}

if erlang {
  external fn do_from_string_builder(StringBuilder) -> BitBuilder =
    "gleam_stdlib" "identity"
}

if javascript {
  fn do_from_string_builder(builder: StringBuilder) -> BitBuilder {
    Text(builder)
  }
}

/// Creates a new `BitBuilder` from a `BitString`.
///
/// Runs in constant time.
///
/// ## Examples
///
///```gleam
/// > from_bit_string(<<>>)
/// > |> to_bit_string
/// <<>>
///
/// > from_bit_string(<<1>>)
/// > |> to_bit_string
/// <<1>>
///```
///
pub fn from_bit_string(bits: BitString) -> BitBuilder {
  do_from_bit_string(bits)
}

if erlang {
  external fn do_from_bit_string(BitString) -> BitBuilder =
    "gleam_stdlib" "wrap_list"
}

if javascript {
  fn do_from_bit_string(bits: BitString) -> BitBuilder {
    Bits(bits)
  }
}

/// Turns a `BitBuilder` into a `BitString`.
///
/// Runs in linear time.
///
/// When running on Erlang this function is implemented natively by the
/// virtual machine and is highly optimised.
///
/// ## Examples
///
///```gleam
/// > from_bit_string(<<1>>)
/// > |> to_bit_string
/// <<1>>
///
/// > from_string("1")
/// > |> to_bit_string
/// <<"1":utf8>>
///```
///
pub fn to_bit_string(builder: BitBuilder) -> BitString {
  do_to_bit_string(builder)
}

if erlang {
  external fn do_to_bit_string(BitBuilder) -> BitString =
    "erlang" "list_to_bitstring"
}

if javascript {
  fn do_to_bit_string(builder: BitBuilder) -> BitString {
    [[builder]]
    |> to_list([])
    |> list.reverse
    |> bit_string.concat
  }

  fn to_list(
    stack: List(List(BitBuilder)),
    acc: List(BitString),
  ) -> List(BitString) {
    case stack {
      [] -> acc

      [[], ..remaining_stack] -> to_list(remaining_stack, acc)

      [[Bits(bits), ..rest], ..remaining_stack] ->
        to_list([rest, ..remaining_stack], [bits, ..acc])

      [[Text(builder), ..rest], ..remaining_stack] -> {
        let bits = bit_string.from_string(string_builder.to_string(builder))
        to_list([rest, ..remaining_stack], [bits, ..acc])
      }

      [[Many(builders), ..rest], ..remaining_stack] ->
        to_list([builders, rest, ..remaining_stack], acc)
    }
  }
}

/// Returns the size of the `BitBuilders`'s content in bytes.
///
/// Runs in linear time.
///
/// ## Examples
///
///```gleam
/// > new()
/// > |> byte_size
/// 0
///
/// > from_bit_string(<<1, 2, 3>>)
/// > |> byte_size
/// 3
///```
///
pub fn byte_size(builder: BitBuilder) -> Int {
  do_byte_size(builder)
}

if erlang {
  external fn do_byte_size(BitBuilder) -> Int =
    "erlang" "iolist_size"
}

if javascript {
  fn do_byte_size(builder: BitBuilder) -> Int {
    [[builder]]
    |> to_list([])
    |> list.fold(0, fn(acc, builder) { bit_string.byte_size(builder) + acc })
  }
}
