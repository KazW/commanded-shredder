defmodule Commanded.Shredder.CreateEncryptionKey do
  @moduledoc """
  Create an encryption key.
  """
  @derive Jason.Encoder

  @type t :: %__MODULE__{
          encryption_key_uuid: String.t(),
          name: String.t(),
          algorithm: String.t() | nil,
          expiry: NaiveDateTime.t() | nil
        }

  defstruct [
    :encryption_key_uuid,
    :name,
    :algorithm,
    :expiry
  ]
end
