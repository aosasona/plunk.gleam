import dot_env
import dot_env/env
import gleam/hackney
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import gleeunit/should
import plunk
import plunk/transactional.{Address, TransactionalEmail}

pub fn send_test() {
  dot_env.load_default()

  let key =
    env.get_string("PLUNK_API_KEY")
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
      echo data
      Nil
    }
    Error(e) -> {
      echo "Error: " <> e |> string.inspect
      should.fail()
    }
  }
}
