defmodule Commanded.Shredder.CommandHandler.DefaultImpl do
  @behaviour Commanded.Shredder.CommandHandler.Impl

  alias Commanded.Scheduler.Router, as: ScheduleRouter

  alias Commanded.Shredder.EncryptionKey

  alias Commanded.Shredder.CreateEncryptionKey
  alias Commanded.Shredder.UpdateEncryptionKey
  alias Commanded.Shredder.ExpireEncryptionKey
  alias Commanded.Shredder.DeleteEncryptionKey

  alias Commanded.Shredder.EncryptionKeyCreated
  alias Commanded.Shredder.EncryptionKeyUpdated
  alias Commanded.Shredder.EncryptionKeyExpired
  alias Commanded.Shredder.EncryptionKeyDeleted

  @type error :: {:error, String.t()}

  @missing_key "encryption_key_not_found"

  @spec create_encryption_key(
          encryption_key :: EncryptionKey.t(),
          create_command :: CreateEncryptionKey.t()
        ) :: [EncryptionKeyCreated.t()] | error
  def create_encryption_key(
        %EncryptionKey{encryption_key_uuid: nil},
        %CreateEncryptionKey{
          encryption_key_uuid: encryption_key_uuid,
          name: name,
          algorithm: algorithm,
          expiry: expiry
        }
      ) do
    with :ok <- validate_expiry(expiry), :ok <- validate_algorithm(algorithm) do
      if %NaiveDateTime{} = expiry do
        create_expiry_schedule(expiry, encryption_key_uuid)
      end

      [
        %EncryptionKeyCreated{
          encryption_key_uuid: encryption_key_uuid,
          name: name,
          algorithm: algorithm || default_algorithm(),
          expiry: truncate(expiry)
        }
      ]
    end
  end

  def create_encryption_key(%EncryptionKey{}, %CreateEncryptionKey{}),
    do: {:error, "encryption_key_already_created"}

  @spec update_encryption_key(
          encryption_key :: EncryptionKey.t(),
          update_command :: UpdateEncryptionKey.t()
        ) :: [EncryptionKeyUpdated.t()] | error
  def update_encryption_key(
        %EncryptionKey{encryption_key_uuid: nil},
        %UpdateEncryptionKey{}
      ),
      do: no_encryption_key()

  def update_encryption_key(
        %EncryptionKey{
          encryption_key_uuid: encryption_key_uuid,
          expiry: old_expiry
        },
        %UpdateEncryptionKey{
          name: name,
          expiry: expiry
        }
      ) do
    with :ok <- validate_expiry(expiry) do
      if(old_expiry or is_nil(expiry), do: cancel_expiry_schedule(encryption_key_uuid))

      if %NaiveDateTime{} = expiry do
        create_expiry_schedule(expiry, encryption_key_uuid)
      end

      [
        %EncryptionKeyUpdated{
          encryption_key_uuid: encryption_key_uuid,
          name: name,
          expiry: if(expiry, do: truncate(expiry))
        }
      ]
    end
  end

  @spec expire_encryption_key(
          encryption_key :: EncryptionKey.t(),
          expire_command :: ExpireEncryptionKey.t()
        ) :: [EncryptionKeyExpired.t()] | error
  def expire_encryption_key(
        %EncryptionKey{encryption_key_uuid: nil},
        %ExpireEncryptionKey{}
      ),
      do: no_encryption_key()

  def expire_encryption_key(
        %EncryptionKey{
          encryption_key_uuid: encryption_key_uuid,
          name: name
        },
        %ExpireEncryptionKey{}
      ),
      do: [
        %EncryptionKeyExpired{
          encryption_key_uuid: encryption_key_uuid,
          name: name
        }
      ]

  @spec delete_encryption_key(
          encryption_key :: EncryptionKey.t(),
          delete_command :: DeleteEncryptionKey.t()
        ) :: [EncryptionKeyDeleted.t()] | error
  def delete_encryption_key(
        %EncryptionKey{encryption_key_uuid: nil},
        %DeleteEncryptionKey{}
      ),
      do: no_encryption_key()

  def delete_encryption_key(
        %EncryptionKey{
          encryption_key_uuid: encryption_key_uuid,
          name: name
        },
        %DeleteEncryptionKey{}
      ),
      do: [
        %EncryptionKeyDeleted{
          encryption_key_uuid: encryption_key_uuid,
          name: name
        }
      ]

  defp validate_expiry(nil), do: :ok

  defp validate_expiry(%NaiveDateTime{} = expiry) do
    case NaiveDateTime.compare(now(), truncate(expiry)) do
      :lt -> :ok
      _ -> {:error, "expiry_passed"}
    end
  end

  defp validate_algorithm(nil), do: :ok

  defp validate_algorithm(algorithm) do
    if algorithm in supported_algorithms() do
      :ok
    else
      {:error, "unsupported_algorithm"}
    end
  end

  defp crypto_module,
    do: Commanded.Shredder.CryptoImpl.crypto_module()

  defp default_algorithm,
    do: crypto_module().default_algorithm()

  defp supported_algorithms,
    do: crypto_module().supported_algorithms()

  defp no_encryption_key, do: {:error, @missing_key}
  defp now, do: NaiveDateTime.utc_now() |> truncate()
  defp truncate(nil), do: nil
  defp truncate(expiry), do: NaiveDateTime.truncate(expiry, :second)

  defp expiry_schedule_prefix,
    do:
      Application.get_env(
        :commanded_shredder,
        :expiry_schedule_prefix,
        "encryption_key_expiry:"
      )

  defp cancel_expiry_schedule(encryption_key_uuid),
    do:
      %Commanded.Scheduler.CancelSchedule{
        schedule_uuid: expiry_schedule_prefix() <> encryption_key_uuid
      }
      |> ScheduleRouter.dispatch(consistency: :strong)

  defp create_expiry_schedule(%NaiveDateTime{} = expiry, encryption_key_uuid),
    do:
      Commanded.Scheduler.schedule_once(
        expiry_schedule_prefix() <> encryption_key_uuid,
        %ExpireEncryptionKey{encryption_key_uuid: encryption_key_uuid},
        truncate(expiry)
      )
end
