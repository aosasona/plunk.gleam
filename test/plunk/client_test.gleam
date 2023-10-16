import gleeunit/should
import gleam/http/request.{Request}
import gleam/http/response.{Response}
import plunk/client.{Client, set_api_key, set_executor}

fn fake_client(_: Request(_)) -> Response(_) {
  Response(body: "OK", headers: [#("ping", "pong")], status: 200)
}

pub fn set_api_key_test() {
  Client(api_key: "foo", executor: fake_client)
  |> set_api_key("foobar")
  |> should.equal(Client(api_key: "foobar", executor: fake_client))
}

pub fn set_executor_test() {
  let replaced_client = fn(_: Request(_)) -> Response(_) {
    Response(body: "NOT OK", headers: [], status: 500)
  }

  Client(api_key: "foo", executor: fake_client)
  |> set_executor(replaced_client)
  |> should.equal(Client(api_key: "foo", executor: replaced_client))
}
