defmodule CaseSwap.Application do
  @moduledoc false

  use Application

    def start(_type, _args) do
    children = [
        CaseSwap.Repo,
    ]

    opts = [strategy: :one_for_one, name: CaseSwap.Supervisor]
    Supervisor.start_link(children, opts)
    end
end
