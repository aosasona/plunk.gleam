import gleam/dynamic/decode.{type Decoder}
import gleam/http
import gleam/http/request.{type Request, Request}
import gleam/http/response.{type Response, Response}
import gleam/json
import gleam/string
import plunk/instance.{type Instance}
import plunk/types.{type PlunkError, ApiError, JSONError}

const plunk_url = "api.useplunk.com"

pub fn make_request(
  instance: Instance,
  endpoint path: String,
  method method: http.Method,
  body body: String,
) -> Request(String) {
  request.new()
  |> request.set_method(method)
  |> request.set_host(plunk_url)
  |> request.set_path("/v1" <> normalize_path(path))
  |> fn(request) -> Request(String) {
    // we only want to set the body if it's not a GET request
    case method {
      http.Get -> request
      _ -> request.set_body(request, body)
    }
  }
  |> set_header("Content-Type", "application/json")
  |> set_header("Accept", "application/json")
  |> set_header("Authorization", "Bearer " <> instance.api_key)
}

// The default `request.set_header` method makes every key lowercase by default but we best assume that Plunk's servers are case sensitive (especially with `Authorization`)
fn set_header(
  req: Request(String),
  key: String,
  value: String,
) -> Request(String) {
  Request(..req, headers: [#(key, value), ..req.headers])
}

pub fn normalize_path(path: String) -> String {
  let path = case string.starts_with(path, "/") {
    True -> path
    False -> "/" <> path
  }

  case string.ends_with(path, "/") {
    True ->
      path
      |> string.trim
      |> string.drop_end(1)
    False -> path
  }
}

pub fn error_decoder() -> Decoder(PlunkError) {
  use code <- decode.field("code", decode.int)
  use error <- decode.field("error", decode.string)
  use message <- decode.field("message", decode.string)
  use time <- decode.field("time", decode.int)
  decode.success(ApiError(
    code: code,
    error: error,
    message: message,
    time: time,
  ))
}

/// Convert the Gleam `Response` type returned by the HTTP client into the appropriate type for that action/resource
pub fn decode(
  res: Response(String),
  decoder: fn() -> Decoder(a),
) -> Result(a, PlunkError) {
  let Response(status: status, body: body, ..) = res
  case status {
    status if status >= 200 && status < 300 -> {
      case json.parse(from: body, using: decoder()) {
        Ok(decoded) -> Ok(decoded)
        Error(err) -> Error(JSONError(err))
      }
    }
    _ -> {
      case json.parse(from: body, using: error_decoder()) {
        Ok(decoded) -> Error(decoded)
        Error(err) -> Error(JSONError(err))
      }
    }
  }
}
