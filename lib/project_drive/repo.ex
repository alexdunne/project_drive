defmodule ProjectDrive.Repo do
  use Ecto.Repo,
    otp_app: :project_drive,
    adapter: Ecto.Adapters.Postgres
end
