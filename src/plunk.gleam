import gleam/dynamic.{Decoder}
import gleam/http/response.{Response}
import plunk/instance.{Instance}
import plunk/internal/bridge
import plunk/types.{PlunkError}

pub fn new(key api_key: String) -> Instance {
  Instance(api_key: api_key)
}

pub fn decode(
  res: Response(String),
  decoder: fn() -> Decoder(a),
) -> Result(a, PlunkError) {
  bridge.decode(res, decoder)
}
