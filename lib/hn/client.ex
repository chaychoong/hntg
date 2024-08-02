defmodule Hn.Client do
  @hn_api_url "https://hacker-news.firebaseio.com/v0"

  def process_link(link) do
    id = get_id_from_link(link)

    case id do
      %{"id" => id} ->
        reply =
          id
          |> then(&(@hn_api_url <> "/item/#{&1}.json"))
          |> Req.get!()
          |> parse_request(link)

        {:ok, reply}

      nil ->
        :error
    end
  end

  defp get_id_from_link(link) do
    ~r{^https://news.ycombinator.com/item\?id=(?<id>\d+)$}
    |> Regex.named_captures(link)
  end

  defp parse_request(req, link) do
    case req do
      %{status: 200, body: body} ->
        parse_item(body, link)
        |> String.trim_trailing()
        |> escape_tg_reserved_chars()

      _ ->
        {:error, req}
    end
  end

  defp parse_item(%{"url" => url, "title" => title}, link) do
    """
    *#{title}*

    *Link*: #{url}
    *Comments*: #{link}
    """
  end

  defp parse_item(%{"text" => _text, "title" => title}, link) do
    """
    *#{title}*

    *Link*: #{link}
    """
  end

  defp escape_tg_reserved_chars(text) do
    # characters '_', '*', '[', ']', '(', ')', '~', '`', '>', '#', '+', '-', '=', '|', '{', '}', '.', '!'
    # must be escaped with the preceding character '\'
    ~r/([_\[\]()~`>#+=|{}\.!-])/
    |> Regex.replace(text, fn _, char -> "\\#{char}" end)
  end
end
