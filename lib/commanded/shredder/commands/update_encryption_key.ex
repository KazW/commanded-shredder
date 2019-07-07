defmodule Commanded.Shredder.UpdateEncryptionKey do
  @moduledoc """
  Update an encryption key, currently only the expiry can be updated.
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
