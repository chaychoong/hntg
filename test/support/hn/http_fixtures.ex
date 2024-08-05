defmodule Hn.API.Fixtures do
  def sample_valid_link_response do
    {:ok,
     %{
       "by" => "gascoigne",
       "descendants" => 46,
       "id" => 41_151_409,
       "kids" => [41_151_938],
       "score" => 44,
       "time" => 1_722_751_117,
       "title" => "Tomato nostalgia as I relive my Croatian island childhood",
       "type" => "story",
       "url" => "https://www.croatiaweek.com/tomatoes-croatian-island-taste/"
     }}
  end

  def sample_valid_text_response do
    {:ok,
     %{
       "by" => "whoishiring",
       "descendants" => 379,
       "id" => 41_129_813,
       "kids" => [41_130_582],
       "score" => 364,
       "text" => "Please state the location and include...",
       "time" => 1_722_524_434,
       "title" => "Ask HN: Who is hiring? (August 2024)",
       "type" => "story"
     }}
  end
end
