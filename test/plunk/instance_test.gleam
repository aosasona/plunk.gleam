import gleeunit/should
import gleam/http/request.{Request}
import gleam/http/response.{Response}
import plunk/instance.{Instance, set_api_key, set_executor}

fn fake_instance(_: Request(_)) -> Response(_) {
  Response(body: "OK", headers: [#("ping", "pong")], status: 200)
}

pub fn set_api_key_test() {
  Instance(api_key: "foo", executor: fake_instance)
  |> set_api_key("foobar")
  |> should.equal(Instance(api_key: "foobar", executor: fake_instance))
}

pub fn set_executor_test() {
  let replaced_client = fn(_: Request(_)) -> Response(_) {
    Response(body: "NOT OK", headers: [], status: 500)
  }

  Instance(api_key: "foo", executor: fake_instance)
  |> set_executor(replaced_client)
  |> should.equal(Instance(api_key: "foo", executor: replaced_client))
}
