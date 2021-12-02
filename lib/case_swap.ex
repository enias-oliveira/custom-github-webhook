defmodule CaseSwap do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.github.com"
  plug Tesla.Middleware.Headers, [{"accept", "application/vnd.github.v3+json"}, { "user-agent", "Tesla" }]
  plug Tesla.Middleware.JSON

  def create_repository_webhook(username, repository_name) do
    is_valid_repository(username, repository_name)
  end

  defp is_valid_repository(username, repository_name) do
      { _, response} = get_repository(username, repository_name)
      response.status == 200
  end

  defp get_repository(username, repository_name) do
    get("/repos/#{ username }/#{ repository_name }")
  end



end
