defmodule Commanded.Shredder.CreateEncryptionKey do
  @moduledoc """
  Create an encryption key.
  """
  @derive Jason.Encoder

  @type t :: %__MODULE__{
          encryption_key_uuid: String.t(),
          name: String.t(),
          expiry: NaiveDateTime.t() | nil
        }

  defstruct [
    :encryption_key_uuid,
    :name,
    :expiry
  ]
end
