import plunk/client.{Client, SendFn}

pub fn new(key api_key: String, sender executor: SendFn) -> Client {
  Client(api_key: api_key, executor: executor)
}
