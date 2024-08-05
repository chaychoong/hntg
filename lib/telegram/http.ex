defmodule Telegram.HttpAPI do
  @moduledoc """
  Make HTTP requests to the Telegram Bot API.
  """
  @behaviour Telegram.API
  @tg_api_url "https://api.telegram.org/bot"

  @impl Telegram.API
  def get_me do
    tg_request("getMe")
  end

  @impl Telegram.API
  def get_updates(offset) do
    tg_request("getUpdates",
      params: [
        timeout: long_polling_timeout_sec(),
        offset: offset
      ],
      receive_timeout: long_polling_timeout_sec() * 1_000,
      retry: false
    )
  end

  @impl Telegram.API
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

  defp tg_request(method, opts \\ []) do
    url = @tg_api_url <> token() <> "/" <> method

    case Req.post(url, opts) do
      {:ok, %{status: 200, body: %{"ok" => true, "result" => result}}} -> {:ok, result}
      {_, req} -> {:error, req}
    end
  end

  defp token do
    Application.fetch_env!(:hntg, :telegram_bot_token)
  end

  defp long_polling_timeout_sec do
    Application.fetch_env!(:hntg, :long_polling_timeout_sec)
  end
end
