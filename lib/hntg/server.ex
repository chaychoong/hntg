defmodule Hntg.Server do
  @moduledoc """
  A GenServer for handling Telegram updates and processing Hacker News links.
  """

  use GenServer
  require Logger

  @initial_offset 0
  @poll_interval 0

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl GenServer
  def init(:ok) do
    with {:ok, %{"username" => botname}} <- Telegram.Client.get_me() do
      Logger.info("Connected to Telegram as #{botname}")
      schedule_poll()
      {:ok, %{offset: @initial_offset}}
    else
      {:error, req} ->
        {:stop, "Failed to connect to Telegram: #{inspect(req)}"}
    end
  end

  @impl GenServer
  def handle_info(:poll, %{offset: offset} = state) do
    Logger.debug("Polling for updates on offset #{offset}")

    new_offset =
      case Telegram.Client.get_updates(offset) do
        {:ok, updates} ->
          Enum.reduce(updates, 0, fn update, _acc -> process_update(update) end)

        {:error, :timeout} ->
          offset
      end

    schedule_poll()
    {:noreply, %{state | offset: new_offset}}
  end

  defp process_update(%{text: text, chat_id: chat_id, offset: offset}) do
    case Hn.Client.process_link(text) do
      {:ok, reply} ->
        send_telegram_message(chat_id, reply)

      {:error, reason} ->
        send_telegram_message(chat_id, "Error: #{reason}")
    end

    offset + 1
  end

  defp send_telegram_message(chat_id, message) do
    case Telegram.Client.send_message(chat_id, message) do
      {:ok, _} -> :ok
      {:error, reason} -> Logger.warning("Failed to send message: #{inspect(reason)}")
    end
  end

  defp schedule_poll do
    Process.send_after(self(), :poll, @poll_interval)
  end
end
