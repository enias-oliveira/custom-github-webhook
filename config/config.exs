import Config

config :case_swap, CaseSwap.Repo,
  database: System.get_env("DATABASE"),
  username: System.get_env("USERNAME"),
  password: System.get_env("PASSWORD"),
  hostname: System.get_env("HOSTNAME")

config :case_swap, ecto_repos: [CaseSwap.Repo]

config :case_swap, Oban,
  repo: CaseSwap.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10, events: 50, media: 20]
