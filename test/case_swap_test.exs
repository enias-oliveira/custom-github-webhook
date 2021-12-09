defmodule CaseSwapTest do
  use ExUnit.Case
  use Oban.Testing, repo: CaseSwap.Repo
  doctest CaseSwap

  import Mox

  setup :verify_on_exit!

  test "get_repository/1" do

    CaseSwap.MockGithubAPI |> expect(:fetch_repository, fn _ -> %Tesla.Env{ status: 200, body: "batata" }  end)

    assert { :ok, body } = CaseSwap.get_repository("github_username/github_repo")
    assert body === "batata"
  end

  describe "create_repository_webhook_swap!/2" do
    test "jobs are enqueued with provided arguments" do
      assert "1" == "1"
    end

    test "jobs are enqueued with provided arguments again" do
      assert "2" == "2"
     end
  end
end
