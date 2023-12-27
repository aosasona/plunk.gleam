import gleeunit/should
import gleam/list
import gleam/int
import gleam/bool
import gleam/option.{Some}
import gleam/io
import gleam/erlang/os
import gleam/result
import gleam/hackney
import plunk
import plunk/contacts

fn generate() {
  generate_("", 16)
}

fn generate_(state: String, len: Int) {
  case len {
    0 -> state
    _ -> generate_(state <> int.to_string(int.random(100)), len - 1)
  }
}

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
        "Got "
        <> int.to_string(c.count)
        <> " contact"
        <> case c {
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
      email: generate()
      <> "@example.com",
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
      should.be_true(contact.success)
      Nil
    }
    _ -> should.fail()
  }
}

// Just a helper function to setup a new contact for testing purposes
fn setup_new_contact(
  subscribed subscribed: Bool,
) -> #(String, contacts.CreatedContact) {
  let key =
    os.get_env("PLUNK_API_KEY")
    |> result.unwrap("")

  should.not_equal(key, "")

  let id = generate()

  let raw_resp =
    plunk.new(key)
    |> contacts.create(contacts.CreateContactData(
      email: id
      <> "@example.com",
      subscribed: subscribed,
      data: Some([#("ulid", id)]),
    ))
    |> hackney.send

  should.be_ok(raw_resp)
  let assert Ok(resp) = raw_resp

  let raw_data = contacts.decode(resp, for: contacts.CreateContact)
  should.be_ok(raw_data)
  let assert Ok(contacts.CreateContactResult(data)) = raw_data

  #(key, data)
}

pub fn subscribe_test() {
  let assert #(key, contact) = setup_new_contact(subscribed: False)
  should.be_false(contact.subscribed)

  let raw_resp =
    plunk.new(key)
    |> contacts.subscribe(contact.id)
    |> hackney.send

  should.be_ok(raw_resp)
  let assert Ok(resp) = raw_resp

  let raw_data = contacts.decode(resp, for: contacts.Subscribe)
  should.be_ok(raw_data)
  let assert Ok(data) = raw_data

  case data {
    contacts.SubscriptionResult(sub) -> {
      io.debug(
        "["
        <> contact.email
        <> " - SUBSCRIBED]"
        <> " Initial value: "
        <> bool.to_string(contact.subscribed)
        <> ", final value: "
        <> bool.to_string(sub.subscribed),
      )
      should.be_true(sub.success)
      should.be_true(sub.subscribed)
      Nil
    }
    _ -> should.fail()
  }
}

pub fn unsubscribe_test() {
  let assert #(key, contact) = setup_new_contact(subscribed: True)
  should.be_true(contact.subscribed)

  let raw_resp =
    plunk.new(key)
    |> contacts.unsubscribe(contact.id)
    |> hackney.send

  should.be_ok(raw_resp)
  let assert Ok(resp) = raw_resp

  let raw_data = contacts.decode(resp, for: contacts.Subscribe)
  should.be_ok(raw_data)
  let assert Ok(data) = raw_data

  case data {
    contacts.SubscriptionResult(sub) -> {
      io.debug(
        "["
        <> contact.email
        <> " - UNSUBSCRIBED]"
        <> " Initial value: "
        <> bool.to_string(contact.subscribed)
        <> ", final value: "
        <> bool.to_string(sub.subscribed),
      )
      should.be_false(sub.subscribed)
      should.be_true(sub.success)
      Nil
    }
    _ -> should.fail()
  }
}

pub fn delete_test() {
  let assert #(key, contact) = setup_new_contact(subscribed: True)

  let raw_resp =
    plunk.new(key)
    |> contacts.delete(contact.id)
    |> hackney.send

  should.be_ok(raw_resp)
  let assert Ok(resp) = raw_resp

  let raw_data = contacts.decode(resp, for: contacts.DeleteContact)
  should.be_ok(raw_data)
  let assert Ok(data) = raw_data

  case data {
    contacts.DeleteContactResult(d) -> {
      io.debug("Deleted contact (" <> d.email <> ")")
      should.be_true(d.success)
      Nil
    }
    _ -> should.fail()
  }
}
