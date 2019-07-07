defmodule Commanded.Shredder.Crypto do
  @behaviour Commanded.Shredder.CryptoImpl
  @type crypto_return :: Commanded.Shredder.Impl.crypto_return()
  alias Commanded.Shredder.Projection.EncryptionKey

  @base64_opts [padding: false]

  @spec encrypt(
          event :: struct,
          fields :: list,
          key :: EncryptionKey.t()
        ) :: crypto_return
  def encrypt(event, fields, key) do
    plain_fields = Keyword.keys(fields)

    event
    |> transform_event(plain_fields, key, &encrypt_value/2)
    |> transform_event(plain_fields, key, &base64_encode/2)
  end

  @spec decrypt(
          event :: struct,
          fields :: list,
          key :: EncryptionKey.t()
        ) :: crypto_return
  def decrypt(event, fields, key) do
    event
    |> transform_event(Keyword.keys(fields), key, &base64_decode/2)
    |> transform_event(fields, key, &decrypt_value/2)
  end

  defp transform_event(event, fields, key, trans),
    do: Enum.reduce(fields, event, &transform_field(&1, &2, key, trans))

  defp transform_field({field, default}, event, key, trans)
       when is_atom(field),
       do: transform_field(field, event, key, trans, default)

  defp transform_field(field, event, key, trans, default \\ "")
       when is_atom(field),
       do:
         Map.put(
           event,
           field,
           Map.get(event, field, default) |> trans.(key)
         )

  defp encrypt_value(value, %EncryptionKey{key: key, key_type: key_type}) do
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

  defp decrypt_value(value, %EncryptionKey{key: key, key_type: key_type}) do
    <<iv::binary-16, tag::binary-16, ciphertext::binary>> = value
    :crypto.block_decrypt(:aes_gcm, key, iv, {key_type, ciphertext, tag})
  end

  defp base64_encode(value, _key),
    do: Base.encode64(value, @base64_opts)

  defp base64_decode(value, _key),
    do: Base.decode64(value, @base64_opts)
end
