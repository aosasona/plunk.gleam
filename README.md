# plunk

[![Package Version](https://img.shields.io/hexpm/v/plunk)](https://hex.pm/packages/plunk)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/plunk/)

## Installation

This library has been designed to be independent of whatever HTTP request library or runtime you choose or wish to use, and you can install for all targets by running:

```sh
gleam add plunk
```

## Usage

```rust
import gleam/erlang/os
import plunk.{send}
import plunk/event.{track}
import your_preferred_http_client as c

pub fn main() {
    let assert Ok(api_key) = os.get_env("PLUNK_API_KEY")
    let p = plunk.new(key: api_key, sender: c.send)

    // Track an event in your application
    let assert Ok(_) = p
        |> track(event: "my_event", email: "someone@example.com", data: [])
        |> send
}
```
