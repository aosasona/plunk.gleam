import plunk
import gleam/http/request.{Request}
import gleam/http/response.{Response}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

fn fake_client(_: Request(_)) -> Response(_) {
  Response(body: "OK", headers: [#("ping", "pong")], status: 200)
}

// gleeunit test functions end in `_test`
pub fn new_test() {
  let p = plunk.new(key: "abc123", sender: fake_client)

  p.api_key
  |> should.equal("abc123")

  p.executor
  |> should.equal(fake_client)
}
