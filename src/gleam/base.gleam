import gleam/bit_string
import gleam/string

/// Encodes a `BitString` into a base 64 encoded `String`.
///
/// ## Examples
///
/// ```gleam
/// > <<0, 0, 0>>
/// > |> encode64(True)
/// "AAAA"
/// ```
///
pub fn encode64(input: BitString, padding: Bool) -> String {
  let encoded = do_encode64(input)
  case padding {
    True -> encoded
    False -> string.replace(encoded, "=", "")
  }
}

if erlang {
  external fn do_encode64(BitString) -> String =
    "base64" "encode"
}

if javascript {
  external fn do_encode64(BitString) -> String =
    "../gleam_stdlib.mjs" "encode64"
}

/// Decodes a base 64 encoded `String` into a `BitString`.
///
/// ## Examples
///
/// ```gleam
/// > "AAAA"
/// > |> decode64()
/// Ok(<<0, 0, 0>>)
/// ```
///
pub fn decode64(encoded: String) -> Result(BitString, Nil) {
  let padded = case bit_string.byte_size(bit_string.from_string(encoded)) % 4 {
    0 -> encoded
    n -> string.append(encoded, string.repeat("=", 4 - n))
  }
  do_decode64(padded)
}

if erlang {
  external fn do_decode64(String) -> Result(BitString, Nil) =
    "gleam_stdlib" "base_decode64"
}

if javascript {
  external fn do_decode64(String) -> Result(BitString, Nil) =
    "../gleam_stdlib.mjs" "decode64"
}

/// Encodes a `BitString` into a base 64 encoded `String` with URL and filename safe alphabet.
///
/// ## Examples
///
/// ```gleam
/// > <<0, 0, 0>>
/// > |> url_encode64(True)
/// "AAAA"
/// ```
///
pub fn url_encode64(input: BitString, padding: Bool) -> String {
  encode64(input, padding)
  |> string.replace("+", "-")
  |> string.replace("/", "_")
}

/// Decodes a base 64 encoded `String` with URL and filename safe alphabet into a `BitString`.
///
/// ## Examples
///
/// ```gleam
/// > "AAAA"
/// > |> url_decode64()
/// Ok(<<0, 0, 0>>)
/// ```
///
pub fn url_decode64(encoded: String) -> Result(BitString, Nil) {
  encoded
  |> string.replace("-", "+")
  |> string.replace("_", "/")
  |> decode64()
}
