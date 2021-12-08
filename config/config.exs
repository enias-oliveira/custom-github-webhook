import Config

config :case_swap, CaseSwap.Repo,
  database: "case_swap_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"

config :case_swap, ecto_repos: [CaseSwap.Repo]

config :case_swap, Oban,
  repo: CaseSwap.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10, events: 50, media: 20]
