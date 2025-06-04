import gleam/dynamic/decode.{type Decoder}
import gleam/http.{Post}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/json
import gleam/option.{type Option}
import plunk/instance.{type Instance}
import plunk/internal/bridge.{make_request}
import plunk/internal/utils
import plunk/types.{type PlunkError}

pub type To {
  Address(String)
  Addresses(List(String))
}

pub type TransactionalEmail {
  TransactionalEmail(
    to: To,
    subject: String,
    body: String,
    name: Option(String),
    from: Option(String),
  )
}

pub type Contact {
  Contact(id: String, email: String)
}

pub type Email {
  Email(contact: Contact, email: String)
}

pub type SendTransactionalEmailResponse {
  SendTransactionalEmailResponse(
    success: Bool,
    emails: List(Email),
    timestamp: Option(String),
  )
}

fn contact_decoder() -> Decoder(Contact) {
  use id <- decode.field("id", decode.string)
  use email <- decode.field("email", decode.string)
  decode.success(Contact(id: id, email: email))
}

fn email_decoder() -> Decoder(Email) {
  use contact <- decode.field("contact", contact_decoder())
  use email <- decode.field("email", decode.string)
  decode.success(Email(contact: contact, email: email))
}

pub fn send_transactional_email_decoder() -> Decoder(
  SendTransactionalEmailResponse,
) {
  use success <- decode.field("success", decode.bool)
  use emails <- decode.field("emails", decode.list(email_decoder()))
  use timestamp <- decode.optional_field(
    "timestamp",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(SendTransactionalEmailResponse(
    success: success,
    emails: emails,
    timestamp: timestamp,
  ))
}

///
/// Send a transactional email
///
/// # Example
///
/// ```gleam
/// import gleam/option.{None}
/// import gleam/hackney
/// import plunk
/// import plunk/transactional.{Address, TransactionalEmail}
///
/// fn main() {
///   let instance = plunk.new(key: "YOUR_API_KEY")
///
///   let req =
///     instance
///     |> transactional.send(
///       mail: TransactionalEmail(
///         to: Address("someone@example.com"),
///         subject: "Hello",
///         body: "<h1>Hello, World!</h1>",
///         name: None,
///         from: None,
///       )
///     )
///   let assert Ok(resp) = hackney.send(req)
///   let assert Ok(data) = transactional.decode(resp)
///   // do whatever you want with the data
/// }
/// ```
pub fn send(
  instance: Instance,
  mail mail: TransactionalEmail,
) -> Request(String) {
  let body =
    [
      #("to", case mail.to {
        Address(addr) -> json.string(addr)
        Addresses(addrs) -> json.array(addrs, of: json.string)
      }),
      #("subject", json.string(mail.subject)),
      #("body", json.string(mail.body)),
    ]
    |> utils.omit_if_none("name", mail.name, json.string)
    |> utils.omit_if_none("from", mail.from, json.string)
    |> json.object
    |> json.to_string

  instance
  |> make_request(method: Post, endpoint: "/send", body: body)
}

/// Decode the raw response into a `SendTransactionalEmailResponse` type wrapped in a `Result` type that can be pattern matched on.
pub fn decode(
  res: Response(String),
) -> Result(SendTransactionalEmailResponse, PlunkError) {
  res
  |> bridge.decode(send_transactional_email_decoder)
}
