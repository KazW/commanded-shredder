use Mix.Config

config :commanded_shredder,
  ecto_repos: [
    Commanded.Scheduler.Repo,
    Commanded.Shredder.Repo
  ]

config :commanded_scheduler,
  router: Commanded.Shredder.Router

import_config "#{Mix.env()}.exs"
