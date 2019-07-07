defmodule Commanded.Shredder.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    [
      Commanded.Shredder.Repo,
      Commanded.Shredder.Projection
    ]
    |> Supervisor.start_link(
      strategy: :one_for_one,
      name: Commanded.Shredder.Supervisor
    )
  end
end
