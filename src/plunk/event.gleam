import gleam/json.{Json}
import gleam/option.{Option}

pub type Event {
  Event(event: String, email: String, data: List(#(String, Json)))
}

pub fn track() {
  todo
}
