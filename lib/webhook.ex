defmodule Webhook do
  alias Webhook.GithubAPI

  def create_repository_webhook!(username, repository_name, target_url, time) do
    repository_full_name = username <> "/" <> repository_name

    with %{body: body, status: 200} <- GithubAPI.fetch_repository(repository_full_name) do
      payload = create_webhook_payload(body)

      %{payload: payload, target_url: target_url}
      |> Webhook.Worker.new(schedule_in: time)
      |> Oban.insert()
    end
  end

  defp create_webhook_payload(raw_data) do
    user = raw_data["owner"]["login"]
    repository = raw_data["name"]
    issues = get_issues(raw_data["full_name"])
    contributors = get_contributors(raw_data["full_name"])

    %{user: user, repository: repository, issues: issues, contributors: contributors}
  end

  defp get_issues(repository_full_name) do
    get_repository_resource(repository_full_name, "issues") |> parse_issues
  end

  defp get_repository_resource(repository_full_name, resource_name) do
    fetch_resource_page = fn page_number ->
      GithubAPI.fetch_repository_resource(repository_full_name, resource_name, page_number)
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
    contributor_name = GithubAPI.fetch_user_human_name(raw_contributor["login"])

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
      GithubAPI.fetch_repository_resource_by_user(
        repository_full_name,
        resource_name,
        page_number,
        username
      )
    end

    get_resource_recursion_aux(fetch_resource_page, [], 1)
  end
end
