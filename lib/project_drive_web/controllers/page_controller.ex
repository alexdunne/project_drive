defmodule ProjectDriveWeb.PageController do
  use ProjectDriveWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
