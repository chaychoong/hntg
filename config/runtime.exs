import Config

config :hntg,
  telegram_bot_token: System.get_env("TELEGRAM_BOT_TOKEN"),
  dns_cluster_query: System.get_env("DNS_CLUSTER_QUERY")
