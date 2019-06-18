defmodule Commanded.Shredder.DeleteEncryptionKey do
  @moduledoc """
  Delete an encryption key.
  """

  @type t :: %__MODULE__{
          encryption_key_uuid: String.t(),
          name: String.t()
        }

  defstruct [
    :encryption_key_uuid,
    :name
  ]
end
