defmodule Hntg.Server do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    state = %{}

    case Telegram.Client.get_me() do
      {:ok, %{"username" => botname}} ->
        Logger.info("Connected to Telegram as #{botname}")
        {:ok, state}

      {:error, req} ->
        Logger.error("Failed to connect to Telegram: #{inspect(req)}")
        :error
    end
  end
end
