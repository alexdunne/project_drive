defmodule ProjectDriveWeb.FallbackController do
  use Phoenix.Controller

  def call(conn, error) do
    errors =
      error
      |> ProjectDrive.Utils.Error.normalize()
      |> List.wrap()

    status = hd(errors).status_code
    messages = Enum.map(errors, & &1.message)
    extras = Enum.map(errors, & &1.extra)

    conn
    |> put_status(status)
    |> json(%{errors: messages, extras: extras})
  end
end
