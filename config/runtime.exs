import Config

config :hntg,
  telegram_bot_token: System.get_env("TELEGRAM_BOT_TOKEN"),
  long_polling_timeout_sec: String.to_integer(System.get_env("LONG_POLLING_TIMEOUT_SEC", "30"))
