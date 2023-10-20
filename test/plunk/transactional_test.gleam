import gleeunit/should
import gleam/erlang/os
import gleam/io
import gleam/option.{None}
import gleam/result
import gleam/hackney
import plunk/instance.{Instance}
import plunk/transactional.{Address, TransactionalEmail}

pub fn send_test() {
  let key =
    os.get_env("PLUNK_API_KEY")
    |> result.unwrap("")

  let req =
    Instance(api_key: key)
    |> transactional.send(mail: TransactionalEmail(
      to: Address("someone@example.com"),
      subject: "Hello",
      body: "Hello, World!",
      name: None,
      from: None,
    ))

  case hackney.send(req) {
    Ok(resp) -> {
      let d = transactional.decode(resp)
      should.be_ok(d)

      let assert Ok(data) = d
      should.equal(data.success, True)
      io.debug(data)
      Nil
    }
    Error(e) -> {
      io.debug(e)
      should.fail()
    }
  }
}
