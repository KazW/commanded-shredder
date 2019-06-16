# Commanded Shredder [![Build Status](https://travis-ci.org/KazW/commanded-shredder.svg?branch=master)](https://travis-ci.org/KazW/commanded-shredder)

Event shredding for [Commanded](https://github.com/commanded/commanded)
CQRS/ES applications.

Enables the permanent storage of personal user data (names, emails, addresses,
etc.) in an immutable eventstore while maintaining good data privacy practices.
Fields designated as personal are encrypted using a unique encryption key and
are written to the eventstore in encypted form. The unique encryption key is
stored in a seperate keystore. Personal information fields are decrypted at
runtime via Commanded's
[upcasting](https://github.com/commanded/commanded/blob/master/guides/Events.md#upcasting-events)
feature using the unique key. The deletion of the encryption key from the key
store renders the personal fields in the events that have used the key unreadable.

Please refer to the [CHANGELOG](CHANGELOG.md) for features, bug fixes, and any
upgrade advice included for each release.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `commanded_shredder` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:commanded_shredder, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/commanded_shredder](https://hexdocs.pm/commanded_shredder).
