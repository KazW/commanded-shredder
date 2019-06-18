defmodule Commanded.Shredder.Router do
  @moduledoc false
  use Commanded.Commands.Router

  alias Commanded.Shredder.EncryptionKey

  alias Commanded.Shredder.CreateEncryptionKey
  alias Commanded.Shredder.UpdateEncryptionKey
  alias Commanded.Shredder.ExpireEncryptionKey
  alias Commanded.Shredder.DeleteEncryptionKey

  identify(EncryptionKey,
    by: :encryption_key_uuid,
    prefix: &__MODULE__.encryption_key_prefix/0
  )

  dispatch(
    [
      CreateEncryptionKey,
      UpdateEncryptionKey,
      ExpireEncryptionKey,
      DeleteEncryptionKey
    ],
    to: Commanded.Shredder.CommandHandler,
    aggregate: EncryptionKey,
    lifespan: EncryptionKey.Lifespan
  )

  @spec encryption_key_prefix :: String.t()
  def encryption_key_prefix,
    do:
      Application.get_env(
        :commanded_shredder,
        :encryption_key_prefix,
        ""
      )
end
