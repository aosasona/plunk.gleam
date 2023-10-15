import gleam/http/request.{Request}
import gleam/http/response.{Response}

pub type SendFn(a, b) =
  fn(Request(a)) -> Response(b)

pub type Client(a, b) {
  Client(api_key: String, executor: SendFn(a, b))
}

pub fn set_api_key(client: Client(a, b), api_key: String) -> Client(a, b) {
  Client(..client, api_key: api_key)
}

pub fn set_executor(
  client: Client(a, b),
  executor: SendFn(a, b),
) -> Client(a, b) {
  Client(..client, executor: executor)
}

pub fn send(client: Client(a, b), request: Request(a)) -> Response(b) {
  client.executor(request)
}
