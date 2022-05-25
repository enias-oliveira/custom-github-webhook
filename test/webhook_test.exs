defmodule WebhookTest do
  use ExUnit.Case
  use Oban.Testing, repo: Webhook.Repo
  doctest Webhook

  import Mox

  setup :verify_on_exit!

  describe "create_repository_webhook!/2" do
    test "standard implementation with correct params" do
      fetch_repository_response = %Tesla.Env{
        status: 200,
        body: %{
          "owner" => %{
            "login" => "github_mock_username"
          },
          "name" => "github_mock_repo",
          "fullname" => "github_mock_username/github_mock_repo"
        }
      }

      fetch_repository_issues_page_1_response = [
        %{
          "title" => "Usage with acceptance/feature tests",
          "owner" => %{
            "login" => "other_github_mock_username"
          },
          "labels" => [
            %{
              "id" => 702_104_002,
              "node_id" => "MDU6TGFiZWw3MDIxMDQwMDI=",
              "url" => "https=>//api.github.com/repos/dashbitco/mox/labels/discussion",
              "name" => "discussion",
              "color" => "e6e6e6",
              "default" => false,
              "description" => nil
            }
          ]
        }
      ]

      fetch_repository_issues_page_2_response = [
        %{
          "title" => "Should we support mocking modules without behaviour?",
          "owner" => %{
            "login" => "other_other_github_mock_username"
          },
          "labels" => []
        }
      ]

      fetch_repository_contributors_page_1_response = [
        %{
          "login" => "josevalim"
        },
        %{
          "login" => "enias"
        }
      ]

      Webhook.MockGithubAPI
      |> expect(:fetch_repository, fn _ -> fetch_repository_response end)
      |> expect(:fetch_repository_resource, 5, fn
        _, "issues", 1 ->
          fetch_repository_issues_page_1_response

        _, "issues", 2 ->
          fetch_repository_issues_page_2_response

        _, "issues", 3 ->
          []

        _, "contributors", 1 ->
          fetch_repository_contributors_page_1_response

        _, "contributors", 2 ->
          []
      end)
      |> expect(:fetch_user_human_name, 2, fn username -> "#{username} HUMAN NAME" end)
      |> expect(:fetch_repository_resource_by_user, 4, fn
        _, "commits", 1, _ -> [1, 2, 3, 5, 6]
        _, "commits", 2, _ -> []
      end)

      username = "mock_github_user"
      repository_name = "mock_github_repo"
      target_url = "https://mock_webhook_target.site/"

      assert {:ok, _} =
               Webhook.create_repository_webhook!(
                 username,
                 repository_name,
                 target_url,
                 {1, :days}
               )

      day_in_seconds = 60 * 60 * 24
      in_an_day = DateTime.add(DateTime.utc_now(), day_in_seconds, :second)

      assert_enqueued(
        worker: Webhook.Worker,
        args: %{
          "payload" => %{
            "contributors" => [
              %{
                "name" => "josevalim HUMAN NAME",
                "qtd_commits" => 5,
                "user" => "josevalim"
              },
              %{"name" => "enias HUMAN NAME", "qtd_commits" => 5, "user" => "enias"}
            ],
            "issues" => [
              %{
                "author" => nil,
                "labels" => [
                  %{
                    "color" => "e6e6e6",
                    "default" => false,
                    "description" => nil,
                    "id" => 702_104_002,
                    "name" => "discussion",
                    "node_id" => "MDU6TGFiZWw3MDIxMDQwMDI=",
                    "url" => "https=>//api.github.com/repos/dashbitco/mox/labels/discussion"
                  }
                ],
                "title" => "Usage with acceptance/feature tests"
              },
              %{
                "author" => nil,
                "labels" => [],
                "title" => "Should we support mocking modules without behaviour?"
              }
            ],
            "repository" => "github_mock_repo",
            "user" => "github_mock_username"
          },
          "target_url" => "https://mock_webhook_target.site/"
        },
        scheduled_at: in_an_day,
        state: "scheduled"
      )
    end

    test "invalid username or repository name" do
      fetch_repository_response = %Tesla.Env{
        status: 404,
        body: %{
          "message" => "Not Found"
        }
      }

      Webhook.MockGithubAPI
      |> expect(:fetch_repository, fn _ -> fetch_repository_response end)

      assert_raise RuntimeError, "Repository does not exist or not visible", fn ->
        username = "mock_github_user"
        repository_name = "mock_github_repo"
        target_url = "https://mock_webhook_target.site/"

        Webhook.create_repository_webhook!(
          username,
          repository_name,
          target_url,
          {1, :days}
        )
      end
    end
  end
end
