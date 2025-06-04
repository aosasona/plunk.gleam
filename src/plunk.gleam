import gleam/dynamic/decode.{type Decoder}
import gleam/http/response.{type Response}
import plunk/instance
import plunk/internal/bridge
import plunk/types.{type PlunkError}

pub type Instance =
  instance.Instance

pub fn new(key api_key: String) -> instance.Instance {
  instance.Instance(api_key: api_key)
}

pub fn decode(
  res: Response(String),
  decoder: fn() -> Decoder(a),
) -> Result(a, PlunkError) {
  bridge.decode(res, decoder)
}
