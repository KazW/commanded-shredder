defmodule Commanded.Shredder.DefaultImpl do
  @moduledoc false
  @behaviour Commanded.Shredder.Impl

  @default_name "key:0"

  alias Commanded.Shredder.Impl
  @type key_return :: Impl.key_return()
  @type crypto_return :: Impl.crypto_return()
  @type error :: Impl.error()
  @type expiry :: Impl.expiry()

  alias Commanded.Shredder.Router
  alias Commanded.Shredder.Projection
  alias Commanded.Shredder.CreateEncryptionKey
  alias Commanded.Shredder.UpdateEncryptionKey

  @spec create_encryption_key(String.t(), expiry :: expiry) :: key_return
  def create_encryption_key(encryption_key_uuid, expiry),
    do:
      %CreateEncryptionKey{
        encryption_key_uuid: encryption_key_uuid,
        name: @default_name,
        expiry: expiry
      }
      |> wait_for_projection()

  @spec update_encryption_key(String.t(), expiry :: expiry) :: key_return
  def update_encryption_key(encryption_key_uuid, expiry),
    do:
      %UpdateEncryptionKey{
        encryption_key_uuid: encryption_key_uuid,
        name: @default_name,
        expiry: expiry
      }
      |> wait_for_projection()

  defp wait_for_projection(command),
    do: command |> Router.dispatch(consistency: [Projection])

  @spec encrypt_event(event :: struct, opts :: Keyword.t()) :: crypto_return
  def encrypt_event(event, _opts) do
    event
  end

  @spec decrypt_event(event :: struct, opts :: Keyword.t()) :: crypto_return
  def decrypt_event(event, _opts) do
    event
  end
end
