import gleam/http/request.{Request}
import gleam/http/response.{Response}

pub type SendFn =
  fn(Request(String)) -> Response(String)

pub type Instance {
  Instance(api_key: String, executor: SendFn)
}

pub fn set_api_key(client: Instance, api_key: String) -> Instance {
  Instance(..client, api_key: api_key)
}

pub fn set_executor(client: Instance, executor: SendFn) -> Instance {
  Instance(..client, executor: executor)
}

pub fn send(client: Instance, request: Request(String)) -> Response(String) {
  client.executor(request)
}
