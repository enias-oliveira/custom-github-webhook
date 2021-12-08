defmodule CaseSwap.Worker do
  use Oban.Worker, queue: :events

  alias CaseSwap.Github

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{} = args}) do
    %{ "payload" => payload, "target_url" => target_url } = args
    Github.post(target_url, payload)

    :ok
  end
end
