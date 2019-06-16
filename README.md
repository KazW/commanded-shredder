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

## Getting started and usage guides

- [Getting started](guides/Getting%20Started.md)
- [Usage](guides/Usage.md)
- [Testing](guides/Testing.md)

## License

This project is licensed under the MIT license. Please refer to the
[LICENSE](LICENSE.md) for the full license text.
