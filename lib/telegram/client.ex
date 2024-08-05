defmodule Telegram.Client do
  @moduledoc """
  A client for interacting with the Telegram Bot API.
  """
  @spec get_me() :: {:ok, map()} | {:error, any()}
  def get_me do
    case Telegram.API.get_me() do
      {:ok, %{"username" => botname}} ->
        {:ok, botname}

      {:error, req} ->
        {:error, req}
    end
  end

  @spec get_updates(integer()) :: {:ok, list(map())} | {:error, any()}
  def get_updates(offset) do
    with {:ok, updates} <- Telegram.API.get_updates(offset) do
      {:ok, Enum.map(updates, &parse_update_msg/1)}
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
