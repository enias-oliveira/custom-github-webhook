defmodule CaseSwap do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.github.com"
  plug Tesla.Middleware.Headers, [{"accept", "application/vnd.github.v3+json"}, { "user-agent", "Tesla" }, { "authorization", "token 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" }]
  plug Tesla.Middleware.JSON

  @target_url "https://webhook.site/8b28f032-eef5-46f7-aa87-a3b9237d9768"

  def create_repository_webhook(username, repository_name) do
    repository_full_name = username <> "/" <> repository_name

    get_repository(repository_full_name)
    |> create_webhook_payload()
    |> post_payload_to_webhook_url(@target_url)
  end

  defp get_repository(repository_full_name) do
    { _, response} = get("/repos/" <> repository_full_name)
    handle_repository_response response
  end

  defp handle_repository_response(response), do:
    if is_valid_repository(response), do: {:ok, response.body}, else: {:error, "Repository does not exist or not visible"}

  defp is_valid_repository(response), do: response.status == 200

  defp create_webhook_payload({_, raw_data}) do
    user = raw_data["owner"]["login"]
    repository = raw_data["name"]
    issues = get_issues(raw_data["full_name"])
    contributors = get_contributors(raw_data["full_name"])

    %{ user: user, repository: repository, issues: issues, contributors: contributors}
  end


  defp get_issues(repository_full_name) do
    get_repository_resource(repository_full_name, "issues") |> parse_issues
  end

  defp get_repository_resource(repository_full_name, resource_name) do
    fetch_resource_page = fn page_number -> fetch_repository_resource(repository_full_name, resource_name, page_number) end
    get_resource_recursion_aux(fetch_resource_page, [], 1)
    end

  defp fetch_repository_resource(repository_full_name, resource_name, page_number) do
    { _, response} =
      get("/repos/#{repository_full_name}/#{resource_name}?page=#{page_number}")
    response.body
  end

  defp get_resource_recursion_aux(fetch_resource_page, acc, page_number) do
    case fetch_resource_page.(page_number) do
       [] -> acc
      items -> get_resource_recursion_aux(fetch_resource_page, acc ++ items, page_number + 1)
    end
  end

  defp parse_issues(raw_issues), do: Enum.map(raw_issues, fn issue -> %{ title: issue["title"], author: issue["user"]["login"], labels: issue["labels"]} end)
  defp parse_contributors(raw_contributors, repository_full_name), do: Enum.map(raw_contributors, fn contributor -> %{ name: get_user_human_name(contributor["login"]), user: contributor["login"], qtd_commits: get_commits_count_by_user_in_repo(repository_full_name, contributor["login"])} end)

  defp get_contributors(repository_full_name) do
    get_repository_resource(repository_full_name, "contributors") |> parse_contributors(repository_full_name)
  end

  defp get_user_human_name(username) do
    { _, response} =
      get("/users/" <> username)
    name = response.body["name"]
    if name, do: name, else: "anonymous"
  end

  defp get_repository_resource_by_user(repository_full_name, resource_name, username) do
    fetch_resource_page = fn page_number -> fetch_repository_resource_by_user(repository_full_name, resource_name, page_number, username) end
    get_resource_recursion_aux(fetch_resource_page, [], 1)
  end

  defp fetch_repository_resource_by_user(repository_full_name, resource_name, page_number, username) do
    { _, response} =
      get("/repos/#{repository_full_name}/#{resource_name}?page=#{page_number}&author=#{username}")
    response.body
  end

  defp get_commits_count_by_user_in_repo(repository_full_name, username) do
    get_repository_resource_by_user(repository_full_name, "commits", username)  |> length()
  end

  defp post_payload_to_webhook_url(payload, target_url) do
    post(target_url, payload)
  end

end
