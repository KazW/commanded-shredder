defmodule Commanded.Shredder.Crypto do
  @behaviour Commanded.Shredder.CryptoImpl

  alias Commanded.Shredder.Projection.EncryptionKey

  @algorithms %{
    "AES256GCM" => :aes_gcm
  }

  @spec default_algorithm :: binary
  def default_algorithm,
    do: "AES256GCM"

  @spec supported_algorithms :: [binary]
  def supported_algorithms,
    do: Map.keys(@algorithms)

  @spec generate_key(algorithm :: binary) :: binary
  def generate_key(_algorithm),
    do: :crypto.strong_rand_bytes(32)

  @spec encrypt(
          value :: binary,
          field :: atom,
          key :: EncryptionKey.t()
        ) :: binary
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
        ) :: binary
  def decrypt(
        <<
          iv::binary-16,
          tag::binary-16,
          ciphertext::binary
        >>,
        _field,
        %EncryptionKey{
          key: key,
          algorithm: algorithm
        }
      ),
      do:
        :crypto.block_decrypt(
          Map.get(@algorithms, algorithm),
          key,
          iv,
          {algorithm, ciphertext, tag}
        )
end
