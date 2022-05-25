defmodule Webhook.MixProject do
  use Mix.Project

  def project do
    [
      app: :webhook,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Webhook.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
    {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
    {:tesla, "~> 1.4"},
    {:hackney, "~> 1.17"},
    {:jason, ">= 1.0.0"},
    {:ecto_sql, "~> 3.0"},
    {:postgrex, ">= 0.0.0"},
    {:oban, "~> 2.10"},
    {:mox, "~> 1.0", only: :test},
    ]
  end
end
