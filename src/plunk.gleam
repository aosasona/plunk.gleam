import plunk/instance.{Instance, SendFn}

pub fn new(key api_key: String, sender executor: SendFn) -> Instance {
  Instance(api_key: api_key, executor: executor)
}
