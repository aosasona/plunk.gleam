import gleam/json
import gleam/dynamic.{Decoder}
import gleam/http/response.{Response}
import plunk/types.{JSONError, PlunkError}
import plunk/internal/bridge.{error_decoder}
import plunk/instance.{Instance}

pub fn new(key api_key: String) -> Instance {
  Instance(api_key: api_key)
}

pub fn decode(
  res: Response(String),
  decoder: fn() -> Decoder(a),
) -> Result(a, PlunkError) {
  let Response(status: status, body: body, ..) = res
  case status {
    status if status >= 200 && status < 300 -> {
      case json.decode(from: body, using: decoder()) {
        Ok(decoded) -> Ok(decoded)
        Error(err) -> Error(JSONError(err))
      }
    }
    _ -> {
      case json.decode(from: body, using: error_decoder()) {
        Ok(decoded) -> Error(decoded)
        Error(err) -> Error(JSONError(err))
      }
    }
  }
}
