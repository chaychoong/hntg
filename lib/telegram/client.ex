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

  def get_updates(offset) do
    long_polling_timeout_sec = Application.get_env(:hntg, :long_polling_timeout_sec)

    case Req.get(base_url() <> "getUpdates",
           params: [
             timeout: long_polling_timeout_sec,
             offset: offset
           ],
           receive_timeout: long_polling_timeout_sec * 1_000,
           retry: false
         ) do
      {:ok, req} ->
        req
        |> parse_request()
        |> parse_updates()

      {:error, %Req.TransportError{reason: :timeout}} ->
        :timeout
    end
  end

  defp parse_updates({:ok, updates}) do
    {:ok, Enum.map(updates, &parse_update_msg/1)}
  end

  defp parse_update_msg(%{
         "message" => %{
           "chat" => %{"id" => chat_id},
           "text" => text
         },
         "update_id" => update_id
       }) do
    %{
      chat_id: chat_id,
      text: text,
      offset: update_id
    }
  end

  defp parse_request(%{status: 200, body: %{"ok" => true, "result" => result}}), do: {:ok, result}
  defp parse_request(req), do: {:error, req}
end
