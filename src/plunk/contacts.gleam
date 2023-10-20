import gleam/http.{Get, Post}
import gleam/dynamic
import gleam/result.{try}
import gleam/http/request.{Request}
import gleam/http/response.{Response}
import plunk/instance.{Instance}
import plunk/types.{PlunkError}
import plunk/internal/bridge.{make_request}
import plunk/internal/contacts_def as definitions

pub type Contact =
  definitions.Contact

pub type ExtendedContact =
  definitions.ExtendedContact

pub type ActionResult {
  GetContactResult(ExtendedContact)
  ListContactsResult(List(Contact))
}

pub type For {
  GetContact
  ListContacts
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
