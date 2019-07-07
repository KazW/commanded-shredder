defmodule Commanded.Shredder.Projection do
  @moduledoc false
  use Commanded.Projections.Ecto,
    name: "Commanded.Shredder.Projection",
    repo: Commanded.Shredder.Repo,
    consistency: :strong

  defmodule EncryptionKey do
    @moduledoc false
    use Ecto.Schema

    @primary_key false
    schema "encryption_keys" do
      field(:encryption_key_uuid, :string, primary_key: true)

      field(:key, :binary)
      field(:algorithm, :string)
      field(:key_options, :map)
      field(:name, :string)
      field(:expiry, :naive_datetime)

      timestamps()
    end
  end

  alias Commanded.Shredder.EncryptionKeyCreated
  alias Commanded.Shredder.EncryptionKeyUpdated
  alias Commanded.Shredder.EncryptionKeyDeleted
  alias Commanded.Shredder.EncryptionKeyExpired
  alias Commanded.Shredder.Repo
  alias Commanded.Shredder.Projection.EncryptionKey

  project(
    %EncryptionKeyCreated{} = created,
    &create_key(&1, created)
  )

  project(
    %EncryptionKeyUpdated{} = updated,
    &update_key(&1, updated)
  )

  project(
    %EncryptionKeyDeleted{encryption_key_uuid: encryption_key_uuid},
    &delete_key(&1, encryption_key_uuid)
  )

  project(
    %EncryptionKeyExpired{encryption_key_uuid: encryption_key_uuid},
    &delete_key(&1, encryption_key_uuid)
  )

  defp encryption_key_query(encryption_key_uuid),
    do:
      from(
        key in EncryptionKey,
        where: key.encryption_key_uuid == ^encryption_key_uuid
      )

  defp create_key(multi, %EncryptionKeyCreated{
         encryption_key_uuid: encryption_key_uuid,
         name: name,
         algorithm: algorithm,
         expiry: expiry
       }),
       do:
         Ecto.Multi.insert(
           multi,
           :create_key,
           %EncryptionKey{
             encryption_key_uuid: encryption_key_uuid,
             name: name,
             key: crypto_module().generate_key(algorithm),
             algorithm: algorithm,
             expiry: truncate_expiry(expiry)
           }
         )

  defp update_key(multi, %EncryptionKeyUpdated{
         encryption_key_uuid: encryption_key_uuid,
         name: name,
         expiry: expiry
       }),
       do:
         Ecto.Multi.update(
           multi,
           :update_key,
           Ecto.Changeset.change(
             encryption_key_query(encryption_key_uuid) |> Repo.one!(),
             %{
               name: name,
               expiry: truncate_expiry(expiry)
             }
           )
         )

  defp delete_key(multi, encryption_key_uuid),
    do:
      Ecto.Multi.delete_all(
        multi,
        :delete_key,
        encryption_key_query(encryption_key_uuid)
      )

  defp truncate_expiry(nil), do: nil

  defp truncate_expiry(%NaiveDateTime{} = expiry),
    do: NaiveDateTime.truncate(expiry, :second)

  defp crypto_module,
    do: Commanded.Shredder.CryptoImpl.crypto_module()
end
