import gleam/json
import gleam/dynamic.{Decoder}
import gleam/option.{Option}
import gleam/http.{Post}
import gleam/http/request.{Request}
import gleam/http/response.{Response}
import plunk/instance.{Instance}
import plunk/types.{PlunkError}
import plunk/internal/bridge.{make_request}

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
  dynamic.decode2(
    Contact,
    dynamic.field("id", dynamic.string),
    dynamic.field("email", dynamic.string),
  )
}

fn email_decoder() -> Decoder(Email) {
  dynamic.decode2(
    Email,
    dynamic.field("contact", contact_decoder()),
    dynamic.field("email", dynamic.string),
  )
}

pub fn send_transactional_email_decoder() -> Decoder(
  SendTransactionalEmailResponse,
) {
  dynamic.decode3(
    SendTransactionalEmailResponse,
    dynamic.field("success", dynamic.bool),
    dynamic.field("emails", dynamic.list(of: email_decoder())),
    dynamic.optional_field("timestamp", dynamic.string),
  )
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
/// import plunk/transactional.{Single, TransactionalEmail}
///
/// let instance = plunk.new(key: "YOUR_API_KEY")
///
/// let req =
///   instance
///   |> transactional.send(
///     mail: TransactionalEmail(
///       to: Address("someone@example.com"),
///       subject: "Hello",
///       body: "<h1>Hello, World!</h1>",
///       name: None,
///       from: None,
///     )
///   )
/// let assert Ok(resp) = hackney.send(req)
/// let assert Ok(data) = transactional.decode(resp)
/// // do whatever you want with the data
/// ```
pub fn send(
  instance: Instance,
  mail mail: TransactionalEmail,
) -> Request(String) {
  let body =
    json.object([
      #(
        "to",
        case mail.to {
          Address(addr) -> json.string(addr)
          Addresses(addrs) -> json.array(addrs, of: json.string)
        },
      ),
      #("subject", json.string(mail.subject)),
      #("body", json.string(mail.body)),
      #("name", json.nullable(mail.name, json.string)),
      #("from", json.nullable(mail.from, json.string)),
    ])
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
