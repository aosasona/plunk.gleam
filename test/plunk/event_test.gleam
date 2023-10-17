import gleeunit/should
import gleam/erlang/os
import gleam/io
import gleam/json
import gleam/list
import gleam/result
import gleam/http.{Post}
import gleam/hackney
import plunk
import plunk/instance.{Instance}
import plunk/event

pub fn track_test() {
  let key =
    os.get_env("PLUNK_API_KEY")
    |> result.unwrap("")

  let req =
    Instance(api_key: key)
    |> event.track(
      event: "your-event",
      email: "someone@example.com",
      data: [#("name", json.string("John"))],
    )

  should.equal(req.method, Post)
  should.equal(req.host, "api.useplunk.com")
  should.equal(req.path, "/v1/track")
  should.equal(
    req.body,
    json.to_string(json.object([
      #("event", json.string("your-event")),
      #("email", json.string("someone@example.com")),
      #("data", json.object([#("name", json.string("John"))])),
    ])),
  )

  req.headers
  |> list.key_find("Content-Type")
  |> should.equal(Ok("application/json"))

  req.headers
  |> list.key_find("Accept")
  |> should.equal(Ok("application/json"))

  req.headers
  |> list.key_find("Authorization")
  |> should.equal(Ok("Bearer " <> key))

  case hackney.send(req) {
    Ok(resp) -> {
      let d = plunk.decode(resp, event.track_event_response_decoder)
      should.be_ok(d)

      let assert Ok(data) = d
      should.equal(data.success, True)
      Nil
    }
    Error(e) -> {
      io.debug(e)
      should.fail()
    }
  }
}
