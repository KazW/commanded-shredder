defmodule Commanded.Shredder.CryptoImpl do
  alias Commanded.Shredder.Projection.EncryptionKey

  @callback default_algorithm :: binary
  @callback supported_algorithms :: [binary]
  @callback generate_key(algorithm :: binary) :: binary

  @callback encrypt(
              value :: binary,
              field :: atom,
              key :: EncryptionKey.t()
            ) :: binary

  @callback decrypt(
              value :: binary,
              field :: atom,
              key :: EncryptionKey.t()
            ) :: binary

  @spec crypto_module :: atom
  def crypto_module,
    do:
      Application.get_env(
        :commanded_shredder,
        :crypto_impl,
        Commanded.Shredder.Crypto
      )
end
