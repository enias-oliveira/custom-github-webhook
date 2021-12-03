defmodule CaseSwap.Github do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.github.com"
  plug Tesla.Middleware.Headers, [{"accept", "application/vnd.github.v3+json"}, { "user-agent", "Tesla" }, { "authorization", "token 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" }]
  plug Tesla.Middleware.JSON

  def fetch_repository(repository_full_name) do
    { _, response} = get("/repos/" <> repository_full_name)
    response
  end

  def fetch_repository_resource(repository_full_name, resource_name, page_number) do
    { _, response} =
      get("/repos/#{repository_full_name}/#{resource_name}?page=#{page_number}")
    response.body
  end

  def fetch_user_human_name(username) do
    { _, response} =
      get("/users/" <> username)
    name = response.body["name"]
    if name, do: name, else: "anonymous"
  end

  def fetch_repository_resource_by_user(repository_full_name, resource_name, page_number, username) do
    { _, response} =
      get("/repos/#{repository_full_name}/#{resource_name}?page=#{page_number}&author=#{username}")
    response.body
  end

  def post_payload_to_webhook_url(payload, target_url) do
    post(target_url, payload)
  end
end
