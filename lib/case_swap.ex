defmodule CaseSwap do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.github.com"
  plug Tesla.Middleware.Headers, [{"accept", "application/vnd.github.v3+json"}, { "user-agent", "Tesla" }]
  plug Tesla.Middleware.JSON

  def create_repository_webhook(username, repository_name) do
    repository_full_name = username <> "/" <> repository_name
    get_repository(repository_full_name) |> create_webhook_payload()
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
    # contributors = get_contributors(raw_data["full_name"])

    %{ user: user, repository: repository, issues: issues}
  end
end
