defmodule Commanded.Shredder do
  @behaviour Commanded.Shredder.Impl
  @moduledoc """
  Documentation for Commanded.Shredder.
  """

  alias Commanded.Shredder.Impl
  @type key_return :: Impl.key_return()
  @type crypto_return :: Impl.crypto_return()
  @type error :: Impl.error()
  @type expiry :: Impl.expiry()

  @doc """
  Create an encryption key.

  ## Examples

      iex> Commanded.Shredder.create_encryption_key(UUID.uuid4())
      :ok

      iex> Commanded.Shredder.create_encryption_key(UUID.uuid4(), NaiveDateTime.utc_now())
      {:error, "expiry_passed"}

      iex> Commanded.Shredder.create_encryption_key(UUID.uuid4(), NaiveDateTime.utc_now() |> NaiveDateTime.add(420))
      :ok
  """
  @spec create_encryption_key(encryption_key_uuid :: String.t(), expiry :: expiry) :: key_return
  def create_encryption_key(encryption_key_uuid, expiry \\ nil)

  def create_encryption_key(encryption_key_uuid, expiry),
    do: impl().create_encryption_key(encryption_key_uuid, expiry)

  @doc """
  Update an encryption key.

  ## Examples

      iex> Commanded.Shredder.update_encryption_key(UUID.uuid4())
      :ok

      iex> Commanded.Shredder.update_encryption_key(UUID.uuid4(), NaiveDateTime.utc_now())
      {:error, "expiry_passed"}

      iex> Commanded.Shredder.update_encryption_key(UUID.uuid4(), NaiveDateTime.utc_now() |> NaiveDateTime.add(420))
      :ok
  """
  @spec update_encryption_key(encryption_key_uuid :: String.t(), expiry :: expiry) :: key_return
  def update_encryption_key(encryption_key_uuid, expiry \\ nil)

  def update_encryption_key(encryption_key_uuid, expiry),
    do: impl().update_encryption_key(encryption_key_uuid, expiry)

  @doc """
  Encrypt an event.

  ## Examples

      iex> Commanded.Shredder.encrypt_event(
        %CreateUser{
          user_id: UUID.uuid4(),
          email: "bob@alice.com"
        },
        [
          key_field: [:user_id, prefix: "users:"],
          encrypt_fields: [:email]
        ]
      )
      {:error, "encryption_key_not_found"}

      iex> Commanded.Shredder.encrypt_event(
        %CreateUser{
          user_id: UUID.uuid4(),
          email: "bob@alice.com"
        },
        [
          create_key: true,
          key_field: [:user_id, prefix: "users:"],
          encrypt_fields: [:email]
        ]
      )
      %CreateUser{user_id: "f8f855ab-4ff9-41aa-ba2a-7cd18f79b3a8", email: "XXXYYYAAAZZZ"}
  """
  @spec encrypt_event(event :: struct, opts :: Keyword.t()) :: crypto_return
  def encrypt_event(event, opts),
    do: impl().encrypt_event(event, opts)

  @doc """
  Decrypt an event.

  ## Examples

      iex> Commanded.Shredder.decrypt_event(
        %CreateUser{
          user_id: UUID.uuid4(),
          email: "XXXYYYAAAZZZ"
        },
        [
          key_field: [:user_id, prefix: "users:"],
          encrypt_fields: [:email]
        ]
      )
      {:error, "encryption_key_not_found"}

      iex> Commanded.Shredder.decrypt_event(
        %CreateUser{
          user_id: "f8f855ab-4ff9-41aa-ba2a-7cd18f79b3a8",
          email: "XXXYYYAAAZZZ"
        },
        [
          key_field: [:user_id, prefix: "users:"],
          decrypt_fields: [email: "default@example.com"]
        ]
      )
      %CreateUser{user_id: "f8f855ab-4ff9-41aa-ba2a-7cd18f79b3a8", email: "bob@alice.com"}
  """
  @spec decrypt_event(event :: struct, opts :: Keyword.t()) :: crypto_return
  def decrypt_event(event, opts),
    do: impl().decrypt_event(event, opts)

  defp impl,
    do:
      Application.get_env(
        :commanded_shredder,
        :public_api_impl,
        Commanded.Shredder.DefaultImpl
      )
end
