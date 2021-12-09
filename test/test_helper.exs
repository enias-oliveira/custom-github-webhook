Mox.defmock(CaseSwap.MockGithubAPI, for: CaseSwap.GithubAPI)
Application.put_env(:case_swap, :github, CaseSwap.MockGithubAPI)

ExUnit.start()
