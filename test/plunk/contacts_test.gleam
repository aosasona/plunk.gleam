import gleam/io
import gleam/hackney
import plunk
import plunk/contacts.{GetContact, GetContactResult}
// pub fn get_test() {
//   let instance = plunk.new("API_KEY")
//   let req = contacts.get(instance, "some-uuid-for-your-contact")
//   let assert Ok(resp) = hackney.send(req)
//   let assert Ok(data) = contacts.decode(resp, for: GetContact)
//   let assert GetContactResult(contact) = data
//   io.println(contact.id)
// }
