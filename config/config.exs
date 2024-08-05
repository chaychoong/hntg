import Config

config :hntg,
  long_polling_timeout_sec: 5

config :hntg, Hntg.Server, server: true

import_config "#{config_env()}.exs"
