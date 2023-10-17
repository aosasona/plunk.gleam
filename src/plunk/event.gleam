import gleam/dynamic
import gleam/json.{Json}
import gleam/http.{Post}
import gleam/http/request.{Request}
import plunk/instance.{Instance}
import plunk/internal/bridge.{make_request}
import plunk/types.{PlunkError}

/// Event is a type that represents a Plunk event.
pub type Event {
  Event(event: String, email: String, data: List(#(String, Json)))
}

/// EventResponse is a type that represents a Plunk event response (track event)
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

/// Track events in your application and send them to Plunk. This function returns a Gleam `Request` type that can then be used with any client of your choice.
///
/// # Example
///
/// In this example we use the `hackney` HTTP client to send the request we get from `track`:
///
/// ```gleam
/// import gleam/json
/// import gleam/hackney
/// import plunk
/// import plunk/event
///
/// let instance = plunk.new(key: "YOUR_API_KEY", sender: hackney.send)
///
/// // In a real project, you want to pattern match on the result of `track` to handle errors instead of using `assert Ok(..)`.
/// let assert Ok(_) =
///   instance
///   |> event.track(event: "your-event", email: "someone@example.com", data: [#("name", json.string("John"))])
///   |> event.send(instance)
/// ```
///
pub fn track(
  instance: Instance,
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

/// Send a request to Plunk to track an event.
pub fn send(
  req: Request(String),
  instance: Instance,
) -> Result(EventResponse, PlunkError) {
  req
  |> bridge.send(instance, event_response_decoder)
}
