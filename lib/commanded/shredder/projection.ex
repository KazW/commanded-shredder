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
      field(:name, :string, primary_key: true)

      field(:key, :binary)
      field(:key_type, :string)
      field(:key_options, :map)
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

  project(%EncryptionKeyCreated{} = created, fn multi ->
    %EncryptionKeyCreated{
      encryption_key_uuid: encryption_key_uuid,
      name: name,
      expiry: expiry
    } = created

    encryption_key = %EncryptionKey{
      encryption_key_uuid: encryption_key_uuid,
      name: name,
      key: :crypto.strong_rand_bytes(32),
      key_type: "AES256GCM",
      expiry: truncate_expiry(expiry)
    }

    Ecto.Multi.insert(multi, :create_key, encryption_key)
  end)

  project(%EncryptionKeyUpdated{} = updated, fn multi ->
    %EncryptionKeyUpdated{
      encryption_key_uuid: encryption_key_uuid,
      name: name,
      expiry: expiry
    } = updated

    Ecto.Multi.update(
      multi,
      :update_key,
      Ecto.Changeset.change(
        encryption_key_uuid |> encryption_key_query(name) |> Repo.one!(),
        %{expiry: truncate_expiry(expiry)}
      )
    )
  end)

  project(
    %EncryptionKeyDeleted{encryption_key_uuid: encryption_key_uuid, name: name},
    &delete_key(&1, name, encryption_key_uuid)
  )

  project(
    %EncryptionKeyExpired{encryption_key_uuid: encryption_key_uuid, name: name},
    &delete_key(&1, name, encryption_key_uuid)
  )

  defp truncate_expiry(nil), do: nil

  defp truncate_expiry(%NaiveDateTime{} = expiry),
    do: NaiveDateTime.truncate(expiry, :second)

  defp delete_key(multi, name, encryption_key_uuid),
    do:
      Ecto.Multi.delete_all(
        multi,
        :delete_key,
        encryption_key_query(encryption_key_uuid, name)
      )

  defp encryption_key_query(encryption_key_uuid, name),
    do:
      from(
        key in EncryptionKey,
        where: key.encryption_key_uuid == ^encryption_key_uuid,
        where: key.name == ^name
      )
end
