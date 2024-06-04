import gleeunit
import gleeunit/should
import plunk

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn new_test() {
  let p = plunk.new(key: "abc123")

  p.api_key
  |> should.equal("abc123")
}
