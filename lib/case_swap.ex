defmodule CaseSwap do
  use Tesla

  def create_repository_webhook(username, repository) do
    create_github_repository_url(username, repository) |> Tesla.get()
  end

  defp create_github_repository_url(username, repository) do
    github_api_base_url = "https://api.github.com"
    "#{github_api_base_url}/#{username}/#{repository}"
  end
end
