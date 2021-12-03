defmodule CaseSwap.RecurrentRunner do
  use GenServer

  @target_url "https://webhook.site/8b28f032-eef5-46f7-aa87-a3b9237d9768"

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  @impl true
  def init(state) do
    schedule_webhook()
    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    send_webhook(state)
    {:noreply, state}
  end

  defp schedule_webhook do
    Process.send_after(self(), :work, 30_000)
  end

  defp send_webhook(state) do
    CaseSwap.create_webhook_payload(state) |> CaseSwap.post_payload_to_webhook_url(@target_url)
  end
end
