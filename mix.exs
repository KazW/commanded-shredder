defmodule Commanded.Shredder.Mixfile do
  use Mix.Project

  @version "0.0.1"

  def project do
    [
      app: :commanded_shredder,
      version: @version,
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      description: description(),
      docs: docs(),
      package: package(),
      name: "Commanded Shredder",
      source_url: "https://github.com/KazW/commanded-shredder"
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {Commanded.Shredder.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: [
        "ecto.drop --quiet -r Commanded.Scheduler.Repo",
        "ecto.drop --quiet -r Commanded.Shredder.Repo",
        "ecto.create --quiet -r Commanded.Scheduler.Repo",
        "ecto.create --quiet -r Commanded.Shredder.Repo",
        "ecto.migrate --quiet -r Commanded.Scheduler.Repo",
        "ecto.migrate --quiet -r Commanded.Shredder.Repo",
        "test --no-start"
      ],
      "test.watch": ["test.watch --no-start"]
    ]
  end

  defp deps do
    [
      {:commanded, ">= 0.18.0", runtime: false},
      {:commanded_ecto_projections, ">= 0.8.0"},
      {:commanded_scheduler, ">= 0.2.0"},
      {:crontab, "~> 1.1"},
      {:ecto, "~> 3.1"},
      {:elixir_uuid, "~> 1.2"},
      {:ex2ms, "~> 1.5"},
      {:postgrex, ">= 0.0.0"},
      {:timex, "~> 3.5"},

      # Optional dependencies
      {:jason, "~> 1.1", optional: true},

      # Build & test tools
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:mix_test_watch, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    A data shredder for the Commanded framework in Elixir, enables the storage
    of personal information while maintaining good data privacy practices.
    """
  end

  defp docs do
    [
      main: "Commanded.Shredder",
      canonical: "http://hexdocs.pm/commanded_shredder",
      source_ref: "v#{@version}",
      extra_section: "GUIDES",
      extras: [
        "guides/Getting Started.md",
        "guides/Usage.md",
        "guides/Testing.md",
        "CHANGELOG.md"
      ]
    ]
  end

  defp package do
    [
      files: [
        "lib",
        "priv",
        "mix.exs",
        "README*",
        "LICENSE*",
        "CHANGELOG*"
      ],
      maintainers: ["Kaz Walker"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/KazW/commanded-shredder",
        "Docs" => "https://hexdocs.pm/commanded_shredder/"
      }
    ]
  end
end
