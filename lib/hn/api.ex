defmodule Hn.API do
  @callback fetch_item(String.t()) :: {:ok, map()} | :api_error

  def fetch_item(id), do: impl().fetch_item(id)
  defp impl, do: Application.get_env(:hntg, :hn_http, Hn.HttpAPI)
end
