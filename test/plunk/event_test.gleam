import gleeunit/should
import gleam/json
import gleam/list
import gleam/http.{Post}
import gleam/http/request.{Request}
import gleam/http/response.{Response}
import plunk/instance.{Instance}
import plunk/event

pub fn track_test() {
  let send = fn(_: Request(String)) -> Response(String) {
    Response(body: "OK", headers: [#("ping", "pong")], status: 200)
  }

  let req =
    Instance(api_key: "MY_API_KEY", executor: send)
    |> event.track(
      event: "your-event",
      email: "someone@example.com",
      data: [#("name", json.string("John"))],
    )

  should.equal(req.method, Post)
  should.equal(req.host, "https://api.useplunk.com")
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
  |> should.equal(Ok("Bearer MY_API_KEY"))
}
