defmodule CaseSwap.Github do
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://api.github.com")

  plug(Tesla.Middleware.Headers, [
    {"accept", "application/vnd.github.v3+json"},
    {"user-agent", "Tesla"},
    {"authorization", "token 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"}
  ])

  plug(Tesla.Middleware.JSON)

  def fetch_repository(repository_full_name) do
    {_, response} = get("/repos/" <> repository_full_name)
    response
  end

  def fetch_repository_resource(repository_full_name, resource_name, page_number) do
    {_, response} =
      get("/repos/#{repository_full_name}/#{resource_name}?page=#{page_number}&per_page=100")

    response.body
  end

  def fetch_user_human_name(username) do
    case get("/users/#{username}") do
      {_, :invalid_uri} -> "anonymous"
      {_, response} -> Map.get(response.body, "name", "anonymous")
    end
  end

  def fetch_repository_resource_by_user(
        repository_full_name,
        resource_name,
        page_number,
        username
      ) do
    case get(
           "/repos/#{repository_full_name}/#{resource_name}?page=#{page_number}&author=#{username}&per_page=100"
         ) do
      {_, :invalid_uri} -> []
      {_, response} -> response.body
    end
  end

  def post_payload_to_webhook_url(payload, target_url) do
    post(target_url, payload)
  end
end

defmodule CaseSwap.GithubAPI do
  @callback fetch_repository(String.t()) ::  { :ok, String.t() }

  def fetch_repository(repository_full_name), do: impl().fetch_repository(repository_full_name)

  defp impl, do: Application.get_env(:case_swap, :github, CaseSwap.Github)
end
