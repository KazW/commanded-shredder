defmodule Commanded.Shredder.Repo.Migrations.CreateProjectionVersions do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:projection_versions, primary_key: false) do
      add(:projection_name, :text, primary_key: true)
      add(:last_seen_event_number, :bigint)

      timestamps()
    end
  end
end
