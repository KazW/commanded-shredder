defmodule Commanded.Shredder.EncryptionKeyCreated do
  @moduledoc false
  @derive Jason.Encoder

  @type t :: %__MODULE__{
          encryption_key_uuid: String.t(),
          name: String.t(),
          algorithm: String.t(),
          expiry: NaiveDateTime.t() | nil
        }

  defstruct [
    :encryption_key_uuid,
    :name,
    :algorithm,
    :expiry
  ]
end
