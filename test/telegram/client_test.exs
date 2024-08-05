defmodule Telegram.ClientTest do
  use ExUnit.Case

  import Mox
  alias Telegram.Client
  alias Telegram.API.Fixtures

  describe "get_bot_name/0" do
    test "returns the bot name" do
      # ARRANGE
      Telegram.MockAPI
      |> expect(:get_me, fn -> Fixtures.sample_get_me_response() end)

      # ACT
      assert {:ok, botname} = Client.get_bot_name()

      # ASSERT
      assert botname == Fixtures.sample_bot_username()
    end
  end

  describe "process_updates/2" do
    test "process 1 regular update" do
      # ARRANGE
      Telegram.MockAPI
      |> expect(:get_updates, fn start_offset ->
        {:ok, [Fixtures.sample_update(start_offset)]}
      end)

      # ACT
      assert {:ok, last_offset} = Client.process_updates(0, fn update -> update.offset end)

      # ASSERT
      assert last_offset == 0
    end

    test "process 1 edited message update" do
      # ARRANGE
      Telegram.MockAPI
      |> expect(:get_updates, fn start_offset ->
        {:ok, [Fixtures.sample_update_edited_message(start_offset)]}
      end)

      # ACT
      # Simply test that structural differences between regular messages and
      # edited messages are handled without errors.
      assert {:ok, last_offset} = Client.process_updates(0, fn update -> update.offset end)

      # ASSERT
      assert last_offset == 0
    end

    test "processs a random number of different updates" do
      # ARRANGE
      random_start_offset = :rand.uniform(1_000_000)
      random_num_updates = :rand.uniform(10)
      expected_last_offset = random_start_offset + random_num_updates

      callbacks = [&Fixtures.sample_update/1, &Fixtures.sample_update_edited_message/1]

      Telegram.MockAPI
      |> expect(:get_updates, fn start_offset ->
        {
          :ok,
          # Generate a random number of updates
          Enum.map(start_offset..expected_last_offset, fn offset ->
            Enum.random(callbacks).(offset)
          end)
        }
      end)

      # ACT
      assert {:ok, last_offset} =
               Client.process_updates(random_start_offset, fn update -> update.offset end)

      # ASSERT
      assert last_offset == expected_last_offset
    end
  end

  describe "send_message/2" do
    test "sends a message" do
      # ARRANGE
      Telegram.MockAPI
      |> expect(:send_message, fn chat_id, text ->
        Fixtures.sample_send_message_response(chat_id, text)
      end)

      # ACT
      assert {:ok, _} = Client.send_message(0, "")

      # ASSERT: nothing much to assert on here
    end
  end
end
