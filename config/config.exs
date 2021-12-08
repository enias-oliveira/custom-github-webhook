import Config

config :case_swap, CaseSwap.Repo,
  database: "case_swap_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"

config :case_swap, ecto_repos: [CaseSwap.Repo]
