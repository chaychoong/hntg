defmodule Telegram.API do
  @callback get_me() :: {:ok, map()} | {:error, any()}
  @callback get_updates(integer()) :: {:ok, list(map())} | {:error, any()}
  @callback send_message(integer(), String.t()) :: {:ok, map()} | {:error, any()}

  def get_me(), do: impl().get_me()
  def get_updates(offset), do: impl().get_updates(offset)
  def send_message(chat_id, text), do: impl().send_message(chat_id, text)
  defp impl, do: Application.get_env(:hntg, :tg_http, Telegram.HttpAPI)
end
