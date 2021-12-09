defmodule CaseSwap do
  alias CaseSwap.Github
  alias CaseSwap.GithubAPI

  @swap_url "https://webhook.site/8b28f032-eef5-46f7-aa87-a3b9237d9768"

  def create_repository_webhook!(username, repository_name, target_url, time) do
    repository_full_name = username <> "/" <> repository_name

    get_repository(repository_full_name)
    |> create_webhook_payload(target_url)
    |> CaseSwap.Worker.new(schedule_in: time)
    |> Oban.insert()
  end

  def create_repository_webhook_swap!(username, repository_name) do
    create_repository_webhook!(username, repository_name, @swap_url, {1, :days})
  end

  def get_repository(repository_full_name) do
    GithubAPI.fetch_repository(repository_full_name) |> handle_repository_response()
  end

  defp handle_repository_response(response),
    do:
      if(is_valid_repository(response),
        do: {:ok, response.body},
        else: raise("Repository does not exist or not visible")
      )

  defp is_valid_repository(response), do: response.status == 200

  def create_webhook_payload({_, raw_data}, target_url) do
    user = raw_data["owner"]["login"]
    repository = raw_data["name"]
    issues = get_issues(raw_data["full_name"])
    contributors = get_contributors(raw_data["full_name"])

    %{
      payload: %{user: user, repository: repository, issues: issues, contributors: contributors},
      target_url: target_url
    }
  end

  defp get_issues(repository_full_name) do
    get_repository_resource(repository_full_name, "issues") |> parse_issues
  end

  defp get_repository_resource(repository_full_name, resource_name) do
    fetch_resource_page = fn page_number ->
      Github.fetch_repository_resource(repository_full_name, resource_name, page_number)
    end

    get_resource_recursion_aux(fetch_resource_page, [], 1)
  end

  defp get_resource_recursion_aux(fetch_resource_page, acc, page_number) do
    case fetch_resource_page.(page_number) do
      [] -> acc
      items -> get_resource_recursion_aux(fetch_resource_page, acc ++ items, page_number + 1)
    end
  end

  defp parse_issues(raw_issues),
    do:
      Enum.map(raw_issues, fn issue ->
        %{title: issue["title"], author: issue["user"]["login"], labels: issue["labels"]}
      end)

  defp get_contributors(repository_full_name) do
    get_repository_resource(repository_full_name, "contributors")
    |> parse_contributors(repository_full_name)
  end

  defp parse_contributors(raw_contributors, repository_full_name),
    do:
      Enum.map(raw_contributors, fn raw_contributor ->
        parse_contributor(raw_contributor, repository_full_name)
      end)

  defp parse_contributor(raw_contributor, repository_full_name) do
    contributor_name = Github.fetch_user_human_name(raw_contributor["login"])

    contributor_commits_count =
      get_commits_count_by_user_in_repo(repository_full_name, raw_contributor["login"])

    %{
      name: contributor_name,
      user: raw_contributor["login"],
      qtd_commits: contributor_commits_count
    }
  end

  defp get_commits_count_by_user_in_repo(repository_full_name, username) do
    get_repository_resource_by_user(repository_full_name, "commits", username) |> length()
  end

  defp get_repository_resource_by_user(repository_full_name, resource_name, username) do
    fetch_resource_page = fn page_number ->
      Github.fetch_repository_resource_by_user(
        repository_full_name,
        resource_name,
        page_number,
        username
      )
    end

    get_resource_recursion_aux(fetch_resource_page, [], 1)
  end
end
