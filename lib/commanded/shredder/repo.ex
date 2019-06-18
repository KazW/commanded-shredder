defmodule Commanded.Shredder.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :commanded_shredder,
    adapter: Ecto.Adapters.Postgres
end
