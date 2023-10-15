import gleam/http
import gleam/string
import gleam/http/request.{Request}

const plunk_url = "https://api.useplunk.com/v1"

pub fn make_request(path: String, method method: http.Method) -> Request(String) {
  todo
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
