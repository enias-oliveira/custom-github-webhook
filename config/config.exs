import Config

config :webhook, Webhook.Repo,
  database: System.get_env("PGDATABASE"),
  username: System.get_env("PGUSERNAME"),
  password: System.get_env("PGPASSWORD"),
  hostname: System.get_env("PGHOSTNAME"),
  port: System.get_env("PGPORT")

config :webhook, ecto_repos: [Webhook.Repo]

config :webhook, Oban,
  repo: Webhook.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10, events: 50, media: 20]

config :webhook, Webhook.Github,
  github_authorization_token: System.get_env("GITHUB_AUTHORIZATION_TOKEN")

import_config "#{config_env()}.exs"
