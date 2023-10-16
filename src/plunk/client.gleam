import gleam/http/request.{Request}
import gleam/http/response.{Response}

pub type SendFn =
  fn(Request(String)) -> Response(String)

pub type Client {
  Client(api_key: String, executor: SendFn)
}

pub fn set_api_key(client: Client, api_key: String) -> Client {
  Client(..client, api_key: api_key)
}

pub fn set_executor(client: Client, executor: SendFn) -> Client {
  Client(..client, executor: executor)
}

pub fn send(client: Client, request: Request(String)) -> Response(String) {
  client.executor(request)
}
