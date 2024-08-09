defmodule Hn.Client do
  @moduledoc """
  A client for interacting with the Hacker News API.
  """
  @link_regex ~r{^https://news.ycombinator.com/item\?id=(?<id>\d+)$}
  @escape_regex ~r/([_\[\]()~`>#+=|{}\.!-])/
  @cache_ttl_sec 3_600

  @spec process_link(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def process_link(link) do
    with {:ok, id} <- get_id_from_link(link),
         {:ok, hn_resp} <- fetch_item(id),
         {:ok, reply} <- parse_item(hn_resp, link) do
      {:ok, reply |> String.trim_trailing() |> escape_tg_reserved_chars()}
    else
      :input_error -> {:error, "Invalid input format"}
      :api_error -> {:error, "Failed to fetch item from HN API"}
      :api_resp_error -> {:error, "Failed to parse response from HN API"}
    end
  end

  defp fetch_item(id) do
    Cachex.fetch(:hn_cache, id, fn id ->
      {:commit, Hn.API.fetch_item(id), ttl: :timer.seconds(@cache_ttl_sec)}
    end)
    |> case do
      {:ok, {:ok, hn_resp}} -> {:ok, hn_resp}
      {:commit, {:ok, hn_resp}, _} -> {:ok, hn_resp}
      _ -> :api_error
    end
  end

  defp get_id_from_link(link) do
    case Regex.named_captures(@link_regex, link) do
      %{"id" => id} -> {:ok, id}
      nil -> :input_error
    end
  end

  defp parse_item(%{"url" => url, "title" => title}, link) do
    {:ok,
     """
     *#{title}*

     *Link*: #{url}
     *Comments*: #{link}
     """}
  end

  defp parse_item(%{"text" => _text, "title" => title}, link) do
    {:ok,
     """
     *#{title}*

     *Link*: #{link}
     """}
  end

  defp parse_item(_, _), do: :api_resp_error

  # Escapes Telegram reserved characters.
  # '_', '[', ']', '(', ')', '~', '`', '>', '#', '+', '-', '=', '|', '{', '}', '.', '!'
  defp escape_tg_reserved_chars(text) do
    Regex.replace(@escape_regex, text, fn _, char -> "\\#{char}" end)
  end
end
