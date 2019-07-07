defmodule Commanded.Shredder.Repo.Migrations.CreateEncryptionKeys do
  use Ecto.Migration

  def change do
    create table(:encryption_keys, primary_key: false) do
      add(:encryption_key_uuid, :text, primary_key: true)

      add(:key, :binary)
      add(:algorithm, :text)
      add(:key_options, :map)
      add(:name, :text)
      add(:expiry, :naive_datetime)

      timestamps()
    end
  end
end
