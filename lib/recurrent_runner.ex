defmodule CaseSwap.RecurrentRunner do
  use GenServer

  def start_link(repository, webhook_info) do
    GenServer.start_link(__MODULE__, { repository, webhook_info })
  end

  @impl true
  def init(state) do
    schedule_webhook(state)
    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    send_webhook(state)
    exit(:normal)
    {:noreply, state}
  end

  defp schedule_webhook({_, webhook_info} ) do
    { _, time } = webhook_info
    Process.send_after(self(), :work, time)
  end

  defp send_webhook({ repository, webhook_info }) do
    { target_url, _ } = webhook_info
    CaseSwap.create_webhook_payload(repository) |> CaseSwap.Github.post_payload_to_webhook_url(target_url)
  end
end
