import gleam/json
import gleam/option.{None, Option, Some}

pub fn omit_if_none(
  fields: List(#(String, json.Json)),
  key: String,
  optional_value: Option(t),
  target: fn(t) -> json.Json,
) -> List(#(String, json.Json)) {
  case optional_value {
    Some(value) -> [#(key, target(value)), ..fields]
    None -> fields
  }
}
