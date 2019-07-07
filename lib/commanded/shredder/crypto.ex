defmodule Commanded.Shredder.Crypto do
  @behaviour Commanded.Shredder.CryptoImpl

  @type crypto_return :: Commanded.Shredder.Impl.crypto_return()
  alias Commanded.Shredder.Projection.EncryptionKey

  @spec encrypt(
          value :: binary,
          field :: atom,
          key :: EncryptionKey.t()
        ) :: crypto_return
  def encrypt(value, _field, %EncryptionKey{key: key, key_type: key_type}) do
    iv = :crypto.strong_rand_bytes(16)

    {ciphertext, tag} =
      :crypto.block_encrypt(
        :aes_gcm,
        key,
        iv,
        {key_type, to_string(value), 16}
      )

    iv <> tag <> ciphertext
  end

  @spec decrypt(
          value :: binary,
          field :: atom,
          key :: EncryptionKey.t()
        ) :: crypto_return
  def decrypt(value, _field, %EncryptionKey{key: key, key_type: key_type}) do
    <<iv::binary-16, tag::binary-16, ciphertext::binary>> = value
    :crypto.block_decrypt(:aes_gcm, key, iv, {key_type, ciphertext, tag})
  end
end
