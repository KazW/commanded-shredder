defmodule Commanded.Shredder.EncryptionKey do
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

  defmodule Lifespan do
    @behaviour Commanded.Aggregates.AggregateLifespan

    @spec after_event(any) :: :infinity | :stop
    def after_event(%Commanded.Shredder.EncryptionKeyExpired{}), do: :stop
    def after_event(%Commanded.Shredder.EncryptionKeyDeleted{}), do: :stop
    def after_event(_event), do: :infinity

    @spec after_command(any) :: :infinity
    def after_command(_command), do: :infinity

    @spec after_error(any) :: :stop
    def after_error(_error), do: :stop
  end

  alias Commanded.Shredder.EncryptionKeyCreated
  alias Commanded.Shredder.EncryptionKeyUpdated

  @type event ::
          EncryptionKeyCreated.t()
          | EncryptionKeyUpdated.t()
          | Commanded.Shredder.EncryptionKeyExpired.t()
          | Commanded.Shredder.EncryptionKeyDeleted.t()

  @spec apply(encryption_key :: t, event :: event) :: t
  def apply(
        %__MODULE__{} = encryption_key,
        %EncryptionKeyCreated{
          encryption_key_uuid: encryption_key_uuid,
          name: name,
          expiry: expiry
        }
      ),
      do: %{
        encryption_key
        | encryption_key_uuid: encryption_key_uuid,
          name: name,
          expiry: expiry
      }

  def apply(
        %__MODULE__{} = encryption_key,
        %EncryptionKeyCreated{expiry: expiry}
      ),
      do: %{
        encryption_key
        | expiry: expiry
      }

  def apply(%__MODULE__{} = encryption_key, _event),
    do: encryption_key
end
