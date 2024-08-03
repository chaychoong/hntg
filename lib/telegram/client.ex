defmodule Telegram.Client do
  @moduledoc """
  A client for interacting with the Telegram Bot API.
  """

  @tg_api_url "https://api.telegram.org/bot"

  @spec get_me() :: {:ok, map()} | {:error, any()}
  def get_me do
    tg_request("getMe")
  end

  @spec get_updates(integer()) :: {:ok, list(map())} | {:error, any()}
  def get_updates(offset) do
    with {:ok, updates} <-
           tg_request("getUpdates",
             params: [
               timeout: long_polling_timeout_sec(),
               offset: offset
             ],
             receive_timeout: long_polling_timeout_sec() * 1_000,
             retry: false
           ) do
      {:ok, Enum.map(updates, &parse_update_msg/1)}
    else
      {:error, %Req.TransportError{reason: :timeout}} -> {:error, :timeout}
      {:error, req} -> {:error, req}
    end
  end

  @spec send_message(integer(), String.t()) :: {:ok, map()} | {:error, any()}
  def send_message(chat_id, text) do
    tg_request("sendMessage",
      headers: [{"Content-Type", "application/json"}],
      json: %{
        chat_id: chat_id,
        text: text,
        parse_mode: "MarkdownV2"
      }
    )
  end

  defp token do
    Application.fetch_env!(:hntg, :telegram_bot_token)
  end

  defp long_polling_timeout_sec do
    Application.fetch_env!(:hntg, :long_polling_timeout_sec)
  end

  defp tg_request(method, opts \\ []) do
    url = @tg_api_url <> token() <> "/" <> method

    case Req.post(url, opts) do
      {:ok, %{status: 200, body: %{"ok" => true, "result" => result}}} -> {:ok, result}
      {_, req} -> {:error, req}
    end
  end

  defp parse_update_msg(%{
         "message" => %{"chat" => %{"id" => chat_id}, "text" => text},
         "update_id" => update_id
       }) do
    %{chat_id: chat_id, text: text, offset: update_id}
  end
end
