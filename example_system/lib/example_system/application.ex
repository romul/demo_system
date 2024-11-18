defmodule ExampleSystem.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    LoadControl.change_schedulers(1)

    children = [
      ExampleSystemWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:example_system, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ExampleSystem.PubSub},
      # Start a worker by calling: ExampleSystem.Worker.start_link(arg)
      # {ExampleSystem.Worker, arg},
      ExampleSystem.Top,
      ExampleSystem.Metrics,
      ExampleSystem.Service,
      ExampleSystem.Math,
      # Start to serve requests, typically the last entry
      ExampleSystemWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExampleSystem.Supervisor]

    with {:ok, pid} <- Supervisor.start_link(children, opts) do
      LoadControl.change_load(0)
      {:ok, pid}
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ExampleSystemWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
