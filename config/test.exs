use Mix.Config

config :logger, :console,
  level: :warn,
  format: "[$level] $message\n"

config :ex_unit,
  capture_log: true

config :commanded_scheduler, Commanded.Scheduler.Repo,
  database: "commanded_scheduler_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :commanded_shredder, Commanded.Shredder.Repo,
  database: "commanded_shredder_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :commanded, event_store_adapter: Commanded.EventStore.Adapters.InMemory

config :commanded, Commanded.EventStore.Adapters.InMemory,
  serializer: Commanded.Serialization.JsonSerializer
