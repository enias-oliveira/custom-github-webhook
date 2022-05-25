Mox.defmock(Webhook.MockGithubAPI, for: Webhook.GithubAPI)
Application.put_env(:webhook, :github, Webhook.MockGithubAPI)

ExUnit.start()
