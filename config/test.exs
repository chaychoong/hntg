import Config

config :hntg,
  hn_http: Hn.MockAPI,
  tg_http: Telegram.MockAPI

config :hntg, Hntg.Server, server: false
