defmodule Webhook.Github do
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

defmodule Webhook.GithubAPI do
  @callback fetch_repository(String.t()) :: Tesla.Env.t()
  @callback fetch_repository_resource(String.t(), String.t(), integer()) :: Tesla.Env.body()
  @callback fetch_user_human_name(String.t()) :: String.t()
  @callback fetch_repository_resource_by_user(String.t(), String.t(), integer(), String.t()) ::
              list()

  @type label :: %{
          color: String.t(),
          default: boolean(),
          description: String.t(),
          id: integer(),
          name: String.t(),
          node_id: String.t(),
          url: String.t()
        }
  @type issue :: %{title: String.t(), author: String.t(), labels: label()}
  @type contributor :: %{name: String.t(), qtd_commits: integer(), user: String.t()}
  @type repository_payload :: %{
          payload: %{
            user: String.t(),
            repository: String.t(),
            issues: list(issue()),
            contributors: list(contributor())
          }
        }

  @callback post_payload_to_webhook_url(repository_payload()) :: Tesla.Env.result()

  def fetch_repository(repository_full_name), do: impl().fetch_repository(repository_full_name)

  def fetch_repository_resource(repository_full_name, resource_name, page_number),
    do: impl().fetch_repository_resource(repository_full_name, resource_name, page_number)

  def fetch_user_human_name(username), do: impl().fetch_user_human_name(username)

  def fetch_repository_resource_by_user(
        repository_full_name,
        resource_name,
        page_number,
        username
      ),
      do:
        impl().fetch_repository_resource_by_user(
          repository_full_name,
          resource_name,
          page_number,
          username
        )

  def post_payload_to_webhook_url(payload, target_url),
    do: impl().post_payload_to_webhook_url(payload, target_url)

  defp impl, do: Application.get_env(:webhook, :github, Webhook.Github)
end
