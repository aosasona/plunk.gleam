import gleam/dynamic/decode
import gleam/http.{Post}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/json.{type Json}
import gleam/option.{type Option}
import plunk/instance.{type Instance}
import plunk/internal/bridge.{make_request}
import plunk/types.{type PlunkError}

/// Event is a type that represents a Plunk event.
pub type Event {
  Event(event: String, email: String, data: List(#(String, Json)))
}

/// EventResponse is a type that represents a Plunk event response (track event)
pub type TrackEventResponse {
  TrackEventResponse(
    success: Bool,
    contact: String,
    event: String,
    timestamp: Option(String),
  )
}

fn track_event_response_decoder() -> decode.Decoder(TrackEventResponse) {
  use success <- decode.field("success", decode.bool)
  use contact <- decode.field("contact", decode.string)
  use event <- decode.field("event", decode.string)
  use timestamp <- decode.optional_field(
    "timestamp",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(TrackEventResponse(
    success: success,
    contact: contact,
    event: event,
    timestamp: timestamp,
  ))
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
/// fn main() {
///   let instance = plunk.new(key: "YOUR_API_KEY") /
///   let req =
///     instance
///     |> event.track(Event(
///       event: "your-event",
///       email: "someone@example.com",
///        data: [#("name", json.string("John"))],
///      ))
///
///   // In a real project, you want to pattern match on the result of `track` to handle errors instead of using `assert Ok(..)`.
///   let assert Ok(resp) = hackney.send(req)
///   let assert Ok(data) = event.decode(resp)
///   // do whatever you want with the data
/// }
/// ```
///
pub fn track(instance: Instance, event event: Event) -> Request(String) {
  let body =
    json.object([
      #("event", json.string(event.event)),
      #("email", json.string(event.email)),
      #("data", json.object(event.data)),
    ])
    |> json.to_string

  instance
  |> make_request(method: Post, endpoint: "/track", body: body)
}

/// Decode the raw response into a `TrackEventResponse` type wrapped in a `Result` type that can be pattern matched on.
pub fn decode(res: Response(String)) -> Result(TrackEventResponse, PlunkError) {
  res
  |> bridge.decode(track_event_response_decoder)
}
