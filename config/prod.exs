use Mix.Config

config :commanded_scheduler, Commanded.Scheduler.Repo,
  database: "commanded_scheduler_prod",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :commanded_shredder, Commanded.Shredder.Repo,
  database: "commanded_shredder_prod",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
