# Hntg

Simple Telegram bot for converting HN links to sharable messages. A working
instance of the bot can be found here: [@HNLinkFmtBot](https://t.me/HNLinkFmtBot).

## Development

Make sure you have at least Elixir 1.15 installed.

```sh
# Clone the repository
git clone git@github.com:chaychoong/hntg.git
cd hntg

# Install dependencies
mix deps.get

# Run the bot in an iex session
iex -S mix
```

## Deployment

Run `fly deploy` to deploy the bot to Fly.io. You will need to set the
`TELEGRAM_BOT_TOKEN` environment variable:

```sh
fly secrets set TELEGRAM_BOT_TOKEN=your_token_here
```

If Fly.io is out of the question, you can use the `Dockerfile` to build an OCI
image and run it however you like.
