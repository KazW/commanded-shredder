defmodule Commanded.Shredder.Crypto do
  @behaviour Commanded.Shredder.CryptoImpl

  @type crypto_return :: Commanded.Shredder.Impl.crypto_return()
  alias Commanded.Shredder.Projection.EncryptionKey

  @algorithms %{
    "AES256GCM" => :aes_gcm
  }

  @callback default_algorithm :: binary
  def default_algorithm,
    do: "AES256GCM"

  @callback supported_algorithms :: [binary]
  def supported_algorithms,
    do: Map.keys(@algorithms)

  @spec encrypt(
          value :: binary,
          field :: atom,
          key :: EncryptionKey.t()
        ) :: crypto_return
  def encrypt(value, _field, %EncryptionKey{key: key, algorithm: algorithm}) do
    iv = :crypto.strong_rand_bytes(16)

    {ciphertext, tag} =
      :crypto.block_encrypt(
        Map.get(@algorithms, algorithm),
        key,
        iv,
        {algorithm, to_string(value), 16}
      )

    iv <> tag <> ciphertext
  end

  @spec decrypt(
          value :: binary,
          field :: atom,
          key :: EncryptionKey.t()
        ) :: crypto_return
  def decrypt(value, _field, %EncryptionKey{key: key, algorithm: algorithm}) do
    <<iv::binary-16, tag::binary-16, ciphertext::binary>> = value

    :crypto.block_decrypt(
      Map.get(@algorithms, algorithm),
      key,
      iv,
      {algorithm, ciphertext, tag}
    )
  end
end
