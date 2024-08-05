defmodule Hn.HttpAPI do
  @moduledoc """
  Make HTTP requests to the Hacker News API.
  """
  @behaviour Hn.API
  @hn_api_url "https://hacker-news.firebaseio.com/v0"

  @impl Hn.API
  def fetch_item(id) do
    case Req.get("#{@hn_api_url}/item/#{id}.json") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      _ -> :api_error
    end
  end
end
