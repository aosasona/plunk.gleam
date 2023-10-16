import gleam/http
import gleam/http/request.{Request}
import gleam/string

const plunk_url = "https://api.useplunk.com/v1"

pub fn make_request(
  endpoint path: String,
  method method: http.Method,
  body body: String,
) -> Request(String) {
  request.new()
  |> request.set_method(method)
  |> request.set_host(plunk_url)
  |> request.set_path(normalize_path(path))
  |> fn(request) -> Request(String) {
    // we only want to set the body if it's not a GET request
    case method {
      http.Get -> request
      _ -> request.set_body(request, body)
    }
  }
  |> request.set_header("content-type", "application/json")
  |> request.set_header("accept", "application/json")
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
