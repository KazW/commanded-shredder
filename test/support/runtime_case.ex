defmodule Commanded.Shredder.RuntimeCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  alias Commanded.Scheduler.Repo, as: SchedulerRepo
  alias Commanded.Shredder.Repo, as: KeyRepo

  setup_all do
    scheduler_database_config = Application.get_env(:commanded_scheduler, SchedulerRepo)
    key_database_config = Application.get_env(:commanded_shredder, KeyRepo)

    Application.ensure_all_started(:postgrex)

    {:ok, key_conn} = Postgrex.start_link(key_database_config)
    {:ok, scheduler_conn} = Postgrex.start_link(scheduler_database_config)

    [key_conn: key_conn, scheduler_conn: scheduler_conn]
  end

  setup %{key_conn: key_conn, scheduler_conn: scheduler_conn} do
    reset_database!(key_conn, "encryption_keys")
    reset_database!(scheduler_conn, "schedules")

    {:ok, _} = Application.ensure_all_started(:commanded)
    {:ok, _} = Application.ensure_all_started(:commanded_scheduler)
    {:ok, _} = Application.ensure_all_started(:commanded_shredder)

    on_exit(fn ->
      Application.stop(:commanded_shredder)
      Application.stop(:commanded_scheduler)
      Application.stop(:commanded)
    end)

    :ok
  end

  defp reset_database!(conn, table) do
    Postgrex.query!(
      conn,
      """
        TRUNCATE TABLE
          projection_versions,
          #{table}
        RESTART IDENTITY;
      """,
      []
    )
  end
end
