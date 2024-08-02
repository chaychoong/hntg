defmodule Telegram.Client do
  @tg_api_url "https://api.telegram.org/bot"

  defp token do
    Application.get_env(:hntg, :telegram_bot_token)
  end

  defp base_url, do: @tg_api_url <> token() <> "/"

  def get_me do
    Req.get!(base_url() <> "getMe")
    |> parse_request()
  end

  defp parse_request(%{status: 200, body: %{"ok" => true, "result" => result}}), do: {:ok, result}
  defp parse_request(req), do: {:error, req}
end
