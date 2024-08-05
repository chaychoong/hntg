defmodule Telegram.API.Fixtures do
  def sample_get_me_response do
    {:ok,
     %{
       "can_connect_to_business" => false,
       "can_join_groups" => true,
       "can_read_all_group_messages" => false,
       "first_name" => sample_bot_first_name(),
       "has_main_web_app" => false,
       "id" => sample_bot_id(),
       "is_bot" => true,
       "supports_inline_queries" => false,
       "username" => sample_bot_username()
     }}
  end

  def sample_update(offset) do
    %{
      "message" => %{
        "chat" => %{
          "first_name" => sample_user_first_name(),
          "id" => sample_user_id(),
          "last_name" => sample_user_last_name(),
          "type" => "private",
          "username" => sample_user_username()
        },
        "date" => 1_111_111_111,
        "from" => %{
          "first_name" => sample_user_first_name(),
          "id" => sample_user_id(),
          "is_bot" => false,
          "language_code" => "en",
          "last_name" => sample_user_last_name(),
          "username" => sample_user_username()
        },
        "message_id" => 1,
        "text" => "sample_text"
      },
      "update_id" => offset
    }
  end

  def sample_update_edited_message(offset) do
    %{
      "edited_message" => %{
        "chat" => %{
          "first_name" => sample_user_first_name(),
          "id" => sample_user_id(),
          "last_name" => sample_user_last_name(),
          "type" => "private",
          "username" => sample_user_username()
        },
        "date" => 1_111_111_111,
        "edit_date" => 2_222_222_222,
        "from" => %{
          "first_name" => sample_user_first_name(),
          "id" => sample_user_id(),
          "is_bot" => false,
          "language_code" => "en",
          "last_name" => sample_user_last_name(),
          "username" => sample_user_username()
        },
        "message_id" => 1,
        "text" => "sample_edited_text"
      },
      "update_id" => offset
    }
  end

  def sample_send_message_response(chat_id, text) do
    {:ok,
     %{
       "chat" => %{
         "first_name" => sample_user_first_name(),
         "id" => chat_id,
         "last_name" => sample_user_last_name(),
         "type" => "private",
         "username" => sample_user_username()
       },
       "date" => 1_111_111_111,
       "from" => %{
         "first_name" => sample_bot_first_name(),
         "id" => sample_bot_id(),
         "is_bot" => true,
         "username" => sample_bot_username()
       },
       "message_id" => 0,
       "text" => text
     }}
  end

  def sample_bot_first_name, do: "Mock Bot"
  def sample_bot_username, do: "mock_bot"
  def sample_bot_id, do: 7_777_777_777

  def sample_user_first_name, do: "First"
  def sample_user_last_name, do: "Last"
  def sample_user_username, do: "sample_username"
  def sample_user_id, do: 33_333_333
end
