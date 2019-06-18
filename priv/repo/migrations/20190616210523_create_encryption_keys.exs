defmodule Commanded.Shredder.Repo.Migrations.CreateEncryptionKeys do
  use Ecto.Migration

  def change do
    create table(:encryption_keys, primary_key: false) do
      add(:encryption_key_uuid, :text, primary_key: true)
      add(:name, :text, primary_key: true)

      add(:key, :binary)
      add(:key_type, :text)
      add(:key_options, :map)
      add(:expiry, :naive_datetime)

      timestamps()
    end
  end
end
