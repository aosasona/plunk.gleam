import plunk/internal/bridge
import gleeunit/should

pub fn normalize_path_test() {
  "/foo/bar/baz"
  |> bridge.normalize_path
  |> should.equal("/foo/bar/baz")

  "foo/bar/baz"
  |> bridge.normalize_path
  |> should.equal("/foo/bar/baz")

  "foo/bar/baz/"
  |> bridge.normalize_path
  |> should.equal("/foo/bar/baz")

  "/foo/bar/baz/"
  |> bridge.normalize_path
  |> should.equal("/foo/bar/baz")
}
