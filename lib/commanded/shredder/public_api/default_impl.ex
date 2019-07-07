defmodule Commanded.Shredder.DefaultImpl do
  @moduledoc false
  @behaviour Commanded.Shredder.Impl

  @default_name "key:0"
  @base64_opts [padding: false]
  @missing_key "key_not_found"

  alias Commanded.Shredder.Impl
  @type key_return :: Impl.key_return()
  @type crypto_return :: Impl.crypto_return()
  @type error :: Impl.error()
  @type expiry :: Impl.expiry()

  import Ecto.Query

  alias Commanded.Shredder.Repo
  alias Commanded.Shredder.Router
  alias Commanded.Shredder.Projection
  alias Projection.EncryptionKey
  alias Commanded.Shredder.CreateEncryptionKey
  alias Commanded.Shredder.UpdateEncryptionKey
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
        plain_fields = Options.get_plain_fields(opts)

        event
        |> transform_event(plain_fields, key, &crypto_module().encrypt_value/3)
        |> transform_event(plain_fields, @base64_opts, &base64_encode/3)
    end
  end

  @spec decrypt_event(event :: struct, opts :: Keyword.t()) :: crypto_return
  def decrypt_event(event, opts) do
    case crypto_setup(event, opts) do
      {:error, @missing_key} ->
        field_defaults = Options.get_fields(opts)
        plain_fields = Options.get_plain_fields(opts)
        transform_event(event, plain_fields, field_defaults, &fill_default_value/3)

      {:error, _message} = error ->
        error

      key ->
        plain_fields = Options.get_plain_fields(opts)

        event
        |> transform_event(plain_fields, @base64_opts, &base64_decode/3)
        |> transform_event(plain_fields, key, &crypto_module().decrypt_value/3)
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
      nil -> {:error, @missing_key}
      key -> key
    end
  end

  defp fill_default_value(_value, field, fields),
    do: Keyword.get(fields, field)

  defp base64_encode(value, _field, opts),
    do: Base.encode64(value, opts)

  defp base64_decode(value, _field, opts),
    do: Base.decode64(value, opts)

  defp transform_event(event, fields, extra, transform),
    do:
      Enum.reduce(
        fields,
        event,
        &transform_field(&1, &2, extra, transform)
      )

  defp transform_field(field, event, extra, transform)
       when is_atom(field),
       do:
         Map.put(
           event,
           field,
           event |> Map.get(field, "") |> transform.(field, extra)
         )
end
