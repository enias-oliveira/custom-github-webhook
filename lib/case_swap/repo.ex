defmodule CaseSwap.Repo do
  use Ecto.Repo,
    otp_app: :case_swap,
    adapter: Ecto.Adapters.Postgres
end
