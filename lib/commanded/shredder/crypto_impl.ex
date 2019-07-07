defmodule Commanded.Shredder.CryptoImpl do
  alias Commanded.Shredder.Projection.EncryptionKey

  @type crypto_return ::
          Commanded.Shredder.Impl.crypto_return()

  @callback encrypt(
              value :: binary,
              field :: atom,
              key :: EncryptionKey.t()
            ) :: crypto_return

  @callback decrypt(
              value :: binary,
              field :: atom,
              key :: EncryptionKey.t()
            ) :: crypto_return
end
