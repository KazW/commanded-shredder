defmodule Commanded.Shredder.CryptoImpl do
  alias Commanded.Shredder.Projection.EncryptionKey

  @type crypto_return ::
          Commanded.Shredder.Impl.crypto_return()

  @callback encrypt(
              event :: struct,
              fields :: list,
              key :: EncryptionKey.t()
            ) :: crypto_return

  @callback decrypt(
              event :: struct,
              fields :: list,
              key :: EncryptionKey.t()
            ) :: crypto_return
end
