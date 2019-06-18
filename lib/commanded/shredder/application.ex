defmodule Commanded.Shredder.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      Commanded.Shredder.Repo,
      Commanded.Shredder.Projection
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Commanded.Shredder.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
