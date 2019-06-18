defmodule Commanded.Shredder.CommandHandler do
  @moduledoc false
  @behaviour Commanded.Commands.Handler
  @behaviour Commanded.Shredder.CommandHandler.Impl

  alias Commanded.Shredder.EncryptionKey

  alias Commanded.Shredder.CreateEncryptionKey
  alias Commanded.Shredder.UpdateEncryptionKey
  alias Commanded.Shredder.ExpireEncryptionKey
  alias Commanded.Shredder.DeleteEncryptionKey

  alias Commanded.Shredder.EncryptionKeyCreated
  alias Commanded.Shredder.EncryptionKeyUpdated
  alias Commanded.Shredder.EncryptionKeyExpired
  alias Commanded.Shredder.EncryptionKeyDeleted

  @type command ::
          CreateEncryptionKey.t()
          | UpdateEncryptionKey.t()
          | ExpireEncryptionKey.t()
          | DeleteEncryptionKey.t()

  @type event ::
          EncryptionKeyCreated.t()
          | EncryptionKeyUpdated.t()
          | EncryptionKeyExpired.t()
          | EncryptionKeyDeleted.t()

  @type error :: {:error, String.t()}
  @type return :: [event] | error

  @spec handle(encryption_key :: EncryptionKey.t(), command :: command) ::
          [event] | error
  def handle(%EncryptionKey{} = encryption_key, %CreateEncryptionKey{} = create_command),
    do: create_encryption_key(encryption_key, create_command)

  def handle(%EncryptionKey{} = encryption_key, %UpdateEncryptionKey{} = update_command),
    do: update_encryption_key(encryption_key, update_command)

  def handle(%EncryptionKey{} = encryption_key, %ExpireEncryptionKey{} = expire_command),
    do: expire_encryption_key(encryption_key, expire_command)

  def handle(%EncryptionKey{} = encryption_key, %DeleteEncryptionKey{} = delete_command),
    do: delete_encryption_key(encryption_key, delete_command)

  @spec create_encryption_key(
          encryption_key :: EncryptionKey.t(),
          create_command :: CreateEncryptionKey.t()
        ) :: [EncryptionKeyCreated.t()] | error
  def create_encryption_key(encryption_key, create_command),
    do: impl().create_encryption_key(encryption_key, create_command)

  @spec update_encryption_key(
          encryption_key :: EncryptionKey.t(),
          update_command :: UpdateEncryptionKey.t()
        ) :: [EncryptionKeyUpdated.t()] | error
  def update_encryption_key(encryption_key, update_command),
    do: impl().update_encryption_key(encryption_key, update_command)

  @spec expire_encryption_key(
          encryption_key :: EncryptionKey.t(),
          expire_command :: ExpireEncryptionKey.t()
        ) :: [EncryptionKeyExpired.t()] | error
  def expire_encryption_key(encryption_key, expire_command),
    do: impl().expire_encryption_key(encryption_key, expire_command)

  @spec delete_encryption_key(
          encryption_key :: EncryptionKey.t(),
          delete_command :: DeleteEncryptionKey.t()
        ) :: [EncryptionKeyDeleted.t()] | error
  def delete_encryption_key(encryption_key, delete_command),
    do: impl().delete_encryption_key(encryption_key, delete_command)

  defp impl,
    do:
      Application.get_env(
        :commanded_shredder,
        :commanded_shredder_handler_impl,
        Commanded.Shredder.CommandHandler.DefaultImpl
      )
end
