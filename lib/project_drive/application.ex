defmodule ProjectDrive.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ProjectDrive.Repo,
      # Start the Telemetry supervisor
      ProjectDriveWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ProjectDrive.PubSub},
      # Start the Endpoint (http/https)
      ProjectDriveWeb.Endpoint,
      # Start a worker by calling: ProjectDrive.Worker.start_link(arg)
      # {ProjectDrive.Worker, arg}
      ProjectDrive.EventHandler.Supervisor,
      # Start the Oban instances
      {Oban, oban_config()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ProjectDrive.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ProjectDriveWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp oban_config do
    Application.get_env(:project_drive, Oban)
  end
end
