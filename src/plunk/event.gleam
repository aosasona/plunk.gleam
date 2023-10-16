import gleam/dynamic
import gleam/json.{Json}
import gleam/http.{Post}
import gleam/http/request.{Request}
import plunk/client.{Client}
import plunk/internal/bridge.{make_request}
import plunk/types.{PlunkError}

pub type Event {
  Event(event: String, email: String, data: List(#(String, Json)))
}

pub type EventResponse {
  EventResponse(
    success: Bool,
    contact: String,
    event: String,
    timestamp: String,
  )
}

fn event_response_decoder() -> dynamic.Decoder(EventResponse) {
  dynamic.decode4(
    EventResponse,
    dynamic.field("success", dynamic.bool),
    dynamic.field("contact", dynamic.string),
    dynamic.field("event", dynamic.string),
    dynamic.field("timestamp", dynamic.string),
  )
}

pub fn track(
  instance: Client,
  event event: String,
  email email: String,
  data data: List(#(String, Json)),
) -> Request(String) {
  let body =
    json.object([
      #("event", json.string(event)),
      #("email", json.string(email)),
      #("data", json.object(data)),
    ])
    |> json.to_string

  instance
  |> make_request(method: Post, endpoint: "/track", body: body)
}

pub fn send(
  instance: Client,
  req: Request(String),
) -> Result(EventResponse, PlunkError) {
  req
  |> bridge.send(instance, event_response_decoder)
}
