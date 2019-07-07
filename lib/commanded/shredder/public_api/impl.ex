defmodule Commanded.Shredder.Impl do
  @type expiry :: NaiveDateTime.t() | nil
  @type error :: {:error, String.t()}
  @type key_return :: :ok | error
  @type crypto_return :: struct | error

  @callback create_encryption_key(
              encryption_key_uuid :: String.t(),
              expiry :: expiry
            ) :: key_return

  @callback update_encryption_key(
              encryption_key_uuid :: String.t(),
              expiry :: expiry
            ) :: key_return

  @callback encrypt_event(
              event :: struct,
              opts :: Keyword.t()
            ) :: crypto_return

  @callback decrypt_event(
              event :: struct,
              opts :: Keyword.t()
            ) :: crypto_return
end
