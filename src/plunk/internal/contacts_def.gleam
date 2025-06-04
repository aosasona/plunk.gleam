import gleam/dynamic/decode
import gleam/option.{type Option}

pub type Event {
  Event(
    id: String,
    name: String,
    project_id: String,
    template_id: Option(String),
    campaign_id: Option(String),
    created_at: String,
    updated_at: String,
  )
}

pub type Action {
  Action(
    id: String,
    name: String,
    run_once: Bool,
    delay: Int,
    project_id: Option(String),
    template_id: Option(String),
    created_at: String,
    updated_at: String,
  )
}

pub type Trigger {
  Trigger(
    id: String,
    contact_id: String,
    event_id: String,
    action_id: Option(String),
    created_at: String,
    updated_at: String,
    event: Option(Event),
    action: Option(Action),
  )
}

pub type Email {
  Email(
    id: String,
    message_id: String,
    subject: String,
    body: String,
    status: String,
    project_id: String,
    action_id: Option(String),
    campaign_id: Option(String),
    contact_id: String,
    created_at: String,
    updated_at: String,
  )
}

/// Unlike `Contact`, this has extra data like the triggers and emails
pub type ExtendedContact {
  ExtendedContact(
    id: String,
    email: String,
    data: Option(String),
    created_at: String,
    updated_at: String,
    triggers: List(Trigger),
    emails: List(Email),
  )
}

pub type Contact {
  Contact(
    id: String,
    email: String,
    subscribed: Bool,
    data: Option(String),
    created_at: String,
    updated_at: String,
  )
}

pub type CreatedContact {
  CreatedContact(
    success: Bool,
    id: String,
    email: String,
    subscribed: Bool,
    data: Option(decode.Dynamic),
    created_at: String,
    updated_at: String,
  )
}

pub type Count {
  Count(count: Int)
}

pub type Subscription {
  Subscription(success: Bool, contact: String, subscribed: Bool)
}

// Duplicated for proper type support
pub type DeletedContact {
  DeletedContact(
    success: Bool,
    id: String,
    email: String,
    subscribed: Bool,
    data: Option(decode.Dynamic),
    created_at: String,
    updated_at: String,
  )
}

fn action_decoder() -> decode.Decoder(Action) {
  use id <- decode.field("id", decode.string)
  use name <- decode.field("name", decode.string)
  use run_once <- decode.field("runOnce", decode.bool)
  use delay <- decode.field("delay", decode.int)
  use project_id <- decode.field("projectId", decode.optional(decode.string))
  use template_id <- decode.field("templateId", decode.optional(decode.string))
  use created_at <- decode.field("createdAt", decode.string)
  use updated_at <- decode.field("updatedAt", decode.string)
  decode.success(Action(
    id: id,
    name: name,
    run_once: run_once,
    delay: delay,
    project_id: project_id,
    template_id: template_id,
    created_at: created_at,
    updated_at: updated_at,
  ))
}

fn event_decoder() -> decode.Decoder(Event) {
  use id <- decode.field("id", decode.string)
  use name <- decode.field("name", decode.string)
  use project_id <- decode.field("projectId", decode.string)
  use template_id <- decode.field("templateId", decode.optional(decode.string))
  use campaign_id <- decode.field("campaignId", decode.optional(decode.string))
  use created_at <- decode.field("createdAt", decode.string)
  use updated_at <- decode.field("updatedAt", decode.string)
  decode.success(Event(
    id: id,
    name: name,
    project_id: project_id,
    template_id: template_id,
    campaign_id: campaign_id,
    created_at: created_at,
    updated_at: updated_at,
  ))
}

fn trigger_decoder() -> decode.Decoder(Trigger) {
  use id <- decode.field("id", decode.string)
  use contact_id <- decode.field("contactId", decode.string)
  use event_id <- decode.field("eventId", decode.string)
  use action_id <- decode.field("actionId", decode.optional(decode.string))
  use created_at <- decode.field("createdAt", decode.string)
  use updated_at <- decode.field("updatedAt", decode.string)
  use event <- decode.field("event", decode.optional(event_decoder()))
  use action <- decode.field("action", decode.optional(action_decoder()))
  decode.success(Trigger(
    id: id,
    contact_id: contact_id,
    event_id: event_id,
    action_id: action_id,
    created_at: created_at,
    updated_at: updated_at,
    event: event,
    action: action,
  ))
}

fn email_decoder() -> decode.Decoder(Email) {
  use id <- decode.field("id", decode.string)
  use message_id <- decode.field("messageId", decode.string)
  use subject <- decode.field("subject", decode.string)
  use body <- decode.field("body", decode.string)
  use status <- decode.field("status", decode.string)
  use project_id <- decode.field("projectId", decode.string)
  use action_id <- decode.field("actionId", decode.optional(decode.string))
  use campaign_id <- decode.optional_field(
    "campaignId",
    option.None,
    decode.optional(decode.string),
  )
  use contact_id <- decode.field("contactId", decode.string)
  use created_at <- decode.field("createdAt", decode.string)
  use updated_at <- decode.field("updatedAt", decode.string)
  decode.success(Email(
    id: id,
    message_id: message_id,
    subject: subject,
    body: body,
    status: status,
    project_id: project_id,
    action_id: action_id,
    campaign_id: campaign_id,
    contact_id: contact_id,
    created_at: created_at,
    updated_at: updated_at,
  ))
}

pub fn get_contact_decoder() -> decode.Decoder(ExtendedContact) {
  use id <- decode.field("id", decode.string)
  use email <- decode.field("email", decode.string)
  use data <- decode.field("data", decode.optional(decode.string))
  use created_at <- decode.field("createdAt", decode.string)
  use updated_at <- decode.field("updatedAt", decode.string)
  use triggers <- decode.field("triggers", decode.list(trigger_decoder()))
  use emails <- decode.field("emails", decode.list(email_decoder()))
  decode.success(ExtendedContact(
    id: id,
    email: email,
    data: data,
    created_at: created_at,
    updated_at: updated_at,
    triggers: triggers,
    emails: emails,
  ))
}

pub fn list_contacts_decoder() -> decode.Decoder(List(Contact)) {
  decode.list({
    use id <- decode.field("id", decode.string)
    use email <- decode.field("email", decode.string)
    use subscribed <- decode.field("subscribed", decode.bool)
    use data <- decode.field("data", decode.optional(decode.string))
    use created_at <- decode.field("createdAt", decode.string)
    use updated_at <- decode.field("updatedAt", decode.string)
    decode.success(Contact(
      id: id,
      email: email,
      subscribed: subscribed,
      data: data,
      created_at: created_at,
      updated_at: updated_at,
    ))
  })
}

pub fn count_decoder() -> decode.Decoder(Count) {
  use count <- decode.field("count", decode.int)
  decode.success(Count(count: count))
}

pub fn created_contact_decoder() -> decode.Decoder(CreatedContact) {
  use success <- decode.field("success", decode.bool)
  use id <- decode.field("id", decode.string)
  use email <- decode.field("email", decode.string)
  use subscribed <- decode.field("subscribed", decode.bool)
  use data <- decode.field("data", decode.optional(decode.dynamic))
  use created_at <- decode.field("createdAt", decode.string)
  use updated_at <- decode.field("updatedAt", decode.string)
  decode.success(CreatedContact(
    success: success,
    id: id,
    email: email,
    subscribed: subscribed,
    data: data,
    created_at: created_at,
    updated_at: updated_at,
  ))
}

pub fn deleted_contact_decoder() -> decode.Decoder(DeletedContact) {
  use success <- decode.field("success", decode.bool)
  use id <- decode.field("id", decode.string)
  use email <- decode.field("email", decode.string)
  use subscribed <- decode.field("subscribed", decode.bool)
  use data <- decode.field("data", decode.optional(decode.dynamic))
  use created_at <- decode.field("createdAt", decode.string)
  use updated_at <- decode.field("updatedAt", decode.string)
  decode.success(DeletedContact(
    success: success,
    id: id,
    email: email,
    subscribed: subscribed,
    data: data,
    created_at: created_at,
    updated_at: updated_at,
  ))
}

pub fn subscription_decoder() -> decode.Decoder(Subscription) {
  use success <- decode.field("success", decode.bool)
  use contact <- decode.field("contact", decode.string)
  use subscribed <- decode.field("subscribed", decode.bool)
  decode.success(Subscription(
    success: success,
    contact: contact,
    subscribed: subscribed,
  ))
}
