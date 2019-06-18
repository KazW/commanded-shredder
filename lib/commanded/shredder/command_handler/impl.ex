defmodule Commanded.Shredder.CommandHandler.Impl do
  @moduledoc false

  @type error :: {:error, String.t()}

  @callback create_encryption_key(
              encryption_key :: Commanded.Shredder.EncryptionKey.t(),
              create_command :: Commanded.Shredder.CreateEncryptionKey.t()
            ) :: [Commanded.Shredder.EncryptionKeyCreated.t()] | error

  @callback update_encryption_key(
              encryption_key :: Commanded.Shredder.EncryptionKey.t(),
              update_command :: Commanded.Shredder.UpdateEncryptionKey.t()
            ) :: [Commanded.Shredder.EncryptionKeyUpdated.t()] | error

  @callback expire_encryption_key(
              encryption_key :: Commanded.Shredder.EncryptionKey.t(),
              expire_command :: Commanded.Shredder.ExpireEncryptionKey.t()
            ) :: [Commanded.Shredder.EncryptionKeyExpired.t()] | error

  @callback delete_encryption_key(
              encryption_key :: Commanded.Shredder.EncryptionKey.t(),
              delete_command :: Commanded.Shredder.DeleteEncryptionKey.t()
            ) :: [Commanded.Shredder.EncryptionKeyDeleted.t()] | error
end
