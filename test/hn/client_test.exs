defmodule Hn.ClientTest do
  use ExUnit.Case

  import Mox
  alias Hn.Client
  alias Hn.API.Fixtures

  setup :set_mox_from_context
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
      assert {:ok, reply} = Client.process_link("https://news.ycombinator.com/item?id=00000001")

      # ASSERT
      assert reply =~ "Link"
      refute reply =~ "Comments"
    end

    test "multiple process_link/1 calls with the same link only fetches once" do
      # ARRANGE
      Hn.MockAPI
      |> expect(:fetch_item, 1, fn _id -> Fixtures.sample_valid_link_response() end)

      # ACT
      Client.process_link("https://news.ycombinator.com/item?id=00000002")

      # ASSERT
      Hn.MockAPI
      |> expect(:fetch_item, 0, fn _id -> Fixtures.sample_valid_link_response() end)

      Client.process_link("https://news.ycombinator.com/item?id=00000002")
      Client.process_link("https://news.ycombinator.com/item?id=00000002")
    end
  end
end
