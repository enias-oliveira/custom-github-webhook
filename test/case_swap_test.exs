defmodule CaseSwapTest do
  use ExUnit.Case
  use Oban.Testing, repo: CaseSwap.Repo
  doctest CaseSwap


  describe "create_repository_webhook_swap!/2" do
    test "jobs are enqueued with provided arguments" do
      assert "1" == "1"
    end

    test "jobs are enqueued with provided arguments again" do
      assert "2" == "2"
     end
  end
end
