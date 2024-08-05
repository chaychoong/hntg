import Config

config :hntg,
  long_polling_timeout_sec: 5

import_config "#{config_env()}.exs"
