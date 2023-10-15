import plunk/client.{Client, SendFn}

pub fn new(key api_key: String, executor executor: SendFn(a, b)) -> Client(a, b) {
  Client(api_key: api_key, executor: executor)
}
