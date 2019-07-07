defmodule Commanded.Shredder.CryptoImpl do
  alias Commanded.Shredder.Projection.EncryptionKey

  @type crypto_return ::
          Commanded.Shredder.Impl.crypto_return()

  @callback default_algorithm :: binary
  @callback supported_algorithms :: [binary]

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

  @spec crypto_module :: atom
  def crypto_module,
    do:
      Application.get_env(
        :commanded_shredder,
        :crypto_impl,
        Commanded.Shredder.Crypto
      )
end
