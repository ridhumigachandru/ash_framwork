defmodule AshEmployeeApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AshEmployeeAppWeb.Telemetry,
      AshEmployeeApp.Repo,
      {DNSCluster, query: Application.get_env(:ash_employee_app, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AshEmployeeApp.PubSub},
      # Start a worker by calling: AshEmployeeApp.Worker.start_link(arg)
      # {AshEmployeeApp.Worker, arg},
      # Start to serve requests, typically the last entry
      AshEmployeeAppWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AshEmployeeApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AshEmployeeAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
