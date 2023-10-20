import gleeunit/should
import gleam/io
import gleam/erlang/os
import gleam/result
import gleam/hackney
import plunk
import plunk/contacts.{GetContact, GetContactResult}

pub fn get_test() {
  let key =
    os.get_env("PLUNK_API_KEY")
    |> result.unwrap("")

  should.not_equal(key, "")

  let raw_resp =
    plunk.new(key)
    |> contacts.get("6e4f09c3-2c0f-478c-bea4-f221135edde5")
    |> hackney.send

  should.be_ok(raw_resp)
  let assert Ok(resp) = raw_resp

  let raw_data = contacts.decode(resp, for: GetContact)
  should.be_ok(raw_data)
  let assert Ok(data) = raw_data

  case data {
    GetContactResult(contact) -> {
      io.debug("ID -> " <> contact.id)
      Nil
    }
    _ -> should.fail()
  }
}
