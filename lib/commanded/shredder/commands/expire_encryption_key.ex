defmodule Commanded.Shredder.ExpireEncryptionKey do
  @moduledoc """
  Expire an encryption key immediately.
  """
  @derive Jason.Encoder

  @type t :: %__MODULE__{
          encryption_key_uuid: String.t(),
          name: String.t()
        }

  defstruct [
    :encryption_key_uuid,
    :name
  ]
end
