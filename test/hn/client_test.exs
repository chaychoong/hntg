defmodule Hn.ClientTest do
  use ExUnit.Case

  import Mox
  alias Hn.Client
  alias Hn.API.Fixtures

  setup :verify_on_exit!

  describe "process_link/1" do
    test "returns a formatted message for a valid link post" do
      # ARRANGE
      Hn.MockAPI
      |> expect(:fetch_item, fn _id -> Fixtures.sample_valid_link_response() end)

      # ACT
      assert {:ok, reply} = Client.process_link("https://news.ycombinator.com/item?id=00000000")

      # ASSERT
      assert reply =~ "Link"
      assert reply =~ "Comments"
    end

    test "returns a formatted message for a valid text post" do
      # ARRANGE
      Hn.MockAPI
      |> expect(:fetch_item, fn _id -> Fixtures.sample_valid_text_response() end)

      # ACT
      assert {:ok, reply} = Client.process_link("https://news.ycombinator.com/item?id=00000000")

      # ASSERT
      assert reply =~ "Link"
      refute reply =~ "Comments"
    end
  end
end
