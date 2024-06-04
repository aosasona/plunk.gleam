import gleam/erlang/os
import gleam/hackney
import gleam/io
import gleam/option.{None, Some}
import gleam/result
import gleeunit/should
import plunk
import plunk/transactional.{Address, TransactionalEmail}

pub fn send_test() {
  let key =
    os.get_env("PLUNK_API_KEY")
    |> result.unwrap("")

  should.not_equal(key, "")

  let req =
    plunk.new(key)
    |> transactional.send(mail: TransactionalEmail(
      to: Address("someone@mailinator.com"),
      subject: "Hello",
      body: "Hello, World!",
      name: Some("plunk.gleam"),
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
