import gleam/dynamic
import gleam/http.{Delete, Get, Post}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result.{try}
import plunk/instance.{type Instance}
import plunk/internal/bridge.{make_request}
import plunk/internal/contacts_def as definitions
import plunk/types.{type PlunkError}

// Re-exported types (for convenience e.g pattern matching or destructuring)
pub type Event =
  definitions.Event

pub type Action =
  definitions.Action

pub type Trigger =
  definitions.Trigger

pub type Email =
  definitions.Email

pub type Contact =
  definitions.Contact

pub type ExtendedContact =
  definitions.ExtendedContact

pub type Count =
  definitions.Count

pub type CreatedContact =
  definitions.CreatedContact

pub type Subscription =
  definitions.Subscription

pub type DeletedContact =
  definitions.DeletedContact

// Decoder types
pub type ActionResult {
  GetContactResult(ExtendedContact)
  ListContactsResult(List(Contact))
  CountContactsResult(Count)
  CreateContactResult(CreatedContact)
  SubscriptionResult(Subscription)
  DeleteContactResult(DeletedContact)
}

pub type For {
  GetContact
  ListContacts
  CountContacts
  CreateContact
  Subscribe
  Unsubscribe
  DeleteContact
}

pub type CreateContactData {
  CreateContactData(
    email: String,
    subscribed: Bool,
    data: Option(List(#(String, String))),
  )
}

pub type SubscriptionData {
  Subscription(id: String)
}

/// Get a contact by ID
pub fn get(instance: Instance, id contact_id: String) -> Request(String) {
  make_request(
    instance,
    method: Get,
    endpoint: "/contacts/" <> contact_id,
    body: "",
  )
}

/// Get all contacts
pub fn list(instance: Instance) -> Request(String) {
  make_request(instance, method: Get, endpoint: "/contacts", body: "")
}

/// Get count of all contacts
pub fn count(instance: Instance) -> Request(String) {
  make_request(instance, method: Get, endpoint: "/contacts/count", body: "")
}

/// Create a contact
pub fn create(instance: Instance, contact: CreateContactData) -> Request(String) {
  let body =
    [
      #("email", json.string(contact.email)),
      #("subscribed", json.bool(contact.subscribed)),
    ]
    |> fn(fields) {
      case contact.data {
        Some(d) -> [
          #(
            "data",
            d
              |> list.map(fn(data) { #(data.0, json.string(data.1)) })
              |> json.object,
          ),
          ..fields
        ]
        None -> fields
      }
    }
    |> json.object
    |> json.to_string

  make_request(instance, method: Post, endpoint: "/contacts", body: body)
}

/// Subscribe a contact
pub fn subscribe(instance: Instance, id: String) -> Request(String) {
  make_request(
    instance,
    method: Post,
    endpoint: "/contacts/subscribe",
    body: json.object([#("id", json.string(id))])
      |> json.to_string,
  )
}

/// Unsubscribe a contact
pub fn unsubscribe(instance: Instance, id: String) -> Request(String) {
  make_request(
    instance,
    method: Post,
    endpoint: "/contacts/unsubscribe",
    body: json.object([#("id", json.string(id))])
      |> json.to_string,
  )
}

/// Delete a contact
pub fn delete(instance: Instance, id: String) -> Request(String) {
  make_request(
    instance,
    method: Delete,
    endpoint: "/contacts",
    body: json.object([#("id", json.string(id))])
      |> json.to_string,
  )
}

///
/// This function decodes all the responses related to this resource albeit a bit differently from the other `decode` functions (but, still type-safe)
///
/// # Example
///
/// ```gleam
/// import gleam/io
/// import gleam/hackney
/// import plunk
/// import plunk/contacts.{GetContact, GetContactResult}
///
/// fn main() {
///   let instance = plunk.new("API_KEY")
///   let req = contacts.get(instance, "some-uuid-for-your-contact")
///   let assert Ok(resp) = hackney.send(req)
///   let assert Ok(data) = contacts.decode(resp, for: GetContact)
///   let assert GetContactResult(contact) = data
///   io.println(contact.id)
/// }
/// ```
///
pub fn decode(
  res: Response(String),
  for for: For,
) -> Result(ActionResult, PlunkError) {
  case for {
    GetContact ->
      try_decode(res, GetContactResult, definitions.get_contact_decoder)
    ListContacts ->
      try_decode(res, ListContactsResult, definitions.list_contacts_decoder)
    CountContacts ->
      try_decode(res, CountContactsResult, definitions.count_decoder)
    CreateContact ->
      try_decode(res, CreateContactResult, definitions.created_contact_decoder)
    DeleteContact ->
      try_decode(res, DeleteContactResult, definitions.deleted_contact_decoder)
    Subscribe | Unsubscribe ->
      try_decode(res, SubscriptionResult, definitions.subscription_decoder)
  }
}

fn try_decode(
  res: Response(String),
  to constructor: fn(r) -> ActionResult,
  using decoder: fn() -> dynamic.Decoder(r),
) -> Result(ActionResult, PlunkError) {
  use d <- try(bridge.decode(res, decoder))
  Ok(constructor(d))
}
