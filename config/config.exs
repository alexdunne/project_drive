# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :project_drive,
  ecto_repos: [ProjectDrive.Repo]

# Configures the endpoint
config :project_drive, ProjectDriveWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "AKWetV7maKf4/LV5Mj/wqgsc5cTbKwQ2zB/0U4iWfxdLwBn+ftT/0l0LYFZFLGAz",
  render_errors: [view: ProjectDriveWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ProjectDrive.PubSub,
  live_view: [signing_salt: "JOQUKylO"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :project_drive, ProjectDrive.Guardian,
  issuer: "ProjectDrive",
  secret_key: "fbbk2PhNH+wy+vI4INc0I/1iI49X7PSz+TuRfEEFXca762w/w9mY9PMR4Ad8QJqE"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
