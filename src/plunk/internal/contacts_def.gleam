import gleam/dynamic
import gleam/list
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
    data: Option(dynamic.Dynamic),
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
    data: Option(dynamic.Dynamic),
    created_at: String,
    updated_at: String,
  )
}

fn action_decoder() -> dynamic.Decoder(Action) {
  dynamic.decode8(
    Action,
    dynamic.field("id", dynamic.string),
    dynamic.field("name", dynamic.string),
    dynamic.field("runOnce", dynamic.bool),
    dynamic.field("delay", dynamic.int),
    dynamic.field("projectId", dynamic.optional(dynamic.string)),
    dynamic.field("templateId", dynamic.optional(dynamic.string)),
    dynamic.field("createdAt", dynamic.string),
    dynamic.field("updatedAt", dynamic.string),
  )
}

fn event_decoder() -> dynamic.Decoder(Event) {
  dynamic.decode7(
    Event,
    dynamic.field("id", dynamic.string),
    dynamic.field("name", dynamic.string),
    dynamic.field("projectId", dynamic.string),
    dynamic.field("templateId", dynamic.optional(dynamic.string)),
    dynamic.field("campaignId", dynamic.optional(dynamic.string)),
    dynamic.field("createdAt", dynamic.string),
    dynamic.field("updatedAt", dynamic.string),
  )
}

fn trigger_decoder() -> dynamic.Decoder(Trigger) {
  dynamic.decode8(
    Trigger,
    dynamic.field("id", dynamic.string),
    dynamic.field("contactId", dynamic.string),
    dynamic.field("eventId", dynamic.string),
    dynamic.field("actionId", dynamic.optional(dynamic.string)),
    dynamic.field("createdAt", dynamic.string),
    dynamic.field("updatedAt", dynamic.string),
    dynamic.field("event", dynamic.optional(event_decoder())),
    dynamic.field("action", dynamic.optional(action_decoder())),
  )
}

fn email_decoder() -> dynamic.Decoder(Email) {
  fn(dyn: dynamic.Dynamic) {
    let id_dc = dynamic.field("id", dynamic.string)(dyn)
    let message_id_dc = dynamic.field("messageId", dynamic.string)(dyn)
    let subject_dc = dynamic.field("subject", dynamic.string)(dyn)
    let body_dc = dynamic.field("body", dynamic.string)(dyn)
    let status_dc = dynamic.field("status", dynamic.string)(dyn)
    let project_id_dc = dynamic.field("projectId", dynamic.string)(dyn)
    let action_id_dc =
      dynamic.field("actionId", dynamic.optional(dynamic.string))(dyn)
    let campaign_id_dc =
      dynamic.field("campaignId", dynamic.optional(dynamic.string))(dyn)
    let contact_id_dc = dynamic.field("contactId", dynamic.string)(dyn)
    let created_at_dc = dynamic.field("createdAt", dynamic.string)(dyn)
    let updated_at_dc = dynamic.field("updatedAt", dynamic.string)(dyn)

    case
      id_dc,
      message_id_dc,
      subject_dc,
      body_dc,
      status_dc,
      project_id_dc,
      action_id_dc,
      campaign_id_dc,
      contact_id_dc,
      created_at_dc,
      updated_at_dc
    {
      Ok(id),
        Ok(message_id),
        Ok(subject),
        Ok(body),
        Ok(status),
        Ok(project_id),
        Ok(action_id),
        Ok(campaign_id),
        Ok(contact_id),
        Ok(created_at),
        Ok(updated_at)
      -> {
        Ok(Email(
          id,
          message_id,
          subject,
          body,
          status,
          project_id,
          action_id,
          campaign_id,
          contact_id,
          created_at,
          updated_at,
        ))
      }
      a, b, c, d, e, f, g, h, i, j, k -> {
        Error(
          list.concat([
            all_errors(a),
            all_errors(b),
            all_errors(c),
            all_errors(d),
            all_errors(e),
            all_errors(f),
            all_errors(g),
            all_errors(h),
            all_errors(i),
            all_errors(j),
            all_errors(k),
          ]),
        )
      }
    }
  }
}

pub fn get_contact_decoder() -> dynamic.Decoder(ExtendedContact) {
  dynamic.decode7(
    ExtendedContact,
    dynamic.field("id", dynamic.string),
    dynamic.field("email", dynamic.string),
    dynamic.field("data", dynamic.optional(dynamic.string)),
    dynamic.field("createdAt", dynamic.string),
    dynamic.field("updatedAt", dynamic.string),
    dynamic.field("triggers", dynamic.list(trigger_decoder())),
    dynamic.field("emails", dynamic.list(email_decoder())),
  )
}

pub fn list_contacts_decoder() -> dynamic.Decoder(List(Contact)) {
  dynamic.list(dynamic.decode6(
    Contact,
    dynamic.field("id", dynamic.string),
    dynamic.field("email", dynamic.string),
    dynamic.field("subscribed", dynamic.bool),
    dynamic.field("data", dynamic.optional(dynamic.string)),
    dynamic.field("createdAt", dynamic.string),
    dynamic.field("updatedAt", dynamic.string),
  ))
}

pub fn count_decoder() -> dynamic.Decoder(Count) {
  dynamic.decode1(Count, dynamic.field("count", dynamic.int))
}

pub fn created_contact_decoder() -> dynamic.Decoder(CreatedContact) {
  dynamic.decode7(
    CreatedContact,
    dynamic.field("success", dynamic.bool),
    dynamic.field("id", dynamic.string),
    dynamic.field("email", dynamic.string),
    dynamic.field("subscribed", dynamic.bool),
    dynamic.field("data", dynamic.optional(dynamic.dynamic)),
    dynamic.field("createdAt", dynamic.string),
    dynamic.field("updatedAt", dynamic.string),
  )
}

pub fn deleted_contact_decoder() -> dynamic.Decoder(DeletedContact) {
  dynamic.decode7(
    DeletedContact,
    dynamic.field("success", dynamic.bool),
    dynamic.field("id", dynamic.string),
    dynamic.field("email", dynamic.string),
    dynamic.field("subscribed", dynamic.bool),
    dynamic.field("data", dynamic.optional(dynamic.dynamic)),
    dynamic.field("createdAt", dynamic.string),
    dynamic.field("updatedAt", dynamic.string),
  )
}

pub fn subscription_decoder() -> dynamic.Decoder(Subscription) {
  dynamic.decode3(
    Subscription,
    dynamic.field("success", dynamic.bool),
    dynamic.field("contact", dynamic.string),
    dynamic.field("subscribed", dynamic.bool),
  )
}

fn all_errors(
  result: Result(a, List(dynamic.DecodeError)),
) -> List(dynamic.DecodeError) {
  case result {
    Ok(_) -> []
    Error(errors) -> errors
  }
}
