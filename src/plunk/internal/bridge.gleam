import gleam/dynamic
import gleam/http
import gleam/http/request.{Request}
import gleam/string
import plunk/types.{ApiError, PlunkError}
import plunk/instance.{Instance}

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
      |> string.drop_right(1)
    False -> path
  }
}

pub fn error_decoder() -> dynamic.Decoder(PlunkError) {
  dynamic.decode4(
    ApiError,
    dynamic.field("code", of: dynamic.int),
    dynamic.field("error", of: dynamic.string),
    dynamic.field("message", of: dynamic.string),
    dynamic.field("time", of: dynamic.int),
  )
}
