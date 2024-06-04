import gleam/erlang/os
import gleam/http.{Post}
import gleam/json
import gleam/list
import gleam/result
import gleeunit/should
import plunk/instance.{Instance}
import plunk/internal/bridge

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

pub fn make_request_test() {
  let key =
    os.get_env("PLUNK_API_KEY")
    |> result.unwrap("")

  let body =
    json.object([#("name", json.string("John Doe"))])
    |> json.to_string

  let req =
    Instance(api_key: key)
    |> bridge.make_request("/ping", Post, body)

  should.equal(req.method, Post)
  should.equal(req.host, "api.useplunk.com")
  should.equal(req.path, "/v1/ping")
  should.equal(req.body, body)

  req.headers
  |> list.key_find("Content-Type")
  |> should.equal(Ok("application/json"))

  req.headers
  |> list.key_find("Accept")
  |> should.equal(Ok("application/json"))

  req.headers
  |> list.key_find("Authorization")
  |> should.equal(Ok("Bearer " <> key))
}
