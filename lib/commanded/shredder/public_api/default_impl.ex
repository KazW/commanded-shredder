defmodule Commanded.Shredder.DefaultImpl do
  @moduledoc false
  @behaviour Commanded.Shredder.Impl

  @default_name "key:0"

  alias Commanded.Shredder.Impl
  @type key_return :: Impl.key_return()
  @type crypto_return :: Impl.crypto_return()
  @type error :: Impl.error()
  @type expiry :: Impl.expiry()

  import Ecto.Query

  alias Commanded.Shredder.Repo
  alias Commanded.Shredder.Router
  alias Commanded.Shredder.Projection
  alias Commanded.Shredder.CreateEncryptionKey
  alias Commanded.Shredder.UpdateEncryptionKey
  alias Commanded.Shredder.Projection.EncryptionKey
  alias Commanded.Shredder.Options

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
  def encrypt_event(event, opts) do
    case crypto_setup(event, opts) do
      {:error, _message} = error ->
        error

      key ->
        crypto_module().encrypt(
          event,
          opts |> Options.get_fields() |> Keyword.new(),
          key
        )
    end
  end

  @spec decrypt_event(event :: struct, opts :: Keyword.t()) :: crypto_return
  def decrypt_event(event, opts) do
    case crypto_setup(event, opts) do
      {:error, _message} = error ->
        error

      key ->
        crypto_module().decrypt(
          event,
          opts |> Options.get_fields() |> Keyword.new(),
          key
        )
    end
  end

  defp crypto_module,
    do:
      Application.get_env(
        :commanded_shredder,
        :crypto_impl,
        Commanded.Shredder.Crypto
      )

  defp crypto_setup(event, opts) do
    with :ok <- Options.validate_options(opts),
         :ok <- Options.validate_fields(event, opts),
         :ok <- Options.validate_key_field(event, opts),
         do: get_encryption_key(event, opts)
  end

  defp get_encryption_key(event, opts) do
    {key_field, prefix} = Options.get_key_field(opts)

    case Repo.get(EncryptionKey, prefix <> Map.get(event, key_field)) do
      nil -> {:error, "key_not_found"}
      key -> key
    end
  end
end
