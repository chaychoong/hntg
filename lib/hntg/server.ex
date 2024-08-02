defmodule Hntg.Server do
  use GenServer
  require Logger

  @initial_offset 0
  @poll_interval 0

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    state = %{offset: @initial_offset}

    case Telegram.Client.get_me() do
      {:ok, %{"username" => botname}} ->
        Logger.info("Connected to Telegram as #{botname}")
        schedule_poll()
        {:ok, state}

      {:error, req} ->
        Logger.error("Failed to connect to Telegram: #{inspect(req)}")
        :error
    end
  end

  @impl true
  def handle_info(:poll, state) do
    Logger.info("Polling for updates on offset #{state.offset}")

    state =
      case Telegram.Client.get_updates(state.offset) do
        {:ok, updates} ->
          Logger.info("Received updates: #{inspect(updates)}")
          %{offset: state.offset}

        :timeout ->
          state
      end

    schedule_poll()
    {:noreply, state}
  end

  defp schedule_poll do
    Process.send_after(self(), :poll, @poll_interval)
  end
end
