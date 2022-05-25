defmodule Webhook.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Webhook.Repo,
      {Oban, oban_config()}
    ]

    opts = [strategy: :one_for_one, name: Webhook.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp oban_config do
    Application.fetch_env!(:webhook, Oban)
  end
end
