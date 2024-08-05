defmodule Hntg.Server do
  @moduledoc """
  A GenServer for handling Telegram updates and processing Hacker News links.
  """

  use GenServer
  require Logger

  @initial_offset 0
  @poll_interval 0

  def start_link(_opts) do
    if server_enabled?() do
      GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
    else
      :ignore
    end
  end

  @impl GenServer
  def init(:ok) do
    with {:ok, botname} <- Telegram.Client.get_bot_name() do
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
    new_offset =
      case Telegram.Client.process_updates(offset, &process_update/1) do
        {:ok, last_offset} ->
          last_offset

        {:error, :timeout} ->
          offset

        {:error, req} ->
          Logger.warning("Failed to get updates: #{inspect(req)}")
          offset
      end

    schedule_poll()
    {:noreply, %{state | offset: new_offset}}
  end

  defp process_update(%{text: text, chat_id: chat_id, offset: offset}) do
    case Hn.Client.process_link(text) do
      {:ok, reply} ->
        send_reply(chat_id, reply)

      {:error, reason} ->
        send_reply(chat_id, "Error: #{reason}")
    end

    process_update(%{offset: offset})
  end

  defp process_update(%{offset: offset}), do: offset + 1

  defp send_reply(chat_id, message) do
    case Telegram.Client.send_message(chat_id, message) do
      {:ok, _} -> :ok
      {:error, reason} -> Logger.warning("Failed to send message: #{inspect(reason)}")
    end
  end

  defp schedule_poll do
    Process.send_after(self(), :poll, @poll_interval)
  end

  defp server_enabled? do
    Application.get_env(:hntg, __MODULE__, [])
    |> Keyword.get(:server, true)
  end
end
