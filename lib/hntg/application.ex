defmodule Hntg.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Hntg.Worker.start_link(arg)
      # {Hntg.Worker, arg}
      {DNSCluster, query: Application.get_env(:hntg, :dns_cluster_query) || :ignore},
      Hntg.Server,
      {Task.Supervisor, name: Hntg.TaskSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hntg.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
