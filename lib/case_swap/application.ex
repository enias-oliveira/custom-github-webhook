defmodule CaseSwap.Application do
  @moduledoc false

  use Application

    def start(_type, _args) do
    children = [
        CaseSwap.Repo,
        { Oban, oban_config() }
    ]

    opts = [strategy: :one_for_one, name: CaseSwap.Supervisor]
    Supervisor.start_link(children, opts)
    end

  defp oban_config do
    Application.fetch_env!(:case_swap,Oban)
  end

end
