import gleeunit/should
import gleam/list
import gleam/int
import gleam/option.{Some}
import gleam/io
import gleam/erlang/os
import gleam/result
import ids/ulid
import gleam/hackney
import plunk
import plunk/contacts

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

  let raw_data = contacts.decode(resp, for: contacts.GetContact)
  should.be_ok(raw_data)
  let assert Ok(data) = raw_data

  case data {
    contacts.GetContactResult(contact) -> {
      io.debug("ID -> " <> contact.id)
      Nil
    }
    _ -> should.fail()
  }
}

pub fn list_test() {
  let key =
    os.get_env("PLUNK_API_KEY")
    |> result.unwrap("")

  should.not_equal(key, "")

  let raw_resp =
    plunk.new(key)
    |> contacts.list()
    |> hackney.send

  should.be_ok(raw_resp)
  let assert Ok(resp) = raw_resp

  let raw_data = contacts.decode(resp, for: contacts.ListContacts)
  should.be_ok(raw_data)
  let assert Ok(data) = raw_data

  case data {
    contacts.ListContactsResult(contacts) -> {
      io.debug("-----------------")
      io.debug("List all contacts")
      let print = fn(contact: contacts.Contact) { io.debug(contact.id) }
      contacts
      |> list.map(print)
      io.debug("-----------------")
      Nil
    }
    _ -> should.fail()
  }
}

pub fn count_test() {
  let key =
    os.get_env("PLUNK_API_KEY")
    |> result.unwrap("")

  should.not_equal(key, "")

  let raw_resp =
    plunk.new(key)
    |> contacts.count()
    |> hackney.send

  should.be_ok(raw_resp)
  let assert Ok(resp) = raw_resp

  let raw_data = contacts.decode(resp, for: contacts.CountContacts)
  should.be_ok(raw_data)
  let assert Ok(data) = raw_data

  case data {
    contacts.CountContactsResult(c) -> {
      io.debug(
        "Got " <> int.to_string(c.count) <> " contact" <> case c {
          c if c.count > 1 -> "s"
          _ -> ""
        },
      )
      Nil
    }
    _ -> should.fail()
  }
}

pub fn create_test() {
  let key =
    os.get_env("PLUNK_API_KEY")
    |> result.unwrap("")

  should.not_equal(key, "")

  let raw_resp =
    plunk.new(key)
    |> contacts.create(contacts.CreateContactData(
      email: ulid.generate() <> "@example.com",
      subscribed: True,
      data: Some([#("name", "John")]),
    ))
    |> hackney.send

  should.be_ok(raw_resp)
  let assert Ok(resp) = raw_resp

  let raw_data = contacts.decode(resp, for: contacts.CreateContact)
  should.be_ok(raw_data)
  let assert Ok(data) = raw_data

  case data {
    contacts.CreateContactResult(contact) -> {
      io.debug(contact)
      Nil
    }
    _ -> should.fail()
  }
}
