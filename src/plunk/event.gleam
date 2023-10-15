import gleam/json.{Json}
import gleam/http.{Post}
import gleam/http/request.{Request}

pub type Event {
  Event(event: String, email: String, data: List(#(String, Json)))
}

pub fn track(
  event: String,
  email: String,
  data: List(#(String, Json)),
) -> Request(String) {
  let body =
    json.object([
      #("event", json.string(event)),
      #("email", json.string(email)),
      #("data", json.object(data)),
    ])
    |> json.to_string

  request.new()
  |> request.set_method(Post)
}
