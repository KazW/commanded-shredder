use Mix.Config

config :mix_test_watch,
  clear: true,
  tasks: [
    "test --no-start"
  ]

config :commanded_scheduler, Commanded.Scheduler.Repo,
  database: "commanded_scheduler_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :commanded_shredder, Commanded.Shredder.Repo,
  database: "commanded_shredder_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
