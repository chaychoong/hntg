defmodule Telegram.Client do
  @moduledoc """
  A client for interacting with the Telegram Bot API.
  """
  @spec get_bot_name() :: {:ok, String.t()} | {:error, any()}
  def get_bot_name do
    case Telegram.API.get_me() do
      {:ok, %{"username" => botname}} ->
        {:ok, botname}

      {:error, req} ->
        {:error, req}
    end
  end

  @spec process_updates(integer(), (map() -> integer())) :: {:ok, integer()} | {:error, any()}
  def process_updates(offset, callback) do
    with {:ok, updates} <- Telegram.API.get_updates(offset) do
      last_offset =
        updates
        |> Stream.map(&parse_update_msg/1)
        |> Enum.reduce(0, fn update, _acc -> callback.(update) end)

      {:ok, last_offset}
    else
      {:error, :timeout} -> {:error, :timeout}
      {:error, req} -> {:error, req}
    end
  end

  @spec send_message(integer(), String.t()) :: {:ok, map()} | {:error, any()}
  def send_message(chat_id, text) do
    Telegram.API.send_message(chat_id, text)
  end

  defp parse_update_msg(%{
         "message" => %{"chat" => %{"id" => chat_id}, "text" => text},
         "update_id" => update_id
       }) do
    %{chat_id: chat_id, text: text, offset: update_id}
  end

  # Ignore other types of updates, such as edited messages
  defp parse_update_msg(%{"update_id" => update_id}) do
    %{offset: update_id}
  end
end
