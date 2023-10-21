# plunk

[![Package Version](https://img.shields.io/hexpm/v/plunk)](https://hex.pm/packages/plunk)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/plunk/)

## Installation

This library has been designed to be independent of whatever HTTP request library or runtime you choose or wish to use, and you can install for all targets by running:

```sh
gleam add plunk
```

## Usage

```gleam
import gleam/erlang/os
import gleam/io
import gleam/json
import gleam/result
import gleam/hackney
import plunk
import plunk/event.{Event}

pub fn main() {
  let key =
    os.get_env("PLUNK_API_KEY")
    |> result.unwrap("")

  let assert Ok(resp) =
    plunk.new(key)
    |> event.track(Event(
      event: "your-event",
      email: "someone@example.com",
      data: [#("name", json.string("John"))],
    ))
    |> hackney.send

  let assert Ok(e) = event.decode(resp)
  io.debug(e)
}
```

See [documentation](https://hexdocs.pm/plunk/) for each module on Hexdocs or go through the [test](./test/) folder for examples.

## Development

To run tests locally, you need to add your Plunk API key to the environment variables like this:

```sh
export PLUNK_API_KEY="sk_..."
```

> NOTE: tests are designed to run only in the BEAM runtime (erlang target) as they depend on hackney
